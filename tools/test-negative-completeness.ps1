[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ManifestPath,

    [string]$RootPath = (Join-Path $PSScriptRoot "..")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FullRoot {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Negative-completeness root is not a directory: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Resolve-ContainedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw "Negative-completeness paths must not be empty."
    }
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Negative-completeness paths must be workspace-relative: $RelativePath"
    }

    $candidate = [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath))
    $prefix = $Root + [System.IO.Path]::DirectorySeparatorChar
    if (-not $candidate.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase) -and
        -not $candidate.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Negative-completeness path escapes the workspace root: $RelativePath"
    }

    $ancestor = $candidate
    while ($true) {
        if (Test-Path -LiteralPath $ancestor) {
            $ancestorItem = Get-Item -Force -LiteralPath $ancestor
            if (($ancestorItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Negative-completeness checks reject symbolic links and reparse points: $RelativePath"
            }
        }
        if ($ancestor.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
            break
        }
        $parent = [System.IO.Directory]::GetParent($ancestor)
        if ($null -eq $parent) {
            throw "Could not prove negative-completeness path containment: $RelativePath"
        }
        $ancestor = $parent.FullName
    }
    return $candidate
}

function ConvertTo-RelativeSlashPath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$FullPath
    )

    if ($FullPath.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "."
    }
    return $FullPath.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
}

function Test-WildcardSet {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][object[]]$Patterns,
        [switch]$CaseSensitive
    )

    foreach ($patternValue in $Patterns) {
        $pattern = ([string]$patternValue).Replace("\", "/")
        if ($CaseSensitive) {
            if ($Value -clike $pattern) { return $true }
        }
        elseif ($Value -like $pattern) {
            return $true
        }
    }
    return $false
}

function Get-OptionalArray {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($Object.PSObject.Properties.Name -contains $Name) {
        return @($Object.$Name)
    }
    return @()
}

$root = Get-FullRoot -Path $RootPath
$manifestFullPath = if ([System.IO.Path]::IsPathRooted($ManifestPath)) {
    [System.IO.Path]::GetFullPath($ManifestPath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $ManifestPath))
}
if (-not (Test-Path -LiteralPath $manifestFullPath -PathType Leaf)) {
    throw "Missing negative-completeness manifest: $ManifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $manifestFullPath -Encoding UTF8 | ConvertFrom-Json
if (-not ($manifest.PSObject.Properties.Name -contains "schemaVersion") -or
    [int]$manifest.schemaVersion -ne 1) {
    throw "Negative-completeness manifest schemaVersion must be 1."
}
$declaredCheckCount = 0
foreach ($family in @("exactPaths", "residualReferences", "gitIgnore")) {
    $declaredCheckCount += @(Get-OptionalArray -Object $manifest -Name $family).Count
}
if ($declaredCheckCount -eq 0) {
    throw "Negative-completeness manifest must contain at least one check."
}

$failures = New-Object System.Collections.Generic.List[string]
$evidence = New-Object System.Collections.Generic.List[string]

foreach ($check in (Get-OptionalArray -Object $manifest -Name "exactPaths")) {
    if (-not ($check.PSObject.Properties.Name -contains "path") -or
        -not ($check.PSObject.Properties.Name -contains "expected")) {
        $failures.Add("Exact-path checks require path and expected.")
        continue
    }

    $relativePath = ([string]$check.path).Replace("\", "/")
    $fullPath = Resolve-ContainedPath -Root $root -RelativePath $relativePath
    $expected = ([string]$check.expected).ToLowerInvariant()
    $kind = if ($check.PSObject.Properties.Name -contains "kind") {
        ([string]$check.kind).ToLowerInvariant()
    }
    else {
        "any"
    }
    if ($expected -notin @("present", "absent")) {
        $failures.Add("Exact path '$relativePath' has unsupported expected value '$expected'.")
        continue
    }
    if ($kind -notin @("any", "file", "directory")) {
        $failures.Add("Exact path '$relativePath' has unsupported kind '$kind'.")
        continue
    }

    $exists = Test-Path -LiteralPath $fullPath
    $kindMatches = $exists -and (
        $kind -eq "any" -or
        ($kind -eq "file" -and (Test-Path -LiteralPath $fullPath -PathType Leaf)) -or
        ($kind -eq "directory" -and (Test-Path -LiteralPath $fullPath -PathType Container))
    )

    if ($expected -eq "absent" -and -not $exists) {
        $evidence.Add("PASS exact absent: $relativePath")
    }
    elseif ($expected -eq "present" -and $kindMatches) {
        $evidence.Add("PASS exact present ($kind): $relativePath")
    }
    elseif ($expected -eq "absent") {
        $failures.Add("Expected exact path to be absent: $relativePath")
    }
    elseif (-not $exists) {
        $failures.Add("Expected exact path to be present: $relativePath")
    }
    else {
        $failures.Add("Expected exact path '$relativePath' to have kind '$kind'.")
    }
}

foreach ($check in (Get-OptionalArray -Object $manifest -Name "residualReferences")) {
    if (-not ($check.PSObject.Properties.Name -contains "pattern") -or
        -not ($check.PSObject.Properties.Name -contains "expected")) {
        $failures.Add("Residual-reference checks require pattern and expected.")
        continue
    }

    $patternText = [string]$check.pattern
    $expected = ([string]$check.expected).ToLowerInvariant()
    if ($expected -notin @("present", "absent")) {
        $failures.Add("Residual pattern '$patternText' has unsupported expected value '$expected'.")
        continue
    }

    $caseSensitive = ($check.PSObject.Properties.Name -contains "caseSensitive") -and
        [bool]$check.caseSensitive
    $fixedString = ($check.PSObject.Properties.Name -contains "fixedString") -and
        [bool]$check.fixedString
    $regexPattern = if ($fixedString) { [regex]::Escape($patternText) } else { $patternText }
    $regexOptions = if ($caseSensitive) {
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    }
    else {
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    }
    try {
        $regex = New-Object System.Text.RegularExpressions.Regex($regexPattern, $regexOptions)
    }
    catch {
        $failures.Add("Residual pattern is not a valid regular expression: $patternText")
        continue
    }

    $searchPaths = @(Get-OptionalArray -Object $check -Name "searchPaths")
    if ($searchPaths.Count -eq 0) {
        $failures.Add("Residual pattern '$patternText' must declare bounded searchPaths.")
        continue
    }
    $includeGlobs = @(Get-OptionalArray -Object $check -Name "includeGlobs")
    if ($includeGlobs.Count -eq 0) { $includeGlobs = @("*") }
    $excludePaths = @(Get-OptionalArray -Object $check -Name "excludePaths")

    $candidateFiles = New-Object System.Collections.Generic.List[string]
    foreach ($searchPathValue in $searchPaths) {
        $searchPath = ([string]$searchPathValue).Replace("\", "/")
        $fullSearchPath = Resolve-ContainedPath -Root $root -RelativePath $searchPath
        if (-not (Test-Path -LiteralPath $fullSearchPath)) {
            $failures.Add("Residual search path does not exist: $searchPath")
            continue
        }
        if (Test-Path -LiteralPath $fullSearchPath -PathType Leaf) {
            $candidateFiles.Add($fullSearchPath)
        }
        else {
            foreach ($file in (Get-ChildItem -LiteralPath $fullSearchPath -Recurse -Force -File |
                Sort-Object FullName)) {
                $candidateFiles.Add($file.FullName)
            }
        }
    }

    $matches = New-Object System.Collections.Generic.List[string]
    $candidatePathSet = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($candidateFile in $candidateFiles) {
        [void]$candidatePathSet.Add($candidateFile)
    }
    $candidatePathArray = @($candidatePathSet)
    [System.Array]::Sort($candidatePathArray, [System.StringComparer]::Ordinal)
    foreach ($filePath in $candidatePathArray) {
        $relativeFile = ConvertTo-RelativeSlashPath -Root $root -FullPath $filePath
        if ($relativeFile -eq ".git" -or $relativeFile.StartsWith(".git/")) { continue }
        if (-not (Test-WildcardSet -Value $relativeFile -Patterns $includeGlobs -CaseSensitive:$caseSensitive)) {
            continue
        }
        if ($excludePaths.Count -gt 0 -and
            (Test-WildcardSet -Value $relativeFile -Patterns $excludePaths -CaseSensitive:$caseSensitive)) {
            continue
        }

        try {
            $lines = [System.IO.File]::ReadAllLines($filePath)
        }
        catch {
            $failures.Add("Could not read residual search file: $relativeFile")
            continue
        }
        for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
            if ($regex.IsMatch($lines[$lineIndex])) {
                $matches.Add(("{0}:{1}" -f $relativeFile, ($lineIndex + 1)))
            }
        }
    }

    $minimum = if ($check.PSObject.Properties.Name -contains "minimumMatches") {
        [int]$check.minimumMatches
    }
    elseif ($expected -eq "present") {
        1
    }
    else {
        0
    }
    $maximum = if ($check.PSObject.Properties.Name -contains "maximumMatches") {
        [int]$check.maximumMatches
    }
    elseif ($expected -eq "absent") {
        0
    }
    else {
        [int]::MaxValue
    }
    if ($minimum -lt 0 -or $maximum -lt 0 -or $minimum -gt $maximum) {
        $failures.Add("Residual pattern '$patternText' has an invalid match range $minimum..$maximum.")
        continue
    }
    if ($expected -eq "absent" -and ($minimum -ne 0 -or $maximum -ne 0)) {
        $failures.Add("Residual pattern '$patternText' expected absent must require exactly 0 matches.")
        continue
    }
    if ($expected -eq "present" -and $minimum -lt 1) {
        $failures.Add("Residual pattern '$patternText' expected present must require at least 1 match.")
        continue
    }

    if ($matches.Count -ge $minimum -and $matches.Count -le $maximum) {
        $locationText = if ($matches.Count -gt 0) { $matches -join ", " } else { "no matches" }
        $evidence.Add("PASS residual $expected '$patternText': $($matches.Count) matching line(s) [$locationText]")
    }
    else {
        $locationText = if ($matches.Count -gt 0) { $matches -join ", " } else { "no matches" }
        $failures.Add(
            "Residual pattern '$patternText' expected $minimum..$maximum matching line(s), found $($matches.Count) [$locationText]"
        )
    }
}

$gitChecks = @(Get-OptionalArray -Object $manifest -Name "gitIgnore")
if ($gitChecks.Count -gt 0 -and -not (Get-Command git -ErrorAction SilentlyContinue)) {
    $failures.Add("Git is required for git-ignore evidence but was not found.")
}
else {
    foreach ($check in $gitChecks) {
        if (-not ($check.PSObject.Properties.Name -contains "path") -or
            -not ($check.PSObject.Properties.Name -contains "expected")) {
            $failures.Add("Git-ignore checks require path and expected.")
            continue
        }
        $relativePath = ([string]$check.path).Replace("\", "/")
        [void](Resolve-ContainedPath -Root $root -RelativePath $relativePath)
        $expected = ([string]$check.expected).ToLowerInvariant()
        if ($expected -notin @("ignored", "not-ignored")) {
            $failures.Add("Git-ignore path '$relativePath' has unsupported expected value '$expected'.")
            continue
        }

        $gitOutput = @(& git -C $root check-ignore --no-index -v -- $relativePath 2>&1)
        $gitExitCode = $LASTEXITCODE
        $global:LASTEXITCODE = 0
        if ($gitExitCode -eq 0) {
            $ruleEvidence = (($gitOutput | ForEach-Object { [string]$_ }) -join " ").Trim()
            if ($expected -eq "ignored") {
                $evidence.Add("PASS git ignored: $relativePath [$ruleEvidence]")
            }
            else {
                $failures.Add("Expected path not to be ignored: $relativePath [$ruleEvidence]")
            }
        }
        elseif ($gitExitCode -eq 1) {
            if ($expected -eq "not-ignored") {
                $evidence.Add("PASS git not-ignored: $relativePath")
            }
            else {
                $failures.Add("Expected path to be ignored, but no matching rule was found: $relativePath")
            }
        }
        else {
            $errorEvidence = (($gitOutput | ForEach-Object { [string]$_ }) -join " ").Trim()
            $failures.Add("Could not obtain git-ignore evidence for '$relativePath' (exit $gitExitCode): $errorEvidence")
        }
    }
}

if ($failures.Count -gt 0) {
    $message = "Negative completeness failed:`n - " + ($failures -join "`n - ")
    throw $message
}

foreach ($item in $evidence) {
    Write-Host $item
}
Write-Host "OK negative completeness passed ($($evidence.Count) check(s))."
