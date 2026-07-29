[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RootPath,

    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-ObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object.PSObject.Properties[$Name]
}

function Assert-OnlyProperties {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Allowed,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    foreach ($property in @($Object.PSObject.Properties)) {
        if ($Allowed -cnotcontains [string]$property.Name) {
            throw "$Purpose contains unsupported property '$($property.Name)'."
        }
    }
}

function Assert-RequiredProperties {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    foreach ($name in $Required) {
        if (-not (Test-ObjectProperty -Object $Object -Name $name)) {
            throw "$Purpose is missing '$name'."
        }
    }
}

function Assert-JsonArray {
    param(
        [AllowEmptyCollection()][Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    if ($Value -isnot [System.Array]) {
        throw "$Purpose must be a JSON array."
    }
}

function Get-PositiveInteger {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Purpose,
        [int64]$Maximum = [int64]::MaxValue
    )

    if ($Value -isnot [byte] -and
        $Value -isnot [int16] -and
        $Value -isnot [int32] -and
        $Value -isnot [int64]) {
        throw "$Purpose must be a JSON integer."
    }
    $number = [int64]$Value
    if ($number -lt 1 -or $number -gt $Maximum) {
        throw "$Purpose must be between 1 and $Maximum."
    }
    return $number
}

function Get-ExplicitRoot {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or
        -not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Draw.io validation requires an explicit existing RootPath directory."
    }
    $item = Get-Item -Force -LiteralPath $Path
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Draw.io validation rejects a RootPath that is a symbolic link or reparse point."
    }
    $fullName = $item.FullName.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $volumeRoot = [System.IO.Path]::GetPathRoot($item.FullName).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    if ($fullName.Equals($volumeRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Draw.io validation RootPath must be narrower than a filesystem volume root."
    }
    return $fullName
}

function Resolve-ContainedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Purpose,
        [switch]$AllowMissing
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw "$Purpose must not be empty."
    }
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "$Purpose must be relative to the explicit RootPath: $RelativePath"
    }
    if ($RelativePath.Contains("\")) {
        throw "$Purpose must use forward slashes: $RelativePath"
    }
    $segments = @($RelativePath.Split("/"))
    if ($segments.Count -eq 0 -or
        @($segments | Where-Object { $_ -eq "" -or $_ -eq "." -or $_ -eq ".." }).Count -gt 0) {
        throw "$Purpose must be a canonical relative path without empty, dot, or parent segments: $RelativePath"
    }

    $candidate = [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath))
    $rootPrefix = $Root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $candidate.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "$Purpose escapes the explicit RootPath: $RelativePath"
    }

    $ancestor = $candidate
    while ($true) {
        if (Test-Path -LiteralPath $ancestor) {
            $item = Get-Item -Force -LiteralPath $ancestor
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "$Purpose traverses a symbolic link or reparse point: $RelativePath"
            }
        }
        if ($ancestor.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
            break
        }
        $parent = [System.IO.Directory]::GetParent($ancestor)
        if ($null -eq $parent) {
            throw "Could not prove containment for $Purpose '$RelativePath'."
        }
        $ancestor = $parent.FullName
    }

    if (-not $AllowMissing -and -not (Test-Path -LiteralPath $candidate)) {
        throw "$Purpose does not exist: $RelativePath"
    }
    return $candidate
}

function Read-StrictUtf8 {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][int64]$MaximumBytes,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    $item = Get-Item -Force -LiteralPath $Path
    if ($item.Length -gt $MaximumBytes) {
        throw "$Purpose exceeds the declared byte limit of $MaximumBytes."
    }
    $encoding = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        return [System.IO.File]::ReadAllText($Path, $encoding)
    }
    catch {
        throw "$Purpose is not valid UTF-8: $($_.Exception.Message)"
    }
}

function ConvertFrom-SafeXml {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int64]$MaximumCharacters,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    $settings = New-Object System.Xml.XmlReaderSettings
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $settings.XmlResolver = $null
    $settings.MaxCharactersInDocument = $MaximumCharacters
    $settings.MaxCharactersFromEntities = 0
    $stringReader = New-Object System.IO.StringReader($Text)
    $reader = $null
    try {
        $reader = [System.Xml.XmlReader]::Create($stringReader, $settings)
        $document = New-Object System.Xml.XmlDocument
        $document.XmlResolver = $null
        $document.PreserveWhitespace = $false
        $document.Load($reader)
        return $document
    }
    catch {
        throw "$Purpose contains invalid or unsafe XML: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $reader) { $reader.Dispose() }
        $stringReader.Dispose()
    }
}

function Expand-CompressedDiagram {
    param(
        [Parameter(Mandatory = $true)][string]$Encoded,
        [Parameter(Mandatory = $true)][int64]$MaximumBytes,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    try {
        $compressed = [System.Convert]::FromBase64String($Encoded.Trim())
    }
    catch {
        throw "$Purpose is not valid base64."
    }

    $input = New-Object System.IO.MemoryStream(, $compressed)
    $deflate = $null
    $output = New-Object System.IO.MemoryStream
    try {
        $deflate = New-Object System.IO.Compression.DeflateStream(
            $input,
            [System.IO.Compression.CompressionMode]::Decompress
        )
        $buffer = New-Object byte[] 8192
        while (($read = $deflate.Read($buffer, 0, $buffer.Length)) -gt 0) {
            if (($output.Length + $read) -gt $MaximumBytes) {
                throw "$Purpose exceeds the declared decoded-page byte limit of $MaximumBytes."
            }
            $output.Write($buffer, 0, $read)
        }
        $utf8 = New-Object System.Text.UTF8Encoding($false, $true)
        $uriEncoded = $utf8.GetString($output.ToArray())
        try {
            return [System.Uri]::UnescapeDataString($uriEncoded)
        }
        catch {
            throw "$Purpose contains invalid URI-encoded XML."
        }
    }
    catch {
        if ($_.Exception.Message.StartsWith($Purpose)) {
            throw
        }
        throw "$Purpose could not be decompressed: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $deflate) { $deflate.Dispose() }
        $output.Dispose()
        $input.Dispose()
    }
}

function Test-FiniteNumber {
    param([Parameter(Mandatory = $true)][string]$Value)

    $number = 0.0
    $parsed = [double]::TryParse(
        $Value,
        [System.Globalization.NumberStyles]::Float,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [ref]$number
    )
    return $parsed -and -not [double]::IsNaN($number) -and -not [double]::IsInfinity($number)
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)]$List,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][string]$Page,
        [AllowNull()][string]$CellId,
        [AllowNull()][string]$Label,
        [Parameter(Mandatory = $true)][string]$Message
    )

    [void]$List.Add([pscustomobject][ordered]@{
        code = $Code
        path = $Path
        page = $Page
        cellId = $CellId
        label = $Label
        message = $Message
    })
}

function Get-NormalizedLabel {
    param([AllowEmptyString()][string]$Value)

    if ($null -eq $Value) { return "" }
    $decoded = [System.Net.WebUtility]::HtmlDecode($Value)
    $withoutMarkup = [regex]::Replace($decoded, "<[^>]*>", " ")
    return [regex]::Replace($withoutMarkup, "\s+", " ").Trim()
}

function Test-LabelRuleMatch {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)]$Rule
    )

    $comparison = if ([bool]$Rule.caseSensitive) {
        [System.StringComparison]::Ordinal
    }
    else {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    if ([string]$Rule.match -ceq "exact") {
        return $Label.Equals([string]$Rule.text, $comparison)
    }
    return $Label.IndexOf([string]$Rule.text, $comparison) -ge 0
}

function Assert-LabelRule {
    param(
        [Parameter(Mandatory = $true)]$Rule,
        [Parameter(Mandatory = $true)][string]$Purpose,
        [switch]$Stale
    )

    $allowed = @("text", "match", "caseSensitive")
    $required = @("text", "match", "caseSensitive")
    if ($Stale) {
        $allowed += "replacement"
        $required += "replacement"
    }
    Assert-OnlyProperties -Object $Rule -Allowed $allowed -Purpose $Purpose
    Assert-RequiredProperties -Object $Rule -Required $required -Purpose $Purpose
    if ($Rule.text -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$Rule.text)) {
        throw "$Purpose text must be a non-empty JSON string."
    }
    if ([string]$Rule.match -cnotin @("exact", "substring")) {
        throw "$Purpose match must be 'exact' or 'substring'."
    }
    if ($Rule.caseSensitive -isnot [bool]) {
        throw "$Purpose caseSensitive must be a JSON boolean."
    }
    if ($Stale) {
        if ($Rule.replacement -isnot [string] -or
            [string]::IsNullOrWhiteSpace([string]$Rule.replacement)) {
            throw "$Purpose replacement must be a non-empty JSON string."
        }
        if ([string]$Rule.text -ceq [string]$Rule.replacement) {
            throw "$Purpose replacement must differ from its stale text."
        }
    }
}

function Test-GraphModel {
    param(
        [Parameter(Mandatory = $true)][System.Xml.XmlElement]$Model,
        [Parameter(Mandatory = $true)][string]$ArtifactPath,
        [Parameter(Mandatory = $true)][string]$PageName,
        [Parameter(Mandatory = $true)]$Findings
    )

    $rootNode = $Model.SelectSingleNode("./root")
    if ($null -eq $rootNode) {
        Add-Finding -List $Findings -Code "GRAPH_ROOT_MISSING" -Path $ArtifactPath `
            -Page $PageName -CellId $null -Label $null `
            -Message "The mxGraphModel page has no root element."
        return [pscustomobject]@{ renderable = $false; cellCount = 0; visualCellCount = 0 }
    }

    $cells = @($rootNode.SelectNodes(".//mxCell"))
    $cellById = New-Object "System.Collections.Generic.Dictionary[string,System.Xml.XmlElement]" (
        [System.StringComparer]::Ordinal
    )
    foreach ($cell in $cells) {
        $id = $cell.GetAttribute("id")
        if ([string]::IsNullOrWhiteSpace($id)) {
            Add-Finding -List $Findings -Code "CELL_ID_MISSING" -Path $ArtifactPath `
                -Page $PageName -CellId $null -Label $null `
                -Message "Every mxCell must have a non-empty id."
            continue
        }
        if ($cellById.ContainsKey($id)) {
            Add-Finding -List $Findings -Code "CELL_ID_DUPLICATE" -Path $ArtifactPath `
                -Page $PageName -CellId $id -Label $null `
                -Message "The mxCell id '$id' occurs more than once on the page."
            continue
        }
        $cellById[$id] = $cell
    }

    if (-not $cellById.ContainsKey("0")) {
        Add-Finding -List $Findings -Code "ROOT_CELL_MISSING" -Path $ArtifactPath `
            -Page $PageName -CellId "0" -Label $null `
            -Message "The page must contain the mxGraph root cell with id '0'."
    }
    elseif (-not [string]::IsNullOrWhiteSpace($cellById["0"].GetAttribute("parent"))) {
        Add-Finding -List $Findings -Code "ROOT_CELL_INVALID" -Path $ArtifactPath `
            -Page $PageName -CellId "0" -Label $null `
            -Message "The mxGraph root cell with id '0' must not have a parent."
    }
    if (-not $cellById.ContainsKey("1") -or
        $cellById["1"].GetAttribute("parent") -cne "0") {
        Add-Finding -List $Findings -Code "DEFAULT_LAYER_MISSING" -Path $ArtifactPath `
            -Page $PageName -CellId "1" -Label $null `
            -Message "The page must contain default layer cell '1' whose parent is '0'."
    }

    $visualCount = 0
    foreach ($cell in $cells) {
        $id = $cell.GetAttribute("id")
        $parent = $cell.GetAttribute("parent")
        $source = $cell.GetAttribute("source")
        $target = $cell.GetAttribute("target")
        $isVertex = $cell.GetAttribute("vertex") -ceq "1"
        $isEdge = $cell.GetAttribute("edge") -ceq "1"

        if ($isVertex -and $isEdge) {
            Add-Finding -List $Findings -Code "CELL_KIND_CONFLICT" -Path $ArtifactPath `
                -Page $PageName -CellId $id -Label $null `
                -Message "An mxCell cannot be both a vertex and an edge."
        }
        if ($id -cne "0" -and [string]::IsNullOrWhiteSpace($parent)) {
            Add-Finding -List $Findings -Code "CELL_PARENT_MISSING" -Path $ArtifactPath `
                -Page $PageName -CellId $id -Label $null `
                -Message "Non-root cell '$id' has no parent reference."
        }
        elseif (-not [string]::IsNullOrWhiteSpace($parent) -and
            -not $cellById.ContainsKey($parent)) {
            Add-Finding -List $Findings -Code "CELL_PARENT_UNKNOWN" -Path $ArtifactPath `
                -Page $PageName -CellId $id -Label $null `
                -Message "Cell '$id' references unknown parent '$parent'."
        }

        foreach ($endpoint in @(
            [pscustomobject]@{ name = "source"; value = $source },
            [pscustomobject]@{ name = "target"; value = $target }
        )) {
            if (-not [string]::IsNullOrWhiteSpace([string]$endpoint.value) -and
                -not $cellById.ContainsKey([string]$endpoint.value)) {
                Add-Finding -List $Findings -Code "EDGE_ENDPOINT_UNKNOWN" -Path $ArtifactPath `
                    -Page $PageName -CellId $id -Label $null `
                    -Message "Cell '$id' references unknown $($endpoint.name) '$($endpoint.value)'."
            }
        }

        if (-not $isVertex -and -not $isEdge) { continue }
        $visualCount++
        $geometry = $cell.SelectSingleNode("./mxGeometry")
        if ($null -eq $geometry) {
            Add-Finding -List $Findings -Code "GEOMETRY_MISSING" -Path $ArtifactPath `
                -Page $PageName -CellId $id -Label $null `
                -Message "Visual cell '$id' has no mxGeometry."
            continue
        }

        foreach ($coordinate in @("x", "y")) {
            if ($geometry.HasAttribute($coordinate) -and
                -not (Test-FiniteNumber -Value $geometry.GetAttribute($coordinate))) {
                Add-Finding -List $Findings -Code "GEOMETRY_NUMBER_INVALID" -Path $ArtifactPath `
                    -Page $PageName -CellId $id -Label $null `
                    -Message "Visual cell '$id' has a non-finite $coordinate coordinate."
            }
        }
        if ($isVertex) {
            foreach ($dimension in @("width", "height")) {
                $value = $geometry.GetAttribute($dimension)
                $number = 0.0
                $parsed = Test-FiniteNumber -Value $value
                if ($parsed) {
                    [void][double]::TryParse(
                        $value,
                        [System.Globalization.NumberStyles]::Float,
                        [System.Globalization.CultureInfo]::InvariantCulture,
                        [ref]$number
                    )
                }
                if (-not $parsed -or $number -le 0) {
                    Add-Finding -List $Findings -Code "GEOMETRY_DIMENSION_INVALID" -Path $ArtifactPath `
                        -Page $PageName -CellId $id -Label $null `
                        -Message "Vertex '$id' requires finite positive $dimension geometry."
                }
            }
        }
        elseif ($isEdge) {
            if ([string]::IsNullOrWhiteSpace($source) -and
                $null -eq $geometry.SelectSingleNode("./mxPoint[@as='sourcePoint']")) {
                Add-Finding -List $Findings -Code "EDGE_TERMINAL_MISSING" -Path $ArtifactPath `
                    -Page $PageName -CellId $id -Label $null `
                    -Message "Unconnected edge '$id' requires a sourcePoint in its geometry."
            }
            if ([string]::IsNullOrWhiteSpace($target) -and
                $null -eq $geometry.SelectSingleNode("./mxPoint[@as='targetPoint']")) {
                Add-Finding -List $Findings -Code "EDGE_TERMINAL_MISSING" -Path $ArtifactPath `
                    -Page $PageName -CellId $id -Label $null `
                    -Message "Unconnected edge '$id' requires a targetPoint in its geometry."
            }
        }
    }

    foreach ($startId in @($cellById.Keys | Sort-Object)) {
        if ($startId -ceq "0") { continue }
        $visited = New-Object "System.Collections.Generic.HashSet[string]" (
            [System.StringComparer]::Ordinal
        )
        $currentId = [string]$startId
        while ($cellById.ContainsKey($currentId)) {
            if (-not $visited.Add($currentId)) {
                Add-Finding -List $Findings -Code "CELL_PARENT_CYCLE" -Path $ArtifactPath `
                    -Page $PageName -CellId ([string]$startId) -Label $null `
                    -Message "Cell '$startId' participates in a parent-reference cycle."
                break
            }
            $nextParent = $cellById[$currentId].GetAttribute("parent")
            if ([string]::IsNullOrWhiteSpace($nextParent) -or
                -not $cellById.ContainsKey($nextParent)) {
                break
            }
            $currentId = $nextParent
        }
    }

    return [pscustomobject]@{
        renderable = $visualCount -gt 0
        cellCount = $cells.Count
        visualCellCount = $visualCount
    }
}

$root = Get-ExplicitRoot -Path $RootPath
$manifestFullPath = Resolve-ContainedPath -Root $root -RelativePath $ManifestPath `
    -Purpose "Draw.io validation manifest"
if (-not (Test-Path -LiteralPath $manifestFullPath -PathType Leaf) -or
    -not [System.IO.Path]::GetExtension($manifestFullPath).Equals(
        ".json",
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
    throw "Draw.io validation manifest must be an existing .json file."
}

$manifestText = Read-StrictUtf8 -Path $manifestFullPath -MaximumBytes 1048576 `
    -Purpose "Draw.io validation manifest"
try {
    $manifest = $manifestText | ConvertFrom-Json
}
catch {
    throw "Draw.io validation manifest contains invalid JSON: $($_.Exception.Message)"
}

Assert-OnlyProperties -Object $manifest `
    -Allowed @("schemaVersion", "maxDrawioBytes", "maxDecodedPageBytes", "artifacts") `
    -Purpose "Draw.io validation manifest"
Assert-RequiredProperties -Object $manifest `
    -Required @("schemaVersion", "maxDrawioBytes", "maxDecodedPageBytes", "artifacts") `
    -Purpose "Draw.io validation manifest"
if ($manifest.schemaVersion -isnot [byte] -and
    $manifest.schemaVersion -isnot [int16] -and
    $manifest.schemaVersion -isnot [int32] -and
    $manifest.schemaVersion -isnot [int64]) {
    throw "Draw.io validation manifest schemaVersion must be JSON integer 1."
}
if ([int64]$manifest.schemaVersion -ne 1) {
    throw "Draw.io validation manifest schemaVersion must be 1."
}
$maxDrawioBytes = Get-PositiveInteger -Value $manifest.maxDrawioBytes `
    -Purpose "maxDrawioBytes" -Maximum 52428800
$maxDecodedPageBytes = Get-PositiveInteger -Value $manifest.maxDecodedPageBytes `
    -Purpose "maxDecodedPageBytes" -Maximum 52428800
Assert-JsonArray -Value $manifest.artifacts -Purpose "artifacts"
$artifacts = @($manifest.artifacts)
if ($artifacts.Count -eq 0) {
    throw "Draw.io validation manifest must declare at least one artifact."
}

$seenArtifacts = New-Object "System.Collections.Generic.HashSet[string]" (
    [System.StringComparer]::OrdinalIgnoreCase
)
$normalizedArtifacts = New-Object System.Collections.ArrayList
for ($artifactIndex = 0; $artifactIndex -lt $artifacts.Count; $artifactIndex++) {
    $artifact = $artifacts[$artifactIndex]
    $purpose = "Draw.io artifact[$artifactIndex]"
    Assert-OnlyProperties -Object $artifact `
        -Allowed @(
            "path",
            "linkedSources",
            "minimumRenderablePages",
            "forbiddenLabels",
            "staleLabels"
        ) `
        -Purpose $purpose
    Assert-RequiredProperties -Object $artifact `
        -Required @(
            "path",
            "linkedSources",
            "minimumRenderablePages",
            "forbiddenLabels",
            "staleLabels"
        ) `
        -Purpose $purpose
    if ($artifact.path -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$artifact.path) -or
        -not [System.IO.Path]::GetExtension([string]$artifact.path).Equals(
            ".drawio",
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
        throw "$purpose path must be a non-empty relative .drawio path."
    }
    $artifactPath = [string]$artifact.path
    [void](Resolve-ContainedPath -Root $root -RelativePath $artifactPath `
        -Purpose "$purpose path" -AllowMissing)
    if (-not $seenArtifacts.Add($artifactPath)) {
        throw "Draw.io validation manifest contains duplicate artifact path '$artifactPath'."
    }
    $minimumPages = Get-PositiveInteger -Value $artifact.minimumRenderablePages `
        -Purpose "$purpose minimumRenderablePages" -Maximum 1000

    Assert-JsonArray -Value $artifact.linkedSources -Purpose "$purpose linkedSources"
    $linkedSources = @($artifact.linkedSources)
    if ($linkedSources.Count -eq 0) {
        throw "$purpose must declare at least one linked source."
    }
    $seenSources = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::OrdinalIgnoreCase
    )
    $normalizedSources = New-Object System.Collections.ArrayList
    foreach ($sourceValue in $linkedSources) {
        if ($sourceValue -isnot [string] -or
            [string]::IsNullOrWhiteSpace([string]$sourceValue)) {
            throw "$purpose linkedSources must contain non-empty JSON strings."
        }
        $sourcePath = [string]$sourceValue
        [void](Resolve-ContainedPath -Root $root -RelativePath $sourcePath `
            -Purpose "$purpose linked source" -AllowMissing)
        if (-not $seenSources.Add($sourcePath)) {
            throw "$purpose contains duplicate linked source '$sourcePath'."
        }
        [void]$normalizedSources.Add($sourcePath)
    }

    Assert-JsonArray -Value $artifact.forbiddenLabels -Purpose "$purpose forbiddenLabels"
    $forbiddenRules = @($artifact.forbiddenLabels)
    for ($ruleIndex = 0; $ruleIndex -lt $forbiddenRules.Count; $ruleIndex++) {
        Assert-LabelRule -Rule $forbiddenRules[$ruleIndex] `
            -Purpose "$purpose forbiddenLabels[$ruleIndex]"
    }
    Assert-JsonArray -Value $artifact.staleLabels -Purpose "$purpose staleLabels"
    $staleRules = @($artifact.staleLabels)
    for ($ruleIndex = 0; $ruleIndex -lt $staleRules.Count; $ruleIndex++) {
        Assert-LabelRule -Rule $staleRules[$ruleIndex] `
            -Purpose "$purpose staleLabels[$ruleIndex]" -Stale
    }

    [void]$normalizedArtifacts.Add([pscustomobject][ordered]@{
        path = $artifactPath
        linkedSources = [object[]]@($normalizedSources | Sort-Object)
        minimumRenderablePages = $minimumPages
        forbiddenLabels = [object[]]$forbiddenRules
        staleLabels = [object[]]$staleRules
    })
}

$findings = New-Object System.Collections.ArrayList
$artifactResults = New-Object System.Collections.ArrayList
foreach ($artifact in @($normalizedArtifacts | Sort-Object path)) {
    $artifactPath = [string]$artifact.path
    $artifactFullPath = Resolve-ContainedPath -Root $root -RelativePath $artifactPath `
        -Purpose "Draw.io artifact path" -AllowMissing
    foreach ($sourcePath in @($artifact.linkedSources)) {
        $sourceFullPath = Resolve-ContainedPath -Root $root -RelativePath ([string]$sourcePath) `
            -Purpose "Draw.io linked source" -AllowMissing
        if (-not (Test-Path -LiteralPath $sourceFullPath -PathType Leaf)) {
            Add-Finding -List $findings -Code "LINKED_SOURCE_MISSING" -Path $artifactPath `
                -Page $null -CellId $null -Label $null `
                -Message "Declared linked source does not exist as a file: $sourcePath"
        }
    }

    $pageResults = New-Object System.Collections.ArrayList
    $labels = New-Object System.Collections.ArrayList
    if (-not (Test-Path -LiteralPath $artifactFullPath -PathType Leaf)) {
        Add-Finding -List $findings -Code "DRAWIO_MISSING" -Path $artifactPath `
            -Page $null -CellId $null -Label $null `
            -Message "Declared Draw.io artifact does not exist as a file."
    }
    else {
        try {
            $drawioText = Read-StrictUtf8 -Path $artifactFullPath `
                -MaximumBytes $maxDrawioBytes -Purpose "Draw.io artifact '$artifactPath'"
            $drawioXml = ConvertFrom-SafeXml -Text $drawioText `
                -MaximumCharacters ($maxDrawioBytes * 2) -Purpose "Draw.io artifact '$artifactPath'"
            if ($drawioXml.DocumentElement.LocalName -cne "mxfile") {
                throw "Draw.io artifact '$artifactPath' root element must be mxfile."
            }
            $diagramNodes = @($drawioXml.DocumentElement.SelectNodes("./diagram"))
            if ($diagramNodes.Count -eq 0) {
                throw "Draw.io artifact '$artifactPath' must contain at least one diagram page."
            }

            for ($pageIndex = 0; $pageIndex -lt $diagramNodes.Count; $pageIndex++) {
                $diagram = $diagramNodes[$pageIndex]
                $pageName = $diagram.GetAttribute("name")
                if ([string]::IsNullOrWhiteSpace($pageName)) {
                    $pageName = "page[$pageIndex]"
                }
                $model = $diagram.SelectSingleNode("./mxGraphModel")
                if ($null -eq $model) {
                    try {
                        $expanded = Expand-CompressedDiagram -Encoded $diagram.InnerText `
                            -MaximumBytes $maxDecodedPageBytes `
                            -Purpose "Draw.io page '$pageName' in '$artifactPath'"
                        $expandedXml = ConvertFrom-SafeXml -Text $expanded `
                            -MaximumCharacters ($maxDecodedPageBytes * 2) `
                            -Purpose "Draw.io page '$pageName' in '$artifactPath'"
                        if ($expandedXml.DocumentElement.LocalName -cne "mxGraphModel") {
                            throw "Draw.io page '$pageName' in '$artifactPath' does not decode to mxGraphModel."
                        }
                        $model = $expandedXml.DocumentElement
                    }
                    catch {
                        Add-Finding -List $findings -Code "PAGE_MODEL_INVALID" -Path $artifactPath `
                            -Page $pageName -CellId $null -Label $null -Message $_.Exception.Message
                        [void]$pageResults.Add([pscustomobject][ordered]@{
                            name = $pageName
                            renderable = $false
                            cellCount = 0
                            visualCellCount = 0
                        })
                        continue
                    }
                }

                $pageFindingCount = $findings.Count
                $graphResult = Test-GraphModel -Model $model -ArtifactPath $artifactPath `
                    -PageName $pageName -Findings $findings
                $pageStructurallyValid = $findings.Count -eq $pageFindingCount
                [void]$pageResults.Add([pscustomobject][ordered]@{
                    name = $pageName
                    renderable = [bool]($pageStructurallyValid -and $graphResult.renderable)
                    cellCount = [int]$graphResult.cellCount
                    visualCellCount = [int]$graphResult.visualCellCount
                })

                foreach ($cell in @($model.SelectNodes("./root//mxCell[@value]"))) {
                    $normalized = Get-NormalizedLabel -Value $cell.GetAttribute("value")
                    if (-not [string]::IsNullOrWhiteSpace($normalized)) {
                        [void]$labels.Add([pscustomobject]@{
                            page = $pageName
                            cellId = $cell.GetAttribute("id")
                            text = $normalized
                        })
                    }
                }
                foreach ($labelNode in @($model.SelectNodes("./root//*[@label]"))) {
                    $normalized = Get-NormalizedLabel -Value $labelNode.GetAttribute("label")
                    if (-not [string]::IsNullOrWhiteSpace($normalized)) {
                        $childCell = $labelNode.SelectSingleNode("./mxCell")
                        $childId = if ($null -ne $childCell) {
                            $childCell.GetAttribute("id")
                        }
                        else {
                            ""
                        }
                        [void]$labels.Add([pscustomobject]@{
                            page = $pageName
                            cellId = $childId
                            text = $normalized
                        })
                    }
                }
            }
        }
        catch {
            Add-Finding -List $findings -Code "DRAWIO_XML_INVALID" -Path $artifactPath `
                -Page $null -CellId $null -Label $null -Message $_.Exception.Message
        }
    }

    $renderableCount = @($pageResults | Where-Object { $_.renderable }).Count
    if ($renderableCount -lt [int64]$artifact.minimumRenderablePages) {
        Add-Finding -List $findings -Code "RENDERABLE_PAGE_MINIMUM_NOT_MET" `
            -Path $artifactPath -Page $null -CellId $null -Label $null `
            -Message (
                "Expected at least $($artifact.minimumRenderablePages) structurally renderable " +
                "page(s), found $renderableCount."
            )
    }

    foreach ($labelRecord in @($labels)) {
        foreach ($rule in @($artifact.forbiddenLabels)) {
            if (Test-LabelRuleMatch -Label ([string]$labelRecord.text) -Rule $rule) {
                Add-Finding -List $findings -Code "FORBIDDEN_LABEL" -Path $artifactPath `
                    -Page ([string]$labelRecord.page) -CellId ([string]$labelRecord.cellId) `
                    -Label ([string]$labelRecord.text) `
                    -Message "Diagram label matches forbidden text '$($rule.text)'."
            }
        }
        foreach ($rule in @($artifact.staleLabels)) {
            if (Test-LabelRuleMatch -Label ([string]$labelRecord.text) -Rule $rule) {
                Add-Finding -List $findings -Code "STALE_LABEL" -Path $artifactPath `
                    -Page ([string]$labelRecord.page) -CellId ([string]$labelRecord.cellId) `
                    -Label ([string]$labelRecord.text) `
                    -Message (
                        "Diagram label uses stale text '$($rule.text)'; " +
                        "replace it with '$($rule.replacement)'."
                    )
            }
        }
    }

    [void]$artifactResults.Add([pscustomobject][ordered]@{
        path = $artifactPath
        linkedSources = [object[]]$artifact.linkedSources
        pages = [object[]]@($pageResults)
        renderablePages = $renderableCount
        labelCount = $labels.Count
    })
}

$orderedFindings = [object[]]@(
    $findings |
        Sort-Object code, path, page, cellId, label, message
)
$result = [pscustomobject][ordered]@{
    schemaVersion = 1
    validator = "annifity-drawio-structure"
    manifest = $ManifestPath.Replace("\", "/")
    verdict = if ($orderedFindings.Count -eq 0) { "pass" } else { "fail" }
    artifacts = [object[]]@($artifactResults)
    findings = $orderedFindings
    summary = [pscustomobject][ordered]@{
        artifactCount = $artifactResults.Count
        pageCount = @($artifactResults | ForEach-Object { @($_.pages) }).Count
        renderablePageCount = @(
            $artifactResults | ForEach-Object { [int]$_.renderablePages }
        ) | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        findingCount = $orderedFindings.Count
    }
}

$result | ConvertTo-Json -Depth 20
if ($orderedFindings.Count -gt 0) {
    exit 2
}
