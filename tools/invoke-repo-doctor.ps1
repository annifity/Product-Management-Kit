[CmdletBinding()]
param(
    [string]$RootPath,
    [string]$ManifestPath,
    [switch]$FailOnFinding
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RootPath)) {
    $RootPath = Join-Path $PSScriptRoot ".."
}
if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
    $ManifestPath = Join-Path $PSScriptRoot "repo-root-manifest.json"
}

function Test-ObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object.PSObject.Properties[$Name]
}

function Assert-KnownProperties {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Names,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($property in @($Object.PSObject.Properties)) {
        if ($Names -notcontains [string]$property.Name) {
            throw "$Context contains unsupported property '$($property.Name)'."
        }
    }
}

function Get-RequiredString {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required property '$Name'."
    }
    $value = [string]$Object.$Name
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "$Context property '$Name' must be a non-empty string."
    }
    return $value.Trim()
}

function Get-Array {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required property '$Name'."
    }
    if ($null -eq $Object.$Name -or $Object.$Name -is [string]) {
        throw "$Context property '$Name' must be a JSON array."
    }
    return @($Object.$Name)
}

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$BasePath
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $Path))
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowNonZero
    )

    $output = @(& git -C $Root @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    $global:LASTEXITCODE = 0
    if (-not $AllowNonZero -and $exitCode -ne 0) {
        throw "Git command failed ($exitCode): git -C <root> $($Arguments -join ' ')`n$($output -join "`n")"
    }
    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = [string[]]@($output | ForEach-Object { [string]$_ })
    }
}

function Get-GitState {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$GitPolicy,
        [Parameter(Mandatory = $true)][hashtable]$TrackedCountByRoot,
        [Parameter(Mandatory = $true)][hashtable]$IgnoreRuleByRoot
    )

    if ($GitPolicy -eq "internal") {
        return [ordered]@{
            actual = "internal"
            trackedFileCount = 0
            ignored = $false
            ignoreRule = $null
        }
    }

    $trackedFileCount = if ($TrackedCountByRoot.ContainsKey($RelativePath)) {
        [int]$TrackedCountByRoot[$RelativePath]
    }
    else {
        0
    }
    $ignored = $IgnoreRuleByRoot.ContainsKey($RelativePath)
    $actual = if ($trackedFileCount -gt 0 -and $ignored) {
        "tracked-and-ignored"
    }
    elseif ($trackedFileCount -gt 0) {
        "tracked"
    }
    elseif ($ignored) {
        "ignored"
    }
    else {
        "untracked"
    }
    $ignoreRule = if ($ignored) {
        [string]$IgnoreRuleByRoot[$RelativePath]
    }
    else {
        $null
    }

    return [ordered]@{
        actual = $actual
        trackedFileCount = $trackedFileCount
        ignored = $ignored
        ignoreRule = $ignoreRule
    }
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $Findings.Add([ordered]@{
        code = $Code
        path = $Path.Replace("\", "/")
        message = $Message
    })
}

$rootFullPath = Resolve-FullPath -Path $RootPath -BasePath (Get-Location).Path
if (-not (Test-Path -LiteralPath $rootFullPath -PathType Container)) {
    throw "Repository doctor root is not a directory: $RootPath"
}
$rootFullPath = (Resolve-Path -LiteralPath $rootFullPath).Path

$manifestFullPath = Resolve-FullPath -Path $ManifestPath -BasePath (Get-Location).Path
if (-not (Test-Path -LiteralPath $manifestFullPath -PathType Leaf)) {
    throw "Repository root manifest does not exist: $ManifestPath"
}

try {
    $manifest = Get-Content -Raw -LiteralPath $manifestFullPath -Encoding UTF8 |
        ConvertFrom-Json
}
catch {
    throw "Repository root manifest is not valid JSON: $($_.Exception.Message)"
}
if ($null -eq $manifest -or $manifest -is [string]) {
    throw "Repository root manifest must be a JSON object."
}
Assert-KnownProperties `
    -Object $manifest `
    -Names @(
        '$schema',
        "schemaVersion",
        "allowedRoots",
        "forbiddenPaths",
        "runtimeNamePatterns"
    ) `
    -Context "Repository root manifest"

$schemaReference = Get-RequiredString `
    -Object $manifest `
    -Name '$schema' `
    -Context "Repository root manifest"
if ($schemaReference -cne "./repo-root-manifest.schema.json") {
    throw "Repository root manifest `$schema must be './repo-root-manifest.schema.json'."
}
$schemaVersion = Get-RequiredString `
    -Object $manifest `
    -Name "schemaVersion" `
    -Context "Repository root manifest"
if ($schemaVersion -cne "1.0") {
    throw "Repository root manifest schemaVersion must be '1.0'."
}

$schemaFullPath = Resolve-FullPath `
    -Path $schemaReference `
    -BasePath (Split-Path -Parent $manifestFullPath)
if (-not (Test-Path -LiteralPath $schemaFullPath -PathType Leaf)) {
    throw "Repository root manifest schema does not exist: $schemaFullPath"
}
try {
    $schemaDocument = Get-Content -Raw -LiteralPath $schemaFullPath -Encoding UTF8 |
        ConvertFrom-Json
}
catch {
    throw "Repository root manifest schema is not valid JSON: $($_.Exception.Message)"
}
if ([string]$schemaDocument.'$id' -cne "urn:annifity:repo-root-manifest:1.0") {
    throw "Repository root manifest schema has an unexpected `$id."
}

$gitRootResult = Invoke-Git `
    -Root $rootFullPath `
    -Arguments @("rev-parse", "--show-toplevel")
if ($gitRootResult.Output.Count -ne 1) {
    throw "Could not determine one Git repository root for the doctor target."
}
$gitRoot = [System.IO.Path]::GetFullPath($gitRootResult.Output[0]).TrimEnd([char[]]"\/")
$normalizedRoot = $rootFullPath.TrimEnd([char[]]"\/")
if (-not $gitRoot.Equals($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Repository doctor must run against the exact Git root, not a nested directory."
}

$allowedItems = Get-Array `
    -Object $manifest `
    -Name "allowedRoots" `
    -Context "Repository root manifest"
if ($allowedItems.Count -eq 0) {
    throw "Repository root manifest must allow at least one root directory."
}
$allowedByPath = @{}
$normalizedAllowed = [System.Collections.Generic.List[object]]::new()
foreach ($item in $allowedItems) {
    if ($null -eq $item -or $item -is [string]) {
        throw "allowedRoots entries must be JSON objects."
    }
    Assert-KnownProperties `
        -Object $item `
        -Names @("path", "kind", "gitPolicy", "required", "explanation") `
        -Context "allowedRoots item"
    $path = Get-RequiredString -Object $item -Name "path" -Context "allowedRoots item"
    if ($path -match "[/\\]" -or $path -in @(".", "..")) {
        throw "Allowed root '$path' must be one repository-root directory name."
    }
    if ($allowedByPath.ContainsKey($path)) {
        throw "allowedRoots contains duplicate path '$path'."
    }
    $kind = Get-RequiredString -Object $item -Name "kind" -Context "allowedRoots '$path'"
    if ($kind -cnotin @("canonical", "generated", "integration", "runtime", "internal")) {
        throw "allowedRoots '$path' has unsupported kind '$kind'."
    }
    $gitPolicy = Get-RequiredString `
        -Object $item `
        -Name "gitPolicy" `
        -Context "allowedRoots '$path'"
    if ($gitPolicy -cnotin @("tracked", "ignored", "runtime-local", "internal")) {
        throw "allowedRoots '$path' has unsupported gitPolicy '$gitPolicy'."
    }
    if (-not (Test-ObjectProperty -Object $item -Name "required") -or
        $item.required -isnot [bool]) {
        throw "allowedRoots '$path' required must be a JSON boolean."
    }
    $explanation = Get-RequiredString `
        -Object $item `
        -Name "explanation" `
        -Context "allowedRoots '$path'"
    $normalized = [ordered]@{
        path = $path
        kind = $kind
        gitPolicy = $gitPolicy
        required = [bool]$item.required
        explanation = $explanation
    }
    $allowedByPath[$path] = $normalized
    $normalizedAllowed.Add($normalized)
}

$forbiddenItems = Get-Array `
    -Object $manifest `
    -Name "forbiddenPaths" `
    -Context "Repository root manifest"
$forbiddenSeen = @{}
$normalizedForbidden = [System.Collections.Generic.List[object]]::new()
foreach ($item in $forbiddenItems) {
    if ($null -eq $item -or $item -is [string]) {
        throw "forbiddenPaths entries must be JSON objects."
    }
    Assert-KnownProperties `
        -Object $item `
        -Names @("path", "code", "explanation") `
        -Context "forbiddenPaths item"
    $path = (Get-RequiredString `
        -Object $item `
        -Name "path" `
        -Context "forbiddenPaths item").Replace("\", "/")
    if ([System.IO.Path]::IsPathRooted($path) -or
        $path -match "(^|/)\.\.($|/)" -or
        $path -match "//") {
        throw "Forbidden path '$path' must be normalized and repository-relative."
    }
    if ($forbiddenSeen.ContainsKey($path)) {
        throw "forbiddenPaths contains duplicate path '$path'."
    }
    $code = Get-RequiredString -Object $item -Name "code" -Context "forbiddenPaths '$path'"
    if ($code -cnotmatch "^[A-Z][A-Z0-9_]+$") {
        throw "forbiddenPaths '$path' code must use uppercase underscore form."
    }
    $explanation = Get-RequiredString `
        -Object $item `
        -Name "explanation" `
        -Context "forbiddenPaths '$path'"
    $normalized = [ordered]@{
        path = $path
        code = $code
        explanation = $explanation
    }
    $forbiddenSeen[$path] = $normalized
    $normalizedForbidden.Add($normalized)
}

$runtimePatterns = [System.Collections.Generic.List[regex]]::new()
foreach ($patternValue in @(
    Get-Array `
        -Object $manifest `
        -Name "runtimeNamePatterns" `
        -Context "Repository root manifest"
)) {
    $pattern = [string]$patternValue
    if ([string]::IsNullOrWhiteSpace($pattern)) {
        throw "runtimeNamePatterns contains an empty pattern."
    }
    try {
        $runtimePatterns.Add([regex]::new(
            $pattern,
            [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
        ))
    }
    catch {
        throw "Invalid runtimeNamePatterns regex '$pattern': $($_.Exception.Message)"
    }
}

$trackedCountByRoot = @{}
$trackedInventory = Invoke-Git -Root $rootFullPath -Arguments @("ls-files")
foreach ($trackedPathValue in $trackedInventory.Output) {
    $trackedPath = ([string]$trackedPathValue).Replace("\", "/")
    if ([string]::IsNullOrWhiteSpace($trackedPath)) {
        continue
    }
    $trackedRoot = ($trackedPath -split "/", 2)[0]
    if (-not $trackedCountByRoot.ContainsKey($trackedRoot)) {
        $trackedCountByRoot[$trackedRoot] = 0
    }
    $trackedCountByRoot[$trackedRoot] = [int]$trackedCountByRoot[$trackedRoot] + 1
}

$ignoreRuleByRoot = @{}
$ignoreProbePaths = @(
    $normalizedAllowed |
        Where-Object { $_.gitPolicy -ne "internal" } |
        ForEach-Object { [string]$_.path } |
        Sort-Object
)
if ($ignoreProbePaths.Count -gt 0) {
    $ignoreArguments = @("check-ignore", "--no-index", "-v", "--") + $ignoreProbePaths
    $ignoreInventory = Invoke-Git `
        -Root $rootFullPath `
        -Arguments $ignoreArguments `
        -AllowNonZero
    foreach ($ignoreLineValue in $ignoreInventory.Output) {
        $ignoreLine = [string]$ignoreLineValue
        $tabIndex = $ignoreLine.LastIndexOf("`t", [System.StringComparison]::Ordinal)
        if ($tabIndex -lt 0 -or $tabIndex -ge ($ignoreLine.Length - 1)) {
            continue
        }
        $ignoredPath = $ignoreLine.Substring($tabIndex + 1).Replace("\", "/")
        $ignoreRuleByRoot[$ignoredPath] = $ignoreLine
    }
}

$findings = [System.Collections.Generic.List[object]]::new()
$rootReports = [System.Collections.Generic.List[object]]::new()
foreach ($allowed in @(
    $normalizedAllowed | Sort-Object @{ Expression = { [string]$_.path } }
)) {
    $relativePath = [string]$allowed.path
    $fullPath = Join-Path $rootFullPath $relativePath
    $present = Test-Path -LiteralPath $fullPath
    if (-not $present) {
        $rootReports.Add([ordered]@{
            path = $relativePath
            kind = [string]$allowed.kind
            present = $false
            expectedGitState = [string]$allowed.gitPolicy
            actualGitState = "absent"
            trackedFileCount = 0
            ignoreRule = $null
            explanation = [string]$allowed.explanation
        })
        if ([bool]$allowed.required) {
            Add-Finding `
                -Findings $findings `
                -Code "REQUIRED_ROOT_MISSING" `
                -Path $relativePath `
                -Message "Required $($allowed.kind) root is missing."
        }
        continue
    }
    if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
        Add-Finding `
            -Findings $findings `
            -Code "ROOT_TYPE_MISMATCH" `
            -Path $relativePath `
            -Message "Allowed root exists but is not a directory."
        continue
    }

    $gitState = Get-GitState `
        -RelativePath $relativePath `
        -GitPolicy ([string]$allowed.gitPolicy) `
        -TrackedCountByRoot $trackedCountByRoot `
        -IgnoreRuleByRoot $ignoreRuleByRoot
    $rootReports.Add([ordered]@{
        path = $relativePath
        kind = [string]$allowed.kind
        present = $true
        expectedGitState = [string]$allowed.gitPolicy
        actualGitState = [string]$gitState.actual
        trackedFileCount = [int]$gitState.trackedFileCount
        ignoreRule = $gitState.ignoreRule
        explanation = [string]$allowed.explanation
    })

    switch ([string]$allowed.gitPolicy) {
        "tracked" {
            if ([bool]$gitState.ignored) {
                Add-Finding `
                    -Findings $findings `
                    -Code "TRACKED_ROOT_IGNORED" `
                    -Path $relativePath `
                    -Message "Canonical or distributed source is matched by an ignore rule."
            }
            if ([int]$gitState.trackedFileCount -eq 0) {
                Add-Finding `
                    -Findings $findings `
                    -Code "EXPECTED_TRACKED_ROOT_UNTRACKED" `
                    -Path $relativePath `
                    -Message "Root is expected to contain tracked source but Git reports no tracked files."
            }
        }
        "ignored" {
            if (-not [bool]$gitState.ignored) {
                Add-Finding `
                    -Findings $findings `
                    -Code "EXPECTED_IGNORED_ROOT_NOT_IGNORED" `
                    -Path $relativePath `
                    -Message "Runtime root is present but no ignore rule matches it."
            }
            if ([int]$gitState.trackedFileCount -gt 0) {
                Add-Finding `
                    -Findings $findings `
                    -Code "IGNORED_RUNTIME_ROOT_TRACKED" `
                    -Path $relativePath `
                    -Message "Runtime root contains tracked files."
            }
        }
        "runtime-local" {
            if ([int]$gitState.trackedFileCount -gt 0) {
                Add-Finding `
                    -Findings $findings `
                    -Code "RUNTIME_ROOT_TRACKED" `
                    -Path $relativePath `
                    -Message "Environment-owned runtime state must not be tracked."
            }
        }
    }
}

$forbiddenTopRoots = @{}
foreach ($forbidden in @(
    $normalizedForbidden | Sort-Object @{ Expression = { [string]$_.path } }
)) {
    $relativePath = [string]$forbidden.path
    $topRoot = ($relativePath -split "/", 2)[0]
    if ($relativePath -notmatch "/") {
        $forbiddenTopRoots[$topRoot] = $true
    }
    $fullPath = Join-Path $rootFullPath ($relativePath.Replace(
        "/",
        [System.IO.Path]::DirectorySeparatorChar
    ))
    if (Test-Path -LiteralPath $fullPath -PathType Container) {
        Add-Finding `
            -Findings $findings `
            -Code ([string]$forbidden.code) `
            -Path $relativePath `
            -Message ([string]$forbidden.explanation)
    }
}

foreach ($directory in @(
    Get-ChildItem -LiteralPath $rootFullPath -Force -Directory |
        Sort-Object Name
)) {
    $name = [string]$directory.Name
    if ($allowedByPath.ContainsKey($name) -or $forbiddenTopRoots.ContainsKey($name)) {
        continue
    }
    $runtimeLike = $false
    foreach ($pattern in $runtimePatterns) {
        if ($pattern.IsMatch($name)) {
            $runtimeLike = $true
            break
        }
    }
    $code = if ($runtimeLike) {
        "UNKNOWN_RUNTIME_ROOT"
    }
    else {
        "UNKNOWN_ROOT_DIRECTORY"
    }
    $message = if ($runtimeLike) {
        "Runtime-like root is not declared by the repository manifest."
    }
    else {
        "Root directory is not declared by the repository manifest."
    }
    Add-Finding -Findings $findings -Code $code -Path $name -Message $message
}

$sortedFindings = [object[]]@(
    $findings |
        Sort-Object `
            @{ Expression = { [string]$_.path } },
            @{ Expression = { [string]$_.code } }
)
$status = if ($sortedFindings.Count -eq 0) { "pass" } else { "fail" }
$report = [ordered]@{
    schemaVersion = "1.0"
    manifest = [System.IO.Path]::GetFileName($manifestFullPath)
    root = "."
    status = $status
    summary = [ordered]@{
        allowedRootCount = $normalizedAllowed.Count
        presentRootCount = @($rootReports | Where-Object { $_.present }).Count
        findingCount = $sortedFindings.Count
    }
    roots = [object[]]@($rootReports)
    findings = $sortedFindings
}

$json = ($report | ConvertTo-Json -Depth 50) -replace "`r`n", "`n"
Write-Output $json
if ($FailOnFinding -and $status -ne "pass") {
    throw "Repository doctor found $($sortedFindings.Count) issue(s)."
}
