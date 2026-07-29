[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$CaseId,

    [string]$ManifestPath = "tests/fixtures/semantic-forward/cases.json",

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputDirectory,

    [string]$RunId = ([guid]::NewGuid().ToString("N"))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Resolve-RepoFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )

    if ([System.IO.Path]::IsPathRooted($Path) -or
        @($Path.Replace("\", "/").Split("/")) -contains ".." -or
        @($Path.Replace("\", "/").Split("/")) -contains ".") {
        throw "$Label must be a canonical repository-relative path: $Path"
    }

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]"\/")
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $rootFull $Path))
    $prefix = $rootFull + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label escapes the repository root: $Path"
    }
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "$Label does not exist: $Path"
    }
    return $fullPath
}

function Get-RequiredText {
    param($Object, [string]$Name, [string]$Context)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        throw "$Context is missing '$Name'."
    }
    return ([string]$property.Value).Trim()
}

function ConvertTo-CanonicalJson {
    param($Value)

    if ($null -eq $Value) {
        return "null"
    }
    if ($Value -is [string] -or $Value -is [char]) {
        return ([string]$Value | ConvertTo-Json -Compress)
    }
    if ($Value -is [bool]) {
        if ($Value) { return "true" }
        return "false"
    }
    if (
        $Value -is [byte] -or $Value -is [sbyte] -or
        $Value -is [int16] -or $Value -is [uint16] -or
        $Value -is [int32] -or $Value -is [uint32] -or
        $Value -is [int64] -or $Value -is [uint64] -or
        $Value -is [single] -or $Value -is [double] -or
        $Value -is [decimal]
    ) {
        return [System.Convert]::ToString(
            $Value,
            [System.Globalization.CultureInfo]::InvariantCulture
        )
    }
    if ($Value -is [System.Collections.IDictionary]) {
        $parts = foreach ($key in @(
            $Value.Keys | ForEach-Object { [string]$_ } | Sort-Object
        )) {
            $encodedKey = ([string]$key | ConvertTo-Json -Compress)
            "$encodedKey`:$((ConvertTo-CanonicalJson -Value $Value[$key]))"
        }
        return "{$($parts -join ',')}"
    }

    $properties = @($Value.PSObject.Properties)
    $isObject = $Value -is [pscustomobject] -or (
        $properties.Count -gt 0 -and
        -not ($Value -is [System.Collections.IEnumerable])
    )
    if ($isObject) {
        $parts = foreach ($property in @($properties | Sort-Object Name)) {
            $encodedName = ([string]$property.Name | ConvertTo-Json -Compress)
            "$encodedName`:$((ConvertTo-CanonicalJson -Value $property.Value))"
        }
        return "{$($parts -join ',')}"
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $parts = foreach ($item in $Value) {
            ConvertTo-CanonicalJson -Value $item
        }
        return "[$($parts -join ',')]"
    }
    return ([string]$Value | ConvertTo-Json -Compress)
}

function Get-CanonicalSha256 {
    param([Parameter(Mandatory = $true)]$Value)

    $bytes = $Utf8NoBom.GetBytes((ConvertTo-CanonicalJson -Value $Value))
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }
    return "sha256:" + (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
}

$manifestRepoPath = if ([System.IO.Path]::IsPathRooted($ManifestPath)) {
    $manifestFull = [System.IO.Path]::GetFullPath($ManifestPath)
    $rootPrefix = $Root.TrimEnd([char[]]"\/") + [System.IO.Path]::DirectorySeparatorChar
    if (-not $manifestFull.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Manifest must stay inside the repository."
    }
    $manifestFull.Substring($Root.TrimEnd([char[]]"\/").Length).TrimStart([char[]]"\/").Replace("\", "/")
}
else {
    $ManifestPath.Replace("\", "/")
}
$manifestFullPath = Resolve-RepoFile -Path $manifestRepoPath -Label "Manifest"
$manifest = [System.IO.File]::ReadAllText($manifestFullPath) | ConvertFrom-Json
if ((Get-RequiredText -Object $manifest -Name "schemaVersion" -Context "Manifest") -cne "1.0") {
    throw "Unsupported semantic-forward manifest schema."
}
$corpusId = Get-RequiredText -Object $manifest -Name "corpusId" -Context "Manifest"

$casesProperty = $manifest.PSObject.Properties["cases"]
if ($null -eq $casesProperty) {
    throw "Manifest is missing 'cases'."
}
$cases = @($casesProperty.Value)
$matches = @($cases | Where-Object { [string]$_.caseId -ceq $CaseId })
if ($matches.Count -ne 1) {
    throw "Case '$CaseId' must resolve exactly once; found $($matches.Count)."
}
$case = $matches[0]

$skill = Get-RequiredText -Object $case -Name "skill" -Context "Case '$CaseId'"
$prompt = Get-RequiredText -Object $case -Name "prompt" -Context "Case '$CaseId'"
$sourceFilesProperty = $case.PSObject.Properties["sourceFiles"]
if ($null -eq $sourceFilesProperty -or @($sourceFilesProperty.Value).Count -eq 0) {
    throw "Case '$CaseId' must declare at least one source file."
}
$dimensions = @($case.dimensions | ForEach-Object { [string]$_ })
$requiredDimensions = @(
    "unsupported-behavior",
    "context-adherence",
    "minimality",
    "baseline-selection",
    "usability"
)
foreach ($dimension in $requiredDimensions) {
    if ($dimensions -cnotcontains $dimension) {
        throw "Case '$CaseId' is missing dimension '$dimension'."
    }
}
if ($null -eq $case.PSObject.Properties["oracle"]) {
    throw "Case '$CaseId' is missing its hidden oracle."
}

$sources = @()
$sourceHashes = [ordered]@{}
$sourcePathSeen = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($sourcePathValue in @($sourceFilesProperty.Value)) {
    $sourcePath = ([string]$sourcePathValue).Replace("\", "/")
    if ([string]::IsNullOrWhiteSpace($sourcePath) -or
        -not $sourcePathSeen.Add($sourcePath)) {
        throw "Case '$CaseId' contains an empty or duplicate source path."
    }
    $sourceFullPath = Resolve-RepoFile -Path $sourcePath -Label "Case source"
    $bytes = [System.IO.File]::ReadAllBytes($sourceFullPath)
    $sha = (Get-FileHash -LiteralPath $sourceFullPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $content = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ([string]::IsNullOrWhiteSpace($content)) {
        throw "Case '$CaseId' source content must not be empty."
    }
    $sourceHashes[$sourcePath] = $sha
    $sources += [pscustomobject][ordered]@{
        path = $sourcePath
        sha256 = $sha
        content = $content
    }
}

$outputFullPath = [System.IO.Path]::GetFullPath($OutputDirectory)
if (-not (Test-Path -LiteralPath $outputFullPath)) {
    New-Item -ItemType Directory -Path $outputFullPath -Force | Out-Null
}
$candidateTaskPath = Join-Path $outputFullPath "candidate-task.json"
if (Test-Path -LiteralPath $candidateTaskPath) {
    throw "Refusing to overwrite existing candidate task: $candidateTaskPath"
}

$contextPolicy = [pscustomobject][ordered]@{
    freshThread = $true
    allowedSourcesOnly = $true
    doNotReadExpectedAnswer = $true
    doNotReadPriorOutputs = $true
}
$manifestSha256 = (Get-FileHash -LiteralPath $manifestFullPath -Algorithm SHA256).
    Hash.
    ToLowerInvariant()
$bindingSources = @(
    $sources |
        ForEach-Object {
            [pscustomobject][ordered]@{
                path = [string]$_.path
                sha256 = [string]$_.sha256
            }
        }
)
$taskFingerprint = Get-CanonicalSha256 -Value ([ordered]@{
    schemaVersion = "1.0"
    manifestSha256 = $manifestSha256
    corpusId = $corpusId
    caseId = $CaseId
    runId = $RunId
    skill = $skill
    prompt = $prompt
    contextPolicy = $contextPolicy
    sources = $bindingSources
})

$candidateTask = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    caseId = $CaseId
    runId = $RunId
    taskFingerprint = $taskFingerprint
    skill = $skill
    prompt = $prompt
    contextPolicy = $contextPolicy
    sources = @($sources)
    sourceHashes = [pscustomobject]$sourceHashes
}
$json = ($candidateTask | ConvertTo-Json -Depth 12) + "`n"
if ($json.IndexOf('"oracle"', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
    throw "Candidate task leaked the hidden oracle."
}
[System.IO.File]::WriteAllText($candidateTaskPath, $json, $Utf8NoBom)

Write-Output "OK candidate task: $candidateTaskPath"
Write-Output "Run ID: $RunId"
Write-Output "Execute it in a fresh context and return a candidate-result JSON."
