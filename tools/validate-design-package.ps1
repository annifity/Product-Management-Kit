[CmdletBinding()]
param(
    [string]$WorkspaceRoot = ".",

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PackagePath,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$Root = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$rootWithSeparator = $Root.TrimEnd([char[]]"\/") + [System.IO.Path]::DirectorySeparatorChar
$packageFullPath = if ([System.IO.Path]::IsPathRooted($PackagePath)) {
    [System.IO.Path]::GetFullPath($PackagePath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path $Root $PackagePath))
}

if (-not $packageFullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "PackagePath must stay inside workspace root '$Root'."
}
if (-not (Test-Path -LiteralPath $packageFullPath -PathType Container)) {
    throw "Design package does not exist: $PackagePath"
}

$manifestPath = Join-Path $packageFullPath "design-manifest.json"
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Design package is missing design-manifest.json."
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath -Encoding UTF8 | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
$FingerprintPattern = "^sha256:[0-9a-f]{64}$"
$AllowedStatuses = @("draft", "reviewed", "approved", "changes-requested", "baselined", "superseded")
$AllowedModes = @("screen-architecture", "wireframe", "visual-design", "interactive-html")
$AllowedAuthorityModes = @("bound-system", "existing-ui", "free-design")
$RequiredKinds = @("contract", "handoff", "brief", "design-system", "traceability", "screens", "review", "preview")

function Add-ValidationError {
    param([Parameter(Mandatory = $true)][string]$Message)
    $errors.Add($Message)
}

function Test-RequiredText {
    param($Object, [string]$Name, [string]$Context)
    if ($null -eq $Object -or $null -eq $Object.PSObject.Properties[$Name] -or
        [string]::IsNullOrWhiteSpace([string]$Object.$Name)) {
        Add-ValidationError "$Context is missing required '$Name'."
        return $false
    }
    return $true
}

if ([string]$manifest.schemaVersion -cne "1.0") {
    Add-ValidationError "schemaVersion must be exactly '1.0'."
}
foreach ($field in @("designId", "title", "status", "mode", "contractFingerprint", "decisionOwner", "created", "updated")) {
    Test-RequiredText -Object $manifest -Name $field -Context "manifest" | Out-Null
}
if ($AllowedStatuses -notcontains [string]$manifest.status) {
    Add-ValidationError "Unsupported design status '$($manifest.status)'."
}
if ($AllowedModes -notcontains [string]$manifest.mode) {
    Add-ValidationError "Unsupported design mode '$($manifest.mode)'."
}
if ([string]$manifest.contractFingerprint -notmatch $FingerprintPattern) {
    Add-ValidationError "contractFingerprint must use sha256:<64 lowercase hex>."
}

foreach ($field in @("artifactId", "version", "path", "sha256")) {
    Test-RequiredText -Object $manifest.sourceSpec -Name $field -Context "sourceSpec" | Out-Null
}
if ([string]$manifest.sourceSpec.sha256 -notmatch $FingerprintPattern) {
    Add-ValidationError "sourceSpec.sha256 must use sha256:<64 lowercase hex>."
}

if (Test-RequiredText -Object $manifest.designAuthority -Name "mode" -Context "designAuthority") {
    if ($AllowedAuthorityModes -notcontains [string]$manifest.designAuthority.mode) {
        Add-ValidationError "Unsupported designAuthority.mode '$($manifest.designAuthority.mode)'."
    }
}
Test-RequiredText -Object $manifest.designAuthority -Name "source" -Context "designAuthority" | Out-Null

$artifactKinds = @()
foreach ($artifact in @($manifest.artifacts)) {
    if (-not (Test-RequiredText -Object $artifact -Name "kind" -Context "artifact")) {
        continue
    }
    if (-not (Test-RequiredText -Object $artifact -Name "path" -Context "artifact")) {
        continue
    }

    $artifactKinds += [string]$artifact.kind
    $relativePath = [string]$artifact.path
    if ([System.IO.Path]::IsPathRooted($relativePath) -or $relativePath -match "(^|[\\/])\.\.([\\/]|$)") {
        Add-ValidationError "Artifact path must be package-relative without traversal: $relativePath"
        continue
    }
    $artifactFullPath = [System.IO.Path]::GetFullPath((Join-Path $packageFullPath $relativePath))
    $packageWithSeparator = $packageFullPath.TrimEnd([char[]]"\/") + [System.IO.Path]::DirectorySeparatorChar
    if (-not $artifactFullPath.StartsWith($packageWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        Add-ValidationError "Artifact path escapes the package: $relativePath"
        continue
    }
    if (-not (Test-Path -LiteralPath $artifactFullPath -PathType Leaf)) {
        Add-ValidationError "Artifact file is missing: $relativePath"
        continue
    }

    $artifactText = [System.IO.File]::ReadAllText($artifactFullPath)
    if ($artifactText -match "\{\{[A-Z0-9_]+\}\}") {
        Add-ValidationError "Artifact contains an unresolved package token: $relativePath"
    }
}

foreach ($kind in $RequiredKinds) {
    if ($artifactKinds -notcontains $kind) {
        Add-ValidationError "Manifest is missing required artifact kind '$kind'."
    }
}

$designContractPath = Join-Path $packageFullPath "design-contract.json"
if (Test-Path -LiteralPath $designContractPath -PathType Leaf) {
    try {
        $designContract = Get-Content -Raw -LiteralPath $designContractPath -Encoding UTF8 | ConvertFrom-Json
        if ([string]$designContract.schemaVersion -cne "1.0") {
            Add-ValidationError "design-contract.json schemaVersion must be exactly '1.0'."
        }
        if ([string]$designContract.designId -cne [string]$manifest.designId) {
            Add-ValidationError "design-contract.json designId must match the manifest."
        }
        if ([string]$designContract.source.artifactId -cne [string]$manifest.sourceSpec.artifactId -or
            [string]$designContract.source.version -cne [string]$manifest.sourceSpec.version -or
            [string]$designContract.source.sha256 -cne [string]$manifest.sourceSpec.sha256) {
            Add-ValidationError "design-contract.json source must match the manifest source baseline."
        }
        if ([string]$designContract.authority.behaviorAuthority -cne "accepted-source-only") {
            Add-ValidationError "design-contract.json behaviorAuthority must be 'accepted-source-only'."
        }
        if ([string]$designContract.gate.gateId -cne "phase.design.ready") {
            Add-ValidationError "design-contract.json must use gate ID 'phase.design.ready'."
        }
    }
    catch {
        Add-ValidationError "design-contract.json is not valid JSON: $($_.Exception.Message)"
    }
}

if (@($manifest.blockers).Count -gt 0 -and [string]$manifest.status -in @("approved", "baselined")) {
    Add-ValidationError "Approved or baselined design packages cannot contain blockers."
}

$sourcePath = [string]$manifest.sourceSpec.path
if ([System.IO.Path]::IsPathRooted($sourcePath) -or $sourcePath -match "(^|[\\/])\.\.([\\/]|$)") {
    Add-ValidationError "sourceSpec.path must be workspace-relative without traversal."
}
else {
    $sourceFullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $sourcePath))
    if (-not $sourceFullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $sourceFullPath -PathType Leaf)) {
        Add-ValidationError "sourceSpec.path does not resolve to a file inside the workspace."
    }
    else {
        $actualSourceHash = "sha256:" + (Get-FileHash -LiteralPath $sourceFullPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualSourceHash -cne [string]$manifest.sourceSpec.sha256) {
            Add-ValidationError "Source baseline hash no longer matches the package manifest."
        }
    }
}

$traceabilityPath = Join-Path $packageFullPath "traceability.md"
if (Test-Path -LiteralPath $traceabilityPath -PathType Leaf) {
    $traceabilityText = [System.IO.File]::ReadAllText($traceabilityPath)
    foreach ($needle in @("Requirement To Design", "Design To Requirement", "Requirement ID", "Screen", "State")) {
        if ($traceabilityText -notmatch [regex]::Escape($needle)) {
            Add-ValidationError "traceability.md is missing '$needle'."
        }
    }
}

$previewPath = Join-Path $packageFullPath "preview/index.html"
if (Test-Path -LiteralPath $previewPath -PathType Leaf) {
    $previewText = [System.IO.File]::ReadAllText($previewPath)
    foreach ($pattern in @(
        "(?i)<html[^>]+\blang\s*=",
        "(?i)<meta[^>]+\bname\s*=\s*['""]viewport['""]",
        "(?i)<main(?:\s|>)",
        "(?i)prefers-reduced-motion"
    )) {
        if ($previewText -notmatch $pattern) {
            Add-ValidationError "preview/index.html is missing required portable/accessibility pattern '$pattern'."
        }
    }
    if ($previewText -match "(?i)(?:src|href)\s*=\s*['""]https?://") {
        Add-ValidationError "preview/index.html must not depend on remote scripts, styles, fonts, images, or links."
    }
    if ($previewText -match "(?i)href\s*=\s*['""]#['""]") {
        Add-ValidationError "preview/index.html contains a placeholder href='#'."
    }
}

$result = [pscustomobject][ordered]@{
    valid = ($errors.Count -eq 0)
    packagePath = $packageFullPath.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
    designId = [string]$manifest.designId
    mode = [string]$manifest.mode
    source = "$($manifest.sourceSpec.artifactId)@$($manifest.sourceSpec.version)"
    errors = @($errors)
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 8
}
elseif ($result.valid) {
    Write-Host "OK design package '$($result.designId)' is valid."
}
else {
    foreach ($validationError in $errors) {
        Write-Error $validationError
    }
}

if (-not $result.valid) {
    exit 1
}
