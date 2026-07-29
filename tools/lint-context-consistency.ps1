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

    if ($Object -isnot [pscustomobject]) {
        throw "$Purpose must be a JSON object."
    }
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

function New-OrdinalIgnoreCaseSet {
    $set = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::OrdinalIgnoreCase
    )
    Write-Output -NoEnumerate $set
}

function Get-ExplicitRoot {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or
        -not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Context consistency lint requires an explicit existing RootPath directory."
    }
    $item = Get-Item -Force -LiteralPath $Path
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Context consistency lint rejects a RootPath that is a symbolic link or reparse point."
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
        throw "Context consistency RootPath must be narrower than a filesystem volume root."
    }
    return $fullName
}

function Resolve-ContainedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Purpose
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
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "$Purpose must be an existing file: $RelativePath"
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

function Assert-NonEmptyString {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        throw "$Purpose must be a non-empty JSON string."
    }
}

function Assert-DeclaredScanPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$ScanPathSet,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    if (-not $ScanPathSet.Contains($Path)) {
        throw "$Purpose must also be declared in scanPaths: $Path"
    }
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)]$List,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()][Nullable[int]]$Line,
        [AllowNull()][string]$Subject,
        [Parameter(Mandatory = $true)][string]$Message
    )

    [void]$List.Add([pscustomobject][ordered]@{
        code = $Code
        path = $Path
        line = $Line
        subject = $Subject
        message = $Message
    })
}

function Get-Lines {
    param([AllowEmptyString()][Parameter(Mandatory = $true)][string]$Text)

    return [regex]::Split($Text, "\r\n|\n|\r")
}

function Split-MarkdownTableLine {
    param([AllowEmptyString()][Parameter(Mandatory = $true)][string]$Line)

    $trimmed = $Line.Trim()
    if (-not $trimmed.StartsWith("|") -or -not $trimmed.EndsWith("|")) {
        return @()
    }
    $inner = $trimmed.Substring(1, $trimmed.Length - 2)
    return @(
        [regex]::Split($inner, "(?<!\\)\|") |
            ForEach-Object { $_.Replace("\|", "|").Trim() }
    )
}

function Get-NormalizedHeader {
    param([Parameter(Mandatory = $true)][string]$Header)

    return [regex]::Replace($Header.ToLowerInvariant(), "[^a-z0-9]", "")
}

function Get-QuestionRecords {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Text
    )

    $records = New-Object System.Collections.ArrayList
    $lines = @(Get-Lines -Text $Text)
    for ($index = 0; $index -lt ($lines.Count - 1); $index++) {
        $headers = @(Split-MarkdownTableLine -Line $lines[$index])
        $separators = @(Split-MarkdownTableLine -Line $lines[$index + 1])
        if ($headers.Count -lt 2 -or $headers.Count -ne $separators.Count) {
            continue
        }
        $isSeparator = $true
        foreach ($separator in $separators) {
            if ($separator -notmatch "^:?-{3,}:?$") {
                $isSeparator = $false
                break
            }
        }
        if (-not $isSeparator) { continue }

        $normalizedHeaders = @($headers | ForEach-Object { Get-NormalizedHeader -Header $_ })
        $idIndex = [array]::IndexOf($normalizedHeaders, "id")
        $questionIndex = [array]::IndexOf($normalizedHeaders, "question")
        $statusIndex = [array]::IndexOf($normalizedHeaders, "status")
        if ($idIndex -lt 0 -or $questionIndex -lt 0 -or $statusIndex -lt 0) {
            continue
        }

        $rowIndex = $index + 2
        while ($rowIndex -lt $lines.Count) {
            $cells = @(Split-MarkdownTableLine -Line $lines[$rowIndex])
            if ($cells.Count -ne $headers.Count) { break }
            $id = [string]$cells[$idIndex]
            $question = [string]$cells[$questionIndex]
            $status = [string]$cells[$statusIndex]
            if (-not [string]::IsNullOrWhiteSpace($id)) {
                [void]$records.Add([pscustomobject]@{
                    id = $id.Trim()
                    question = $question.Trim()
                    status = $status.Trim()
                    path = $Path
                    line = $rowIndex + 1
                })
            }
            $rowIndex++
        }
        $index = $rowIndex - 1
    }
    return [object[]]$records
}

function Get-QuestionState {
    param([Parameter(Mandatory = $true)][string]$Status)

    $plain = [regex]::Replace($Status, '[`*_]', "").Trim().ToLowerInvariant()
    if ($plain -match "^open(?:\b|\s|[-:])") { return "open" }
    if ($plain -match "^(?:closed|resolved|superseded)(?:\b|\s|[-:])") { return "closed" }
    return "unknown"
}

function Get-FrontmatterAllowedFromProfile {
    param(
        [Parameter(Mandatory = $true)][string]$ProfilePath,
        [Parameter(Mandatory = $true)][string]$Text
    )

    $jsonText = $Text
    if ([System.IO.Path]::GetExtension($ProfilePath).Equals(
        ".md",
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        $matches = [regex]::Matches($Text, '(?ms)```json\s*(.*?)\s*```')
        if ($matches.Count -ne 1) {
            throw "Frontmatter profile '$ProfilePath' must contain exactly one fenced json block."
        }
        $jsonText = $matches[0].Groups[1].Value
    }
    elseif (-not [System.IO.Path]::GetExtension($ProfilePath).Equals(
        ".json",
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Frontmatter profile '$ProfilePath' must be .json or .md."
    }
    try {
        $profile = $jsonText | ConvertFrom-Json
    }
    catch {
        throw "Frontmatter profile '$ProfilePath' contains invalid JSON: $($_.Exception.Message)"
    }

    $bag = if (Test-ObjectProperty -Object $profile -Name "resolvedProfile") {
        $profile.resolvedProfile
    }
    elseif (Test-ObjectProperty -Object $profile -Name "values") {
        $profile.values
    }
    else {
        throw "Frontmatter profile '$ProfilePath' has neither resolvedProfile nor values."
    }
    if ($bag -isnot [pscustomobject] -or
        -not (Test-ObjectProperty -Object $bag -Name "format.frontmatter")) {
        throw "Frontmatter profile '$ProfilePath' does not resolve 'format.frontmatter'."
    }
    $allowed = $bag.PSObject.Properties["format.frontmatter"].Value
    if ($allowed -isnot [bool]) {
        throw "Frontmatter profile '$ProfilePath' value 'format.frontmatter' must be a JSON boolean."
    }
    return [bool]$allowed
}

function Test-HasYamlFrontmatter {
    param([Parameter(Mandatory = $true)][string]$Text)

    $withoutBom = $Text.TrimStart([char]0xFEFF)
    return $withoutBom -match "\A---(?:\r\n|\n|\r)"
}

function Get-LiteralMatchIndex {
    param(
        [AllowEmptyString()][Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Needle,
        [Parameter(Mandatory = $true)][bool]$CaseSensitive,
        [Parameter(Mandatory = $true)][string]$Match
    )

    $comparison = if ($CaseSensitive) {
        [System.StringComparison]::Ordinal
    }
    else {
        [System.StringComparison]::OrdinalIgnoreCase
    }
    if ($Match -ceq "exact") {
        if ($Value.Trim().Equals($Needle, $comparison)) { return 0 }
        return -1
    }
    return $Value.IndexOf($Needle, $comparison)
}

function Get-MojibakeIndex {
    param([AllowEmptyString()][Parameter(Mandatory = $true)][string]$Value)

    $continuationCodes = @(
        0x20AC, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6,
        0x2030, 0x0160, 0x2039, 0x0152, 0x017D, 0x2018, 0x2019, 0x201C,
        0x201D, 0x2022, 0x2013, 0x2014, 0x02DC, 0x2122, 0x0161, 0x203A,
        0x0153, 0x017E, 0x0178
    )
    for ($index = 0; $index -lt $Value.Length; $index++) {
        $code = [int][char]$Value[$index]
        if ($code -eq 0xFFFD) { return $index }
        if ($index -ge ($Value.Length - 1)) { continue }
        $next = [int][char]$Value[$index + 1]
        $looksLikeContinuation = ($next -ge 0x0080 -and $next -le 0x00BF) -or
            $continuationCodes -contains $next
        if ($code -ge 0x00C2 -and $code -le 0x00F4 -and $looksLikeContinuation) {
            return $index
        }
    }
    return -1
}

$root = Get-ExplicitRoot -Path $RootPath
$manifestFullPath = Resolve-ContainedPath -Root $root -RelativePath $ManifestPath `
    -Purpose "Context consistency manifest"
if (-not [System.IO.Path]::GetExtension($manifestFullPath).Equals(
    ".json",
    [System.StringComparison]::OrdinalIgnoreCase
)) {
    throw "Context consistency manifest must be an existing .json file."
}
$manifestText = Read-StrictUtf8 -Path $manifestFullPath -MaximumBytes 1048576 `
    -Purpose "Context consistency manifest"
try {
    $manifest = $manifestText | ConvertFrom-Json
}
catch {
    throw "Context consistency manifest contains invalid JSON: $($_.Exception.Message)"
}

$manifestProperties = @(
    "schemaVersion",
    "maxTextBytes",
    "scanPaths",
    "questionSources",
    "frontmatterPolicies",
    "terminologyRules",
    "decisions",
    "changelogStreams"
)
Assert-OnlyProperties -Object $manifest -Allowed $manifestProperties `
    -Purpose "Context consistency manifest"
Assert-RequiredProperties -Object $manifest -Required $manifestProperties `
    -Purpose "Context consistency manifest"
if ($manifest.schemaVersion -isnot [byte] -and
    $manifest.schemaVersion -isnot [int16] -and
    $manifest.schemaVersion -isnot [int32] -and
    $manifest.schemaVersion -isnot [int64]) {
    throw "Context consistency manifest schemaVersion must be JSON integer 1."
}
if ([int64]$manifest.schemaVersion -ne 1) {
    throw "Context consistency manifest schemaVersion must be 1."
}
$maxTextBytes = Get-PositiveInteger -Value $manifest.maxTextBytes `
    -Purpose "maxTextBytes" -Maximum 52428800

foreach ($arrayProperty in @(
    "scanPaths",
    "questionSources",
    "frontmatterPolicies",
    "terminologyRules",
    "decisions",
    "changelogStreams"
)) {
    Assert-JsonArray -Value $manifest.$arrayProperty -Purpose $arrayProperty
}
$scanPathValues = @($manifest.scanPaths)
if ($scanPathValues.Count -eq 0) {
    throw "Context consistency manifest must declare at least one exact scanPath."
}
$scanPathSet = New-OrdinalIgnoreCaseSet
$scanPaths = New-Object System.Collections.ArrayList
$texts = @{}
foreach ($pathValue in $scanPathValues) {
    Assert-NonEmptyString -Value $pathValue -Purpose "scanPaths entry"
    $path = [string]$pathValue
    $fullPath = Resolve-ContainedPath -Root $root -RelativePath $path -Purpose "scanPaths entry"
    if (-not $scanPathSet.Add($path)) {
        throw "Context consistency manifest contains duplicate scanPath '$path'."
    }
    [void]$scanPaths.Add($path)
    $texts[$path] = Read-StrictUtf8 -Path $fullPath -MaximumBytes $maxTextBytes `
        -Purpose "Context scan file '$path'"
}
$scanPaths = [object[]]@($scanPaths | Sort-Object)

$questionSources = @($manifest.questionSources)
$normalizedQuestionSources = New-Object System.Collections.ArrayList
$questionSourceSet = New-OrdinalIgnoreCaseSet
foreach ($sourceValue in $questionSources) {
    Assert-NonEmptyString -Value $sourceValue -Purpose "questionSources entry"
    $source = [string]$sourceValue
    Assert-DeclaredScanPath -Path $source -ScanPathSet $scanPathSet `
        -Purpose "questionSources entry"
    if (-not $questionSourceSet.Add($source)) {
        throw "Context consistency manifest contains duplicate question source '$source'."
    }
    [void]$normalizedQuestionSources.Add($source)
}

$frontmatterPolicies = @($manifest.frontmatterPolicies)
$normalizedFrontmatterPolicies = New-Object System.Collections.ArrayList
$frontmatterPathSet = New-OrdinalIgnoreCaseSet
for ($index = 0; $index -lt $frontmatterPolicies.Count; $index++) {
    $policy = $frontmatterPolicies[$index]
    $purpose = "frontmatterPolicies[$index]"
    Assert-OnlyProperties -Object $policy -Allowed @("path", "allowed", "profilePath") `
        -Purpose $purpose
    Assert-RequiredProperties -Object $policy -Required @("path") -Purpose $purpose
    Assert-NonEmptyString -Value $policy.path -Purpose "$purpose path"
    $path = [string]$policy.path
    Assert-DeclaredScanPath -Path $path -ScanPathSet $scanPathSet -Purpose "$purpose path"
    if (-not $frontmatterPathSet.Add($path)) {
        throw "Context consistency manifest contains duplicate frontmatter policy for '$path'."
    }
    $hasAllowed = Test-ObjectProperty -Object $policy -Name "allowed"
    $hasProfile = Test-ObjectProperty -Object $policy -Name "profilePath"
    if ($hasAllowed -eq $hasProfile) {
        throw "$purpose must contain exactly one of allowed or profilePath."
    }
    if ($hasAllowed) {
        if ($policy.allowed -isnot [bool]) {
            throw "$purpose allowed must be a JSON boolean."
        }
        [void]$normalizedFrontmatterPolicies.Add([pscustomobject]@{
            path = $path
            allowed = [bool]$policy.allowed
            profilePath = $null
        })
    }
    else {
        Assert-NonEmptyString -Value $policy.profilePath -Purpose "$purpose profilePath"
        $profilePath = [string]$policy.profilePath
        Assert-DeclaredScanPath -Path $profilePath -ScanPathSet $scanPathSet `
            -Purpose "$purpose profilePath"
        [void]$normalizedFrontmatterPolicies.Add([pscustomobject]@{
            path = $path
            allowed = $null
            profilePath = $profilePath
        })
    }
}

$terminologyRules = @($manifest.terminologyRules)
$normalizedTerminologyRules = New-Object System.Collections.ArrayList
for ($index = 0; $index -lt $terminologyRules.Count; $index++) {
    $rule = $terminologyRules[$index]
    $purpose = "terminologyRules[$index]"
    Assert-OnlyProperties -Object $rule `
        -Allowed @("stale", "replacement", "match", "caseSensitive", "paths") `
        -Purpose $purpose
    Assert-RequiredProperties -Object $rule `
        -Required @("stale", "replacement", "match", "caseSensitive", "paths") `
        -Purpose $purpose
    Assert-NonEmptyString -Value $rule.stale -Purpose "$purpose stale"
    Assert-NonEmptyString -Value $rule.replacement -Purpose "$purpose replacement"
    if ([string]$rule.stale -ceq [string]$rule.replacement) {
        throw "$purpose replacement must differ from stale text."
    }
    if ([string]$rule.match -cnotin @("exact", "substring")) {
        throw "$purpose match must be 'exact' or 'substring'."
    }
    if ($rule.caseSensitive -isnot [bool]) {
        throw "$purpose caseSensitive must be a JSON boolean."
    }
    Assert-JsonArray -Value $rule.paths -Purpose "$purpose paths"
    $rulePaths = @($rule.paths)
    if ($rulePaths.Count -eq 0) {
        throw "$purpose must declare at least one exact path."
    }
    $rulePathSet = New-OrdinalIgnoreCaseSet
    $normalizedRulePaths = New-Object System.Collections.ArrayList
    foreach ($rulePathValue in $rulePaths) {
        Assert-NonEmptyString -Value $rulePathValue -Purpose "$purpose paths entry"
        $rulePath = [string]$rulePathValue
        Assert-DeclaredScanPath -Path $rulePath -ScanPathSet $scanPathSet `
            -Purpose "$purpose paths entry"
        if (-not $rulePathSet.Add($rulePath)) {
            throw "$purpose contains duplicate path '$rulePath'."
        }
        [void]$normalizedRulePaths.Add($rulePath)
    }
    [void]$normalizedTerminologyRules.Add([pscustomobject]@{
        stale = [string]$rule.stale
        replacement = [string]$rule.replacement
        match = [string]$rule.match
        caseSensitive = [bool]$rule.caseSensitive
        paths = [object[]]@($normalizedRulePaths | Sort-Object)
    })
}

$decisionValues = @($manifest.decisions)
$decisions = New-Object System.Collections.ArrayList
$decisionIdSet = New-OrdinalIgnoreCaseSet
for ($index = 0; $index -lt $decisionValues.Count; $index++) {
    $decision = $decisionValues[$index]
    $purpose = "decisions[$index]"
    Assert-OnlyProperties -Object $decision `
        -Allowed @("id", "key", "value", "status", "source", "supersedes") `
        -Purpose $purpose
    Assert-RequiredProperties -Object $decision `
        -Required @("id", "key", "value", "status", "source", "supersedes") `
        -Purpose $purpose
    foreach ($name in @("id", "key", "value", "status", "source")) {
        Assert-NonEmptyString -Value $decision.$name -Purpose "$purpose $name"
    }
    if ([string]$decision.status -cnotin @("active", "superseded", "rejected")) {
        throw "$purpose status must be active, superseded, or rejected."
    }
    $source = [string]$decision.source
    Assert-DeclaredScanPath -Path $source -ScanPathSet $scanPathSet `
        -Purpose "$purpose source"
    if (-not $decisionIdSet.Add([string]$decision.id)) {
        throw "Context consistency manifest contains duplicate decision id '$($decision.id)'."
    }
    Assert-JsonArray -Value $decision.supersedes -Purpose "$purpose supersedes"
    $supersedesValues = @($decision.supersedes)
    $supersedesSet = New-OrdinalIgnoreCaseSet
    $supersedes = New-Object System.Collections.ArrayList
    foreach ($supersededValue in $supersedesValues) {
        Assert-NonEmptyString -Value $supersededValue -Purpose "$purpose supersedes entry"
        if ([string]$supersededValue -ieq [string]$decision.id) {
            throw "$purpose cannot supersede itself."
        }
        if (-not $supersedesSet.Add([string]$supersededValue)) {
            throw "$purpose contains duplicate supersedes id '$supersededValue'."
        }
        [void]$supersedes.Add([string]$supersededValue)
    }
    [void]$decisions.Add([pscustomobject]@{
        id = [string]$decision.id
        key = [string]$decision.key
        value = [regex]::Replace(([string]$decision.value).Trim(), "\s+", " ")
        status = [string]$decision.status
        source = $source
        supersedes = [object[]]$supersedes
    })
}

$streamValues = @($manifest.changelogStreams)
$streams = New-Object System.Collections.ArrayList
$streamIdSet = New-OrdinalIgnoreCaseSet
for ($streamIndex = 0; $streamIndex -lt $streamValues.Count; $streamIndex++) {
    $stream = $streamValues[$streamIndex]
    $purpose = "changelogStreams[$streamIndex]"
    Assert-OnlyProperties -Object $stream -Allowed @("id", "expectedHead", "entries") `
        -Purpose $purpose
    Assert-RequiredProperties -Object $stream -Required @("id", "expectedHead", "entries") `
        -Purpose $purpose
    Assert-NonEmptyString -Value $stream.id -Purpose "$purpose id"
    Assert-NonEmptyString -Value $stream.expectedHead -Purpose "$purpose expectedHead"
    if (-not $streamIdSet.Add([string]$stream.id)) {
        throw "Context consistency manifest contains duplicate changelog stream id '$($stream.id)'."
    }
    Assert-JsonArray -Value $stream.entries -Purpose "$purpose entries"
    $entryValues = @($stream.entries)
    if ($entryValues.Count -eq 0) {
        throw "$purpose must declare at least one changelog entry."
    }
    $entries = New-Object System.Collections.ArrayList
    for ($entryIndex = 0; $entryIndex -lt $entryValues.Count; $entryIndex++) {
        $entry = $entryValues[$entryIndex]
        $entryPurpose = "$purpose entries[$entryIndex]"
        Assert-OnlyProperties -Object $entry -Allowed @("version", "source", "previous") `
            -Purpose $entryPurpose
        Assert-RequiredProperties -Object $entry -Required @("version", "source", "previous") `
            -Purpose $entryPurpose
        Assert-NonEmptyString -Value $entry.version -Purpose "$entryPurpose version"
        Assert-NonEmptyString -Value $entry.source -Purpose "$entryPurpose source"
        if ($null -ne $entry.previous -and
            ($entry.previous -isnot [string] -or
                [string]::IsNullOrWhiteSpace([string]$entry.previous))) {
            throw "$entryPurpose previous must be null or a non-empty JSON string."
        }
        $entrySource = [string]$entry.source
        Assert-DeclaredScanPath -Path $entrySource -ScanPathSet $scanPathSet `
            -Purpose "$entryPurpose source"
        [void]$entries.Add([pscustomobject]@{
            version = [string]$entry.version
            source = $entrySource
            previous = if ($null -eq $entry.previous) { $null } else { [string]$entry.previous }
        })
    }
    [void]$streams.Add([pscustomobject]@{
        id = [string]$stream.id
        expectedHead = [string]$stream.expectedHead
        entries = [object[]]$entries
    })
}

$findings = New-Object System.Collections.ArrayList

# Detect common UTF-8 text decoded as Windows-1252/Latin-1, plus replacement characters.
foreach ($path in $scanPaths) {
    $lines = @(Get-Lines -Text ([string]$texts[[string]$path]))
    for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
        if ((Get-MojibakeIndex -Value $lines[$lineIndex]) -ge 0) {
            Add-Finding -List $findings -Code "MOJIBAKE_DETECTED" -Path ([string]$path) `
                -Line ($lineIndex + 1) -Subject $null `
                -Message "Text contains a likely UTF-8/Windows-1252 decoding artifact."
        }
    }
}

# Parse the existing Open Questions Memory table shape and compare duplicate IDs.
$questions = New-Object System.Collections.ArrayList
foreach ($source in @($normalizedQuestionSources | Sort-Object)) {
    $sourceRecords = @(
        Get-QuestionRecords -Path ([string]$source) -Text ([string]$texts[[string]$source])
    )
    if ($sourceRecords.Count -eq 0) {
        Add-Finding -List $findings -Code "QUESTION_SOURCE_EMPTY" -Path ([string]$source) `
            -Line $null -Subject $null `
            -Message "Declared question source contains no ID/Question/Status Markdown table rows."
    }
    foreach ($record in $sourceRecords) {
        $record | Add-Member -NotePropertyName state `
            -NotePropertyValue (Get-QuestionState -Status ([string]$record.status))
        [void]$questions.Add($record)
        if ($record.state -ceq "unknown") {
            Add-Finding -List $findings -Code "QUESTION_STATUS_UNKNOWN" `
                -Path ([string]$record.path) -Line ([int]$record.line) `
                -Subject ([string]$record.id) `
                -Message "Question status '$($record.status)' is neither open nor closed/resolved/superseded."
        }
    }
}
$questionsById = @{}
foreach ($question in $questions) {
    $key = ([string]$question.id).ToUpperInvariant()
    if (-not $questionsById.ContainsKey($key)) {
        $questionsById[$key] = New-Object System.Collections.ArrayList
    }
    [void]$questionsById[$key].Add($question)
}
foreach ($questionKey in @($questionsById.Keys | Sort-Object)) {
    $records = @($questionsById[$questionKey])
    $states = @($records | ForEach-Object { [string]$_.state } | Sort-Object -Unique)
    if ($states -contains "open" -and $states -contains "closed") {
        $orderedRecords = @($records | Sort-Object path, line)
        $locations = @(
            $orderedRecords | ForEach-Object { "$($_.path):$($_.line) [$($_.status)]" }
        ) -join "; "
        Add-Finding -List $findings -Code "QUESTION_STATE_CONFLICT" `
            -Path ([string]$orderedRecords[0].path) -Line ([int]$orderedRecords[0].line) `
            -Subject ([string]$orderedRecords[0].id) `
            -Message "Question is both open and closed across declared sources: $locations"
    }
}

# Resolve frontmatter policy from an explicit boolean or a declared resolved profile.
foreach ($policy in @($normalizedFrontmatterPolicies | Sort-Object path)) {
    $allowed = if ($null -ne $policy.profilePath) {
        Get-FrontmatterAllowedFromProfile -ProfilePath ([string]$policy.profilePath) `
            -Text ([string]$texts[[string]$policy.profilePath])
    }
    else {
        [bool]$policy.allowed
    }
    if (-not $allowed -and
        (Test-HasYamlFrontmatter -Text ([string]$texts[[string]$policy.path]))) {
        $authority = if ($null -ne $policy.profilePath) {
            "resolved profile '$($policy.profilePath)'"
        }
        else {
            "manifest policy"
        }
        Add-Finding -List $findings -Code "FRONTMATTER_FORBIDDEN" `
            -Path ([string]$policy.path) -Line 1 -Subject $null `
            -Message "YAML frontmatter is forbidden by $authority."
    }
}

# Enforce explicit literal terminology replacements only within each rule's exact paths.
foreach ($rule in $normalizedTerminologyRules) {
    foreach ($path in @($rule.paths)) {
        $lines = @(Get-Lines -Text ([string]$texts[[string]$path]))
        for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
            $matchIndex = Get-LiteralMatchIndex -Value $lines[$lineIndex] `
                -Needle ([string]$rule.stale) -CaseSensitive ([bool]$rule.caseSensitive) `
                -Match ([string]$rule.match)
            if ($matchIndex -ge 0) {
                Add-Finding -List $findings -Code "STALE_TERMINOLOGY" `
                    -Path ([string]$path) -Line ($lineIndex + 1) `
                    -Subject ([string]$rule.stale) `
                    -Message (
                        "Replace stale terminology '$($rule.stale)' with " +
                        "'$($rule.replacement)'."
                    )
            }
        }
    }
}

# Validate decision source evidence and flag incompatible active values for one key.
$decisionById = @{}
foreach ($decision in $decisions) {
    $decisionById[([string]$decision.id).ToUpperInvariant()] = $decision
    $decisionSourceText = [string]$texts[[string]$decision.source]
    $hasDecisionId = $decisionSourceText.IndexOf(
        [string]$decision.id,
        [System.StringComparison]::Ordinal
    ) -ge 0
    $hasDecisionValue = $decisionSourceText.IndexOf(
        [string]$decision.value,
        [System.StringComparison]::OrdinalIgnoreCase
    ) -ge 0
    if (-not $hasDecisionId -or -not $hasDecisionValue) {
        Add-Finding -List $findings -Code "DECISION_SOURCE_MISMATCH" `
            -Path ([string]$decision.source) -Line $null -Subject ([string]$decision.id) `
            -Message "Declared decision source does not contain both the decision ID and value."
    }
}
foreach ($decision in $decisions) {
    foreach ($supersededId in @($decision.supersedes)) {
        $supersededKey = ([string]$supersededId).ToUpperInvariant()
        if (([string]$texts[[string]$decision.source]).IndexOf(
            [string]$supersededId,
            [System.StringComparison]::Ordinal
        ) -lt 0) {
            Add-Finding -List $findings -Code "DECISION_SOURCE_MISMATCH" `
                -Path ([string]$decision.source) -Line $null -Subject ([string]$decision.id) `
                -Message "Decision source does not contain superseded ID '$supersededId'."
        }
        if (-not $decisionById.ContainsKey($supersededKey)) {
            Add-Finding -List $findings -Code "DECISION_SUPERSESSION_INVALID" `
                -Path ([string]$decision.source) -Line $null -Subject ([string]$decision.id) `
                -Message "Decision supersedes undeclared decision '$supersededId'."
            continue
        }
        $superseded = $decisionById[$supersededKey]
        if ([string]$decision.key -ine [string]$superseded.key -or
            [string]$superseded.status -cne "superseded" -or
            [string]$decision.status -cne "active") {
            Add-Finding -List $findings -Code "DECISION_SUPERSESSION_INVALID" `
                -Path ([string]$decision.source) -Line $null -Subject ([string]$decision.id) `
                -Message (
                    "Supersession '$($decision.id)' -> '$supersededId' requires the same key, " +
                    "an active replacement, and a superseded predecessor."
                )
        }
    }
}
$activeByKey = @{}
foreach ($decision in @($decisions | Where-Object { $_.status -ceq "active" })) {
    $key = ([string]$decision.key).ToUpperInvariant()
    if (-not $activeByKey.ContainsKey($key)) {
        $activeByKey[$key] = New-Object System.Collections.ArrayList
    }
    [void]$activeByKey[$key].Add($decision)
}
foreach ($key in @($activeByKey.Keys | Sort-Object)) {
    $active = @($activeByKey[$key] | Sort-Object id)
    $values = @($active | ForEach-Object { ([string]$_.value).ToUpperInvariant() } |
        Sort-Object -Unique)
    if ($values.Count -gt 1) {
        $claims = @($active | ForEach-Object { "$($_.id)='$($_.value)'" }) -join "; "
        Add-Finding -List $findings -Code "DECISION_CONFLICT_UNSUPERSEDED" `
            -Path ([string]$active[0].source) -Line $null -Subject ([string]$active[0].key) `
            -Message "Multiple active decisions make incompatible claims for one key: $claims"
    }
}

# Check an explicit, ordered changelog chain and its declared expected head.
foreach ($stream in @($streams | Sort-Object id)) {
    $entries = @($stream.entries)
    $seenVersions = New-OrdinalIgnoreCaseSet
    for ($entryIndex = 0; $entryIndex -lt $entries.Count; $entryIndex++) {
        $entry = $entries[$entryIndex]
        if (-not $seenVersions.Add([string]$entry.version)) {
            Add-Finding -List $findings -Code "CHANGELOG_CONTINUITY_GAP" `
                -Path ([string]$entry.source) -Line $null -Subject ([string]$stream.id) `
                -Message "Changelog contains duplicate version '$($entry.version)'."
        }
        $expectedPrevious = if ($entryIndex -eq 0) {
            $null
        }
        else {
            [string]$entries[$entryIndex - 1].version
        }
        $previousMatches = if ($null -eq $expectedPrevious) {
            $null -eq $entry.previous
        }
        else {
            $null -ne $entry.previous -and
                [string]$entry.previous -ceq $expectedPrevious
        }
        if (-not $previousMatches) {
            $actualPrevious = if ($null -eq $entry.previous) { "<null>" } else { $entry.previous }
            $expectedText = if ($null -eq $expectedPrevious) { "<null>" } else { $expectedPrevious }
            Add-Finding -List $findings -Code "CHANGELOG_CONTINUITY_GAP" `
                -Path ([string]$entry.source) -Line $null -Subject ([string]$stream.id) `
                -Message (
                    "Version '$($entry.version)' declares previous '$actualPrevious'; " +
                    "the ordered chain requires '$expectedText'."
                )
        }
        if (([string]$texts[[string]$entry.source]).IndexOf(
            [string]$entry.version,
            [System.StringComparison]::OrdinalIgnoreCase
        ) -lt 0) {
            Add-Finding -List $findings -Code "CHANGELOG_VERSION_NOT_FOUND" `
                -Path ([string]$entry.source) -Line $null -Subject ([string]$stream.id) `
                -Message "Changelog source does not contain declared version '$($entry.version)'."
        }
    }
    if ([string]$entries[-1].version -cne [string]$stream.expectedHead) {
        Add-Finding -List $findings -Code "CHANGELOG_CONTINUITY_GAP" `
            -Path ([string]$entries[-1].source) -Line $null -Subject ([string]$stream.id) `
            -Message (
                "Declared changelog head '$($entries[-1].version)' does not match " +
                "expectedHead '$($stream.expectedHead)'."
            )
    }
}

$orderedFindings = [object[]]@(
    $findings |
        Sort-Object code, path, line, subject, message
)
$result = [pscustomobject][ordered]@{
    schemaVersion = 1
    validator = "annifity-context-consistency"
    manifest = $ManifestPath.Replace("\", "/")
    verdict = if ($orderedFindings.Count -eq 0) { "pass" } else { "fail" }
    checkedPaths = [object[]]$scanPaths
    findings = $orderedFindings
    summary = [pscustomobject][ordered]@{
        checkedPathCount = $scanPaths.Count
        questionRecordCount = $questions.Count
        decisionRecordCount = $decisions.Count
        changelogStreamCount = $streams.Count
        findingCount = $orderedFindings.Count
    }
}

$result | ConvertTo-Json -Depth 20
if ($orderedFindings.Count -gt 0) {
    exit 2
}
