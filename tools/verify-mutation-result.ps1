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
    throw "Mutation verification root is not a directory: $RootPath"
}
$root = (Resolve-Path -LiteralPath $RootPath).Path
$preview = Get-Content -Raw -LiteralPath $previewFullPath -Encoding UTF8 | ConvertFrom-Json
foreach ($name in @("changeIntent", "expectedAfter", "hashes")) {
    if (-not ($preview.PSObject.Properties.Name -contains $name)) {
        throw "Mutation preview is missing '$name'."
    }
}
if ([string]$preview.hashes.fingerprint -cne
    $ConfirmFingerprint.Trim().ToLowerInvariant()) {
    throw "Verification fingerprint does not match the confirmed preview."
}
if (-not ($preview.changeIntent.PSObject.Properties.Name -contains
    "negativeCompleteness")) {
    throw "Confirmed mutation preview has no bound negative-completeness manifest."
}

$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-mutation-verify-{0}" -f [guid]::NewGuid().ToString("N")
)
[void](New-Item -ItemType Directory -Path $tempDirectory)
$tempIntentPath = Join-Path $tempDirectory "intent.json"
$tempPreviewPath = Join-Path $tempDirectory "after-preview.json"
$tempManifestPath = Join-Path $tempDirectory "negative-completeness.json"

try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $intentJson = (($preview.changeIntent | ConvertTo-Json -Depth 100) -replace
        "`r`n", "`n") + "`n"
    [System.IO.File]::WriteAllText($tempIntentPath, $intentJson, $utf8NoBom)

    $previewGenerator = Join-Path $PSScriptRoot "new-mutation-preview.ps1"
    & $previewGenerator `
        -IntentPath $tempIntentPath `
        -RootPath $root `
        -OutputPath $tempPreviewPath `
        -AfterStateOnly 6>$null | Out-Null
    $current = Get-Content -Raw -LiteralPath $tempPreviewPath -Encoding UTF8 |
        ConvertFrom-Json

    $actualByPath = @{}
    foreach ($snapshot in @($current.snapshots.targets)) {
        $actualByPath[[string]$snapshot.path] = $snapshot
    }
    $failures = New-Object System.Collections.Generic.List[string]
    foreach ($expected in @($preview.expectedAfter)) {
        $path = [string]$expected.path
        if (-not $actualByPath.ContainsKey($path)) {
            $failures.Add("Missing actual after-state snapshot for '$path'.")
            continue
        }
        $actual = $actualByPath[$path]
        if ([string]$actual.state -cne [string]$expected.state) {
            $failures.Add(
                "After-state '$path' expected state '$($expected.state)' but found '$($actual.state)'."
            )
            continue
        }
        if ([string]$expected.state -ne "absent" -and
            [string]$actual.sha256 -cne [string]$expected.sha256) {
            $failures.Add(
                "After-state '$path' SHA-256 differs from the confirmed preview."
            )
        }
    }
    if ($actualByPath.Count -ne @($preview.expectedAfter).Count) {
        $failures.Add("Actual target snapshot count differs from expectedAfter.")
    }
    if ($failures.Count -gt 0) {
        throw "Mutation after-state verification failed:`n - $($failures -join "`n - ")"
    }

    $manifestJson = (($preview.changeIntent.negativeCompleteness |
        ConvertTo-Json -Depth 100) -replace "`r`n", "`n") + "`n"
    [System.IO.File]::WriteAllText(
        $tempManifestPath,
        $manifestJson,
        $utf8NoBom
    )
    $negativeVerifier = Join-Path $PSScriptRoot "test-negative-completeness.ps1"
    & $negativeVerifier `
        -ManifestPath $tempManifestPath `
        -RootPath $root | Out-Null

    $receipt = [ordered]@{
        schemaVersion = 1
        status = "verified"
        algorithm = "SHA-256"
        fingerprint = [string]$preview.hashes.fingerprint
        expectedAfterSha256 = [string]$preview.hashes.expectedAfterSha256
        actualTargetsSha256 = [string]$current.hashes.targetsSha256
        negativeCompleteness = "passed"
    }
    Write-Output (($receipt | ConvertTo-Json -Depth 10) -replace "`r`n", "`n")
}
finally {
    if (Test-Path -LiteralPath $tempDirectory -PathType Container) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempDirectory)
        $tempBase = [System.IO.Path]::GetFullPath(
            [System.IO.Path]::GetTempPath()
        ).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        $tempPrefix = $tempBase + [System.IO.Path]::DirectorySeparatorChar
        if (-not $resolvedTemp.StartsWith(
            $tempPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            throw "Refusing to remove mutation verification data outside temp."
        }
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}
