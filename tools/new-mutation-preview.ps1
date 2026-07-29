[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IntentPath,

    [string]$RootPath = (Join-Path $PSScriptRoot ".."),

    [string]$OutputPath,

    [switch]$AfterStateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

function Get-Sha256Text {
    param([AllowEmptyString()][Parameter(Mandatory = $true)][string]$Text)

    $encoding = New-Object System.Text.UTF8Encoding($false)
    $bytes = $encoding.GetBytes($Text)
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $algorithm.ComputeHash($bytes)
        return ([System.BitConverter]::ToString($hash) -replace "-", "").ToLowerInvariant()
    }
    finally {
        $algorithm.Dispose()
    }
}

function Get-Sha256File {
    param([Parameter(Mandatory = $true)][string]$Path)

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function ConvertTo-CanonicalValue {
    param([AllowNull()][object]$Value)

    if ($null -eq $Value) { return $null }
    if ($Value -is [string] -or
        $Value -is [char] -or
        $Value -is [bool] -or
        $Value -is [byte] -or
        $Value -is [sbyte] -or
        $Value -is [int16] -or
        $Value -is [uint16] -or
        $Value -is [int32] -or
        $Value -is [uint32] -or
        $Value -is [int64] -or
        $Value -is [uint64] -or
        $Value -is [single] -or
        $Value -is [double] -or
        $Value -is [decimal]) {
        return $Value
    }

    if ($Value -is [System.Collections.IDictionary]) {
        $keyNames = @($Value.Keys | ForEach-Object { [string]$_ })
        [System.Array]::Sort($keyNames, [System.StringComparer]::Ordinal)
        $result = [ordered]@{}
        foreach ($key in $keyNames) {
            $result[$key] = ConvertTo-CanonicalValue -Value $Value[$key]
        }
        return $result
    }

    if ($Value -is [pscustomobject]) {
        $propertyNames = @($Value.PSObject.Properties.Name)
        [System.Array]::Sort($propertyNames, [System.StringComparer]::Ordinal)
        $result = [ordered]@{}
        foreach ($propertyName in $propertyNames) {
            $result[$propertyName] = ConvertTo-CanonicalValue -Value $Value.$propertyName
        }
        return $result
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = New-Object System.Collections.Generic.List[object]
        foreach ($item in $Value) {
            $items.Add((ConvertTo-CanonicalValue -Value $item))
        }
        return ,$items.ToArray()
    }

    return [string]$Value
}

function ConvertTo-CanonicalJson {
    param([AllowNull()][object]$Value)

    $canonical = ConvertTo-CanonicalValue -Value $Value
    return (($canonical | ConvertTo-Json -Depth 100 -Compress) -replace "`r`n", "`n")
}

function Get-FullRoot {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Mutation preview root is not a directory: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Get-NormalizedContainedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw "Mutation preview paths must not be empty."
    }
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Mutation preview paths must be workspace-relative: $RelativePath"
    }

    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath))
    $prefix = $Root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase) -and
        -not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Mutation preview path escapes the workspace root: $RelativePath"
    }

    $ancestor = $fullPath
    while ($true) {
        if (Test-Path -LiteralPath $ancestor) {
            $ancestorItem = Get-Item -Force -LiteralPath $ancestor
            if (($ancestorItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Mutation preview rejects symbolic links and reparse points: $RelativePath"
            }
        }
        if ($ancestor.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
            break
        }
        $parent = [System.IO.Directory]::GetParent($ancestor)
        if ($null -eq $parent) {
            throw "Could not prove mutation preview path containment: $RelativePath"
        }
        $ancestor = $parent.FullName
    }

    $normalized = if ($fullPath.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        "."
    }
    else {
        $fullPath.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
    }
    return [pscustomobject]@{
        FullPath = $fullPath
        RelativePath = $normalized
    }
}

function Assert-NotReparsePoint {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileSystemInfo]$Item,
        [Parameter(Mandatory = $true)][string]$DisplayPath
    )

    if (($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Mutation preview rejects symbolic links and reparse points: $DisplayPath"
    }
}

function Get-PathSnapshot {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    $resolved = Get-NormalizedContainedPath -Root $Root -RelativePath $RelativePath
    if (-not (Test-Path -LiteralPath $resolved.FullPath)) {
        return [ordered]@{
            path = $resolved.RelativePath
            state = "absent"
            sha256 = Get-Sha256Text -Text "absent"
        }
    }

    $item = Get-Item -Force -LiteralPath $resolved.FullPath
    Assert-NotReparsePoint -Item $item -DisplayPath $resolved.RelativePath
    if (-not $item.PSIsContainer) {
        return [ordered]@{
            path = $resolved.RelativePath
            state = "file"
            sha256 = Get-Sha256File -Path $resolved.FullPath
        }
    }

    $entries = New-Object System.Collections.Generic.List[object]
    $descendantPaths = @(
        Get-ChildItem -Force -LiteralPath $resolved.FullPath -Recurse |
            ForEach-Object { $_.FullName }
    )
    [System.Array]::Sort($descendantPaths, [System.StringComparer]::Ordinal)
    foreach ($descendantPath in $descendantPaths) {
        $descendant = Get-Item -Force -LiteralPath $descendantPath
        $entryPath = $descendant.FullName.Substring($resolved.FullPath.Length).
            TrimStart([char[]]"\/").Replace("\", "/")
        Assert-NotReparsePoint -Item $descendant -DisplayPath "$($resolved.RelativePath)/$entryPath"
        if ($descendant.PSIsContainer) {
            $entries.Add([ordered]@{
                path = $entryPath
                state = "directory"
                sha256 = Get-Sha256Text -Text "directory"
            })
        }
        else {
            $entries.Add([ordered]@{
                path = $entryPath
                state = "file"
                sha256 = Get-Sha256File -Path $descendant.FullName
            })
        }
    }
    $entryArray = $entries.ToArray()
    $directoryHash = Get-Sha256Text -Text (ConvertTo-CanonicalJson -Value $entryArray)
    return [ordered]@{
        path = $resolved.RelativePath
        state = "directory"
        sha256 = $directoryHash
        entries = $entryArray
    }
}

function Get-NormalizedPathList {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [AllowEmptyCollection()][Parameter(Mandatory = $true)][object[]]$Paths,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $seen = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
    $normalizedPaths = New-Object System.Collections.Generic.List[string]
    foreach ($pathValue in $Paths) {
        $normalized = (Get-NormalizedContainedPath -Root $Root -RelativePath ([string]$pathValue)).RelativePath
        if (-not $seen.Add($normalized)) {
            throw "Mutation preview $Label contains a duplicate path: $normalized"
        }
        $normalizedPaths.Add($normalized)
    }
    $result = $normalizedPaths.ToArray()
    [System.Array]::Sort($result, [System.StringComparer]::Ordinal)
    return ,$result
}

$root = Get-FullRoot -Path $RootPath
$intentFullPath = if ([System.IO.Path]::IsPathRooted($IntentPath)) {
    [System.IO.Path]::GetFullPath($IntentPath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $IntentPath))
}
if (-not (Test-Path -LiteralPath $intentFullPath -PathType Leaf)) {
    throw "Missing mutation intent: $IntentPath"
}

$intent = Get-Content -Raw -LiteralPath $intentFullPath -Encoding UTF8 | ConvertFrom-Json
foreach ($requiredProperty in @(
    "schemaVersion",
    "intent",
    "sources",
    "targets",
    "changes",
    "expectedAfter",
    "negativeCompleteness"
)) {
    if (-not ($intent.PSObject.Properties.Name -contains $requiredProperty)) {
        throw "Mutation intent is missing required property '$requiredProperty'."
    }
}
if ([int]$intent.schemaVersion -ne 1) {
    throw "Mutation intent schemaVersion must be 1."
}
if ([string]::IsNullOrWhiteSpace([string]$intent.intent)) {
    throw "Mutation intent must describe the requested end state."
}

$sources = Get-NormalizedPathList -Root $root -Paths @($intent.sources) -Label "sources"
$targets = Get-NormalizedPathList -Root $root -Paths @($intent.targets) -Label "targets"
if ($targets.Count -eq 0) {
    throw "Mutation intent must declare at least one target path."
}
$changes = @($intent.changes)
if ($changes.Count -eq 0) {
    throw "Mutation intent must declare at least one change."
}
if ($intent.negativeCompleteness -isnot [pscustomobject] -or
    -not ($intent.negativeCompleteness.PSObject.Properties.Name -contains "schemaVersion") -or
    [int]$intent.negativeCompleteness.schemaVersion -ne 1) {
    throw "Mutation intent negativeCompleteness must be a complete schemaVersion 1 manifest."
}
$negativeCheckCount = 0
foreach ($checkFamily in @("exactPaths", "residualReferences", "gitIgnore")) {
    if ($intent.negativeCompleteness.PSObject.Properties.Name -contains $checkFamily) {
        $negativeCheckCount += @($intent.negativeCompleteness.$checkFamily).Count
    }
}
if ($negativeCheckCount -eq 0) {
    throw "Mutation intent negativeCompleteness must contain at least one end-state check."
}

$expectedAfterInput = @($intent.expectedAfter)
if ($expectedAfterInput.Count -eq 0) {
    throw "Mutation intent must declare expectedAfter for every target."
}
$expectedAfterMap = @{}
$expectedAfterList = New-Object System.Collections.Generic.List[object]
foreach ($expected in $expectedAfterInput) {
    foreach ($name in @("path", "state")) {
        if (-not ($expected.PSObject.Properties.Name -contains $name) -or
            [string]::IsNullOrWhiteSpace([string]$expected.$name)) {
            throw "Every expectedAfter entry requires non-empty path and state."
        }
    }
    $expectedPath = (Get-NormalizedContainedPath `
        -Root $root `
        -RelativePath ([string]$expected.path)).RelativePath
    if ($expectedAfterMap.ContainsKey($expectedPath)) {
        throw "Mutation intent expectedAfter repeats target '$expectedPath'."
    }
    if (@($targets) -notcontains $expectedPath) {
        throw "expectedAfter path '$expectedPath' must be declared in targets."
    }
    $expectedState = ([string]$expected.state).ToLowerInvariant()
    if ($expectedState -notin @("absent", "file", "directory")) {
        throw "expectedAfter path '$expectedPath' has unsupported state '$expectedState'."
    }
    $expectedSha = if ($expected.PSObject.Properties.Name -contains "sha256") {
        ([string]$expected.sha256).ToLowerInvariant()
    }
    else {
        ""
    }
    if ($expectedState -eq "absent") {
        if (-not [string]::IsNullOrWhiteSpace($expectedSha)) {
            throw "Absent expectedAfter path '$expectedPath' must not declare sha256."
        }
    }
    elseif ($expectedSha -cnotmatch "^[a-f0-9]{64}$") {
        throw "Present expectedAfter path '$expectedPath' requires a lowercase SHA-256."
    }
    $normalizedExpected = [ordered]@{
        path = $expectedPath
        state = $expectedState
        sha256 = $expectedSha
    }
    $expectedAfterMap[$expectedPath] = $normalizedExpected
    $expectedAfterList.Add($normalizedExpected)
}
foreach ($target in $targets) {
    if (-not $expectedAfterMap.ContainsKey($target)) {
        throw "Mutation target '$target' is missing expectedAfter."
    }
}
$normalizedExpectedAfter = @(
    $expectedAfterList.ToArray() |
        Sort-Object { $_.path }
)

$declaredPaths = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($path in @($sources) + @($targets)) { [void]$declaredPaths.Add($path) }
foreach ($change in $changes) {
    if (-not ($change.PSObject.Properties.Name -contains "operation") -or
        [string]::IsNullOrWhiteSpace([string]$change.operation)) {
        throw "Every declared change requires a non-empty operation."
    }
    foreach ($pathProperty in @("path", "from", "to", "source", "target")) {
        if ($change.PSObject.Properties.Name -contains $pathProperty) {
            $normalizedChangePath = (Get-NormalizedContainedPath `
                -Root $root `
                -RelativePath ([string]$change.$pathProperty)).RelativePath
            if (-not $declaredPaths.Contains($normalizedChangePath)) {
                throw "Change path '$normalizedChangePath' must be listed in sources or targets."
            }
        }
    }

    $operation = ([string]$change.operation).ToLowerInvariant()
    $contentOperations = @(
        "create",
        "update",
        "overwrite",
        "ignore-update",
        "generated-replace"
    )
    if ($operation -in $contentOperations) {
        if (-not ($change.PSObject.Properties.Name -contains "path")) {
            throw "Change operation '$operation' requires path."
        }
        $hasContentSource = $change.PSObject.Properties.Name -contains "contentSource"
        $hasProposedPatch = $change.PSObject.Properties.Name -contains "proposedPatch"
        if ($hasContentSource -eq $hasProposedPatch) {
            throw "Change operation '$operation' requires exactly one of contentSource or proposedPatch."
        }
        if ($hasContentSource) {
            $contentSourcePath = (Get-NormalizedContainedPath `
                -Root $root `
                -RelativePath ([string]$change.contentSource)).RelativePath
            if (@($sources) -notcontains $contentSourcePath) {
                throw "Change contentSource '$contentSourcePath' must be declared in sources."
            }
        }
        elseif ([string]::IsNullOrWhiteSpace([string]$change.proposedPatch)) {
            throw "Change proposedPatch must not be empty."
        }
    }
    elseif ($operation -eq "delete") {
        if (-not ($change.PSObject.Properties.Name -contains "path")) {
            throw "Delete change requires path."
        }
    }
    elseif ($operation -in @("move", "rename")) {
        if (-not ($change.PSObject.Properties.Name -contains "from") -or
            -not ($change.PSObject.Properties.Name -contains "to")) {
            throw "Change operation '$operation' requires from and to."
        }
    }
    else {
        throw "Unsupported mutation operation '$operation'."
    }
}

$intentProperties = [ordered]@{}
$intentPropertyNames = @($intent.PSObject.Properties.Name)
[System.Array]::Sort($intentPropertyNames, [System.StringComparer]::Ordinal)
foreach ($propertyName in $intentPropertyNames) {
    if ($propertyName -eq "sources") {
        $intentProperties[$propertyName] = @($sources)
    }
    elseif ($propertyName -eq "targets") {
        $intentProperties[$propertyName] = @($targets)
    }
    else {
        $intentProperties[$propertyName] = ConvertTo-CanonicalValue -Value $intent.$propertyName
    }
}
$canonicalIntent = ConvertTo-CanonicalValue -Value $intentProperties

$sourceSnapshots = @($sources | ForEach-Object { Get-PathSnapshot -Root $root -RelativePath $_ })
$targetSnapshots = @($targets | ForEach-Object { Get-PathSnapshot -Root $root -RelativePath $_ })
if (-not $AfterStateOnly) {
    foreach ($change in $changes) {
        $operation = ([string]$change.operation).ToLowerInvariant()
        $targetPath = if ($change.PSObject.Properties.Name -contains "path") {
            (Get-NormalizedContainedPath -Root $root -RelativePath ([string]$change.path)).RelativePath
        }
        elseif ($change.PSObject.Properties.Name -contains "to") {
            (Get-NormalizedContainedPath -Root $root -RelativePath ([string]$change.to)).RelativePath
        }
        else {
            ""
        }
        if (-not [string]::IsNullOrWhiteSpace($targetPath) -and
            -not $expectedAfterMap.ContainsKey($targetPath)) {
            throw "Change target '$targetPath' is missing expectedAfter."
        }

        if ($change.PSObject.Properties.Name -contains "contentSource") {
            $contentSourcePath = (Get-NormalizedContainedPath `
                -Root $root `
                -RelativePath ([string]$change.contentSource)).RelativePath
            $contentSnapshot = @(
                $sourceSnapshots |
                    Where-Object { $_.path -eq $contentSourcePath }
            )
            if ($contentSnapshot.Count -ne 1 -or $contentSnapshot[0].state -ne "file") {
                throw "Change contentSource '$contentSourcePath' must resolve to one regular file."
            }
            if ($expectedAfterMap[$targetPath].state -ne "file" -or
                $expectedAfterMap[$targetPath].sha256 -cne $contentSnapshot[0].sha256) {
                throw "expectedAfter for '$targetPath' must match contentSource '$contentSourcePath'."
            }
        }
        elseif ($operation -eq "delete") {
            if ($expectedAfterMap[$targetPath].state -ne "absent") {
                throw "Delete target '$targetPath' must have absent expectedAfter state."
            }
        }
        elseif ($operation -in @("move", "rename")) {
            $fromPath = (Get-NormalizedContainedPath `
                -Root $root `
                -RelativePath ([string]$change.from)).RelativePath
            $toPath = (Get-NormalizedContainedPath `
                -Root $root `
                -RelativePath ([string]$change.to)).RelativePath
            if (-not $expectedAfterMap.ContainsKey($fromPath) -or
                $expectedAfterMap[$fromPath].state -ne "absent") {
                throw "Move/rename source '$fromPath' must be a target with absent expectedAfter state."
            }
            $fromSnapshot = @(
                $sourceSnapshots |
                    Where-Object { $_.path -eq $fromPath }
            )
            if ($fromSnapshot.Count -ne 1 -or
                $fromSnapshot[0].state -eq "absent") {
                throw "Move/rename source '$fromPath' must exist in sources."
            }
            if (-not $expectedAfterMap.ContainsKey($toPath) -or
                $expectedAfterMap[$toPath].state -cne $fromSnapshot[0].state -or
                $expectedAfterMap[$toPath].sha256 -cne $fromSnapshot[0].sha256) {
                throw "Move/rename destination '$toPath' must preserve the confirmed source state and SHA-256."
            }
        }
    }
}
$intentHash = Get-Sha256Text -Text (ConvertTo-CanonicalJson -Value $canonicalIntent)
$sourcesHash = Get-Sha256Text -Text (ConvertTo-CanonicalJson -Value $sourceSnapshots)
$targetsHash = Get-Sha256Text -Text (ConvertTo-CanonicalJson -Value $targetSnapshots)
$expectedAfterHash = Get-Sha256Text -Text (
    ConvertTo-CanonicalJson -Value $normalizedExpectedAfter
)
$fingerprintInput = @(
    "schemaVersion=1"
    "intentSha256=$intentHash"
    "sourcesSha256=$sourcesHash"
    "targetsSha256=$targetsHash"
    "expectedAfterSha256=$expectedAfterHash"
) -join "`n"
$fingerprint = Get-Sha256Text -Text $fingerprintInput

$preview = [ordered]@{
    schemaVersion = 1
    algorithm = "SHA-256"
    changeIntent = $canonicalIntent
    snapshots = [ordered]@{
        sources = $sourceSnapshots
        targets = $targetSnapshots
    }
    expectedAfter = $normalizedExpectedAfter
    hashes = [ordered]@{
        intentSha256 = $intentHash
        sourcesSha256 = $sourcesHash
        targetsSha256 = $targetsHash
        expectedAfterSha256 = $expectedAfterHash
        fingerprint = $fingerprint
    }
}
$previewJson = (($preview | ConvertTo-Json -Depth 100) -replace "`r`n", "`n") + "`n"

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    Write-Output $previewJson
}
else {
    $outputFullPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        [System.IO.Path]::GetFullPath($OutputPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $OutputPath))
    }
    $outputDirectory = Split-Path -Parent $outputFullPath
    if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
        throw "Mutation preview output directory does not exist: $outputDirectory"
    }
    if (Test-Path -LiteralPath $outputFullPath) {
        throw "Refusing to overwrite an existing mutation preview: $outputFullPath"
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($outputFullPath, $previewJson, $utf8NoBom)
    Write-Host "OK mutation preview written: $outputFullPath"
    Write-Host "Fingerprint: $fingerprint"
}
