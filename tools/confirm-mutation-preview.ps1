[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PreviewPath,

    [string]$RootPath = (Join-Path $PSScriptRoot ".."),

    [Parameter(Mandatory = $true)]
    [string]$ConfirmFingerprint
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Hash {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string]$Expected,
        [Parameter(Mandatory = $true)][string]$Actual
    )

    if (-not $Expected.Equals($Actual, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Mutation preview is stale or invalid: $Label changed (expected $Expected, actual $Actual)."
    }
}

$previewFullPath = if ([System.IO.Path]::IsPathRooted($PreviewPath)) {
    [System.IO.Path]::GetFullPath($PreviewPath)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $PreviewPath))
}
if (-not (Test-Path -LiteralPath $previewFullPath -PathType Leaf)) {
    throw "Missing mutation preview: $PreviewPath"
}
if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
    throw "Mutation confirmation root is not a directory: $RootPath"
}
$root = (Resolve-Path -LiteralPath $RootPath).Path

$preview = Get-Content -Raw -LiteralPath $previewFullPath -Encoding UTF8 | ConvertFrom-Json
foreach ($requiredProperty in @(
    "schemaVersion",
    "algorithm",
    "changeIntent",
    "snapshots",
    "expectedAfter",
    "hashes"
)) {
    if (-not ($preview.PSObject.Properties.Name -contains $requiredProperty)) {
        throw "Mutation preview is missing required property '$requiredProperty'."
    }
}
if ([int]$preview.schemaVersion -ne 1) {
    throw "Mutation preview schemaVersion must be 1."
}
if ([string]$preview.algorithm -ne "SHA-256") {
    throw "Mutation preview algorithm must be SHA-256."
}
foreach ($hashProperty in @(
    "intentSha256",
    "sourcesSha256",
    "targetsSha256",
    "expectedAfterSha256",
    "fingerprint"
)) {
    if (-not ($preview.hashes.PSObject.Properties.Name -contains $hashProperty)) {
        throw "Mutation preview hashes are missing '$hashProperty'."
    }
    if ([string]$preview.hashes.$hashProperty -notmatch "^[0-9a-f]{64}$") {
        throw "Mutation preview hash '$hashProperty' must be 64 lowercase hexadecimal characters."
    }
}

$recordedFingerprint = [string]$preview.hashes.fingerprint
$confirmedFingerprint = $ConfirmFingerprint.Trim().ToLowerInvariant()
if (-not $confirmedFingerprint.Equals($recordedFingerprint, [System.StringComparison]::Ordinal)) {
    throw "Confirmation fingerprint does not match the displayed mutation preview."
}

$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-mutation-confirm-{0}" -f [guid]::NewGuid().ToString("N")
)
[void](New-Item -ItemType Directory -Path $tempDirectory)
$tempIntentPath = Join-Path $tempDirectory "intent.json"
$tempPreviewPath = Join-Path $tempDirectory "preview.json"

try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $intentJson = (($preview.changeIntent | ConvertTo-Json -Depth 100) -replace "`r`n", "`n") + "`n"
    [System.IO.File]::WriteAllText($tempIntentPath, $intentJson, $utf8NoBom)

    $previewGenerator = Join-Path $PSScriptRoot "new-mutation-preview.ps1"
    & $previewGenerator `
        -IntentPath $tempIntentPath `
        -RootPath $root `
        -OutputPath $tempPreviewPath 6>$null | Out-Null

    $current = Get-Content -Raw -LiteralPath $tempPreviewPath -Encoding UTF8 | ConvertFrom-Json
    Assert-Hash `
        -Label "change intent" `
        -Expected ([string]$preview.hashes.intentSha256) `
        -Actual ([string]$current.hashes.intentSha256)
    Assert-Hash `
        -Label "source snapshot" `
        -Expected ([string]$preview.hashes.sourcesSha256) `
        -Actual ([string]$current.hashes.sourcesSha256)
    Assert-Hash `
        -Label "target snapshot" `
        -Expected ([string]$preview.hashes.targetsSha256) `
        -Actual ([string]$current.hashes.targetsSha256)
    Assert-Hash `
        -Label "expected after-state" `
        -Expected ([string]$preview.hashes.expectedAfterSha256) `
        -Actual ([string]$current.hashes.expectedAfterSha256)
    Assert-Hash `
        -Label "combined fingerprint" `
        -Expected $recordedFingerprint `
        -Actual ([string]$current.hashes.fingerprint)

    $recordedSnapshots = $preview.snapshots | ConvertTo-Json -Depth 100 -Compress
    $currentSnapshots = $current.snapshots | ConvertTo-Json -Depth 100 -Compress
    if ($recordedSnapshots -ne $currentSnapshots) {
        throw "Mutation preview is invalid: recorded snapshot evidence differs from the fresh snapshot."
    }
    $recordedExpectedAfter = $preview.expectedAfter | ConvertTo-Json -Depth 100 -Compress
    $currentExpectedAfter = $current.expectedAfter | ConvertTo-Json -Depth 100 -Compress
    if ($recordedExpectedAfter -ne $currentExpectedAfter) {
        throw "Mutation preview is invalid: expected after-state differs from the fresh preview."
    }

    $receipt = [ordered]@{
        schemaVersion = 1
        status = "confirmed"
        algorithm = "SHA-256"
        fingerprint = $recordedFingerprint
        intentSha256 = [string]$preview.hashes.intentSha256
        sourcesSha256 = [string]$preview.hashes.sourcesSha256
        targetsSha256 = [string]$preview.hashes.targetsSha256
        expectedAfterSha256 = [string]$preview.hashes.expectedAfterSha256
    }
    Write-Output (($receipt | ConvertTo-Json -Depth 10) -replace "`r`n", "`n")
}
finally {
    if (Test-Path -LiteralPath $tempIntentPath -PathType Leaf) {
        Remove-Item -LiteralPath $tempIntentPath -Force
    }
    if (Test-Path -LiteralPath $tempPreviewPath -PathType Leaf) {
        Remove-Item -LiteralPath $tempPreviewPath -Force
    }
    if (Test-Path -LiteralPath $tempDirectory -PathType Container) {
        Remove-Item -LiteralPath $tempDirectory -Force
    }
}
