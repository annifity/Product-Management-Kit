[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FixtureRoot = Join-Path $Root "tests/fixtures/mutation-safety"
$FixtureWorkspace = Join-Path $FixtureRoot "workspace"
$NegativeTest = Join-Path $Root "tools/test-negative-completeness.ps1"
$PreviewTool = Join-Path $Root "tools/new-mutation-preview.ps1"
$ConfirmTool = Join-Path $Root "tools/confirm-mutation-preview.ps1"
$VerifyTool = Join-Path $Root "tools/verify-mutation-result.ps1"

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) { throw $Message }
}

foreach ($requiredPath in @(
    $FixtureWorkspace,
    (Join-Path $FixtureRoot "negative-completeness.pass.json"),
    (Join-Path $FixtureRoot "negative-completeness.fail.json"),
    (Join-Path $FixtureRoot "negative-completeness.empty.json"),
    (Join-Path $FixtureRoot "negative-completeness.absent-range.json"),
    (Join-Path $FixtureRoot "negative-completeness.present-zero.json"),
    (Join-Path $FixtureRoot "mutation-intent.json"),
    $NegativeTest,
    $PreviewTool,
    $ConfirmTool
    $VerifyTool
)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Mutation-safety test is missing required path: $requiredPath"
    }
}

$fixtureSourceHashBefore = (Get-FileHash -LiteralPath (Join-Path $FixtureWorkspace "source.txt") -Algorithm SHA256).Hash
$fixtureTargetHashBefore = (Get-FileHash -LiteralPath (Join-Path $FixtureWorkspace "target.txt") -Algorithm SHA256).Hash
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-mutation-safety-{0}" -f [guid]::NewGuid().ToString("N")
)
[void](New-Item -ItemType Directory -Path $tempRoot)
$workspace = Join-Path $tempRoot "workspace"
$previewOne = Join-Path $tempRoot "preview-one.json"
$previewTwo = Join-Path $tempRoot "preview-two.json"

try {
    Copy-Item -LiteralPath $FixtureWorkspace -Destination $workspace -Recurse
    & git -C $workspace init -q
    if ($LASTEXITCODE -ne 0) {
        throw "Could not initialize isolated Git fixture for mutation-safety tests."
    }
    $global:LASTEXITCODE = 0

    & $NegativeTest `
        -ManifestPath (Join-Path $FixtureRoot "negative-completeness.pass.json") `
        -RootPath $workspace | Out-Null

    $negativeFailureObserved = $false
    try {
        & $NegativeTest `
            -ManifestPath (Join-Path $FixtureRoot "negative-completeness.fail.json") `
            -RootPath $workspace | Out-Null
    }
    catch {
        $negativeFailureObserved = $true
    }
    Assert-True `
        -Condition $negativeFailureObserved `
        -Message "Negative-completeness tooling must fail contradictory expectations."

    foreach ($invalidManifest in @(
        "negative-completeness.empty.json",
        "negative-completeness.absent-range.json",
        "negative-completeness.present-zero.json"
    )) {
        $invalidFailureObserved = $false
        try {
            & $NegativeTest `
                -ManifestPath (Join-Path $FixtureRoot $invalidManifest) `
                -RootPath $workspace | Out-Null
        }
        catch {
            $invalidFailureObserved = $true
        }
        Assert-True `
            -Condition $invalidFailureObserved `
            -Message "Negative completeness must reject invalid manifest '$invalidManifest'."
    }

    $tempTargetPath = Join-Path $workspace "target.txt"
    $tempSourcePath = Join-Path $workspace "source.txt"
    $targetHashBefore = (Get-FileHash -LiteralPath $tempTargetPath -Algorithm SHA256).Hash
    $sourceHashBefore = (Get-FileHash -LiteralPath $tempSourcePath -Algorithm SHA256).Hash

    & $PreviewTool `
        -IntentPath (Join-Path $FixtureRoot "mutation-intent.json") `
        -RootPath $workspace `
        -OutputPath $previewOne | Out-Null
    & $PreviewTool `
        -IntentPath (Join-Path $FixtureRoot "mutation-intent.json") `
        -RootPath $workspace `
        -OutputPath $previewTwo | Out-Null

    $previewOneText = [System.IO.File]::ReadAllText($previewOne)
    $previewTwoText = [System.IO.File]::ReadAllText($previewTwo)
    Assert-True `
        -Condition ($previewOneText -ceq $previewTwoText) `
        -Message "Identical intent and workspace state must produce byte-identical mutation previews."

    $preview = $previewOneText | ConvertFrom-Json
    Assert-True `
        -Condition ([string]$preview.hashes.fingerprint -match "^[0-9a-f]{64}$") `
        -Message "Mutation preview fingerprint must be lowercase SHA-256."

    $receiptText = (& $ConfirmTool `
        -PreviewPath $previewOne `
        -RootPath $workspace `
        -ConfirmFingerprint ([string]$preview.hashes.fingerprint)) -join "`n"
    $receipt = $receiptText | ConvertFrom-Json
    Assert-True `
        -Condition ([string]$receipt.status -eq "confirmed") `
        -Message "Fresh mutation preview should produce a confirmation receipt."
    Assert-True `
        -Condition ([string]$receipt.fingerprint -eq [string]$preview.hashes.fingerprint) `
        -Message "Confirmation receipt must bind to the reviewed fingerprint."

    $targetHashAfterConfirmation = (Get-FileHash -LiteralPath $tempTargetPath -Algorithm SHA256).Hash
    $sourceHashAfterConfirmation = (Get-FileHash -LiteralPath $tempSourcePath -Algorithm SHA256).Hash
    Assert-True `
        -Condition ($targetHashBefore -eq $targetHashAfterConfirmation) `
        -Message "Confirmation must not mutate the target."
    Assert-True `
        -Condition ($sourceHashBefore -eq $sourceHashAfterConfirmation) `
        -Message "Confirmation must not mutate the source."
    Assert-True `
        -Condition (-not (Test-Path -LiteralPath (Join-Path $workspace "future.txt"))) `
        -Message "Confirmation must not create an absent target."

    $wrongFingerprintFailureObserved = $false
    try {
        & $ConfirmTool `
            -PreviewPath $previewOne `
            -RootPath $workspace `
            -ConfirmFingerprint ("0" * 64) | Out-Null
    }
    catch {
        $wrongFingerprintFailureObserved = $true
    }
    Assert-True `
        -Condition $wrongFingerprintFailureObserved `
        -Message "Confirmation must reject a fingerprint different from the reviewed preview."

    [System.IO.File]::AppendAllText($tempSourcePath, "stale-state")
    $staleFailureObserved = $false
    try {
        & $ConfirmTool `
            -PreviewPath $previewOne `
            -RootPath $workspace `
            -ConfirmFingerprint ([string]$preview.hashes.fingerprint) | Out-Null
    }
    catch {
        $staleFailureObserved = $true
    }
    Assert-True `
        -Condition $staleFailureObserved `
        -Message "Confirmation must reject a stale source or target snapshot."

    $targetHashAfterStaleCheck = (Get-FileHash -LiteralPath $tempTargetPath -Algorithm SHA256).Hash
    Assert-True `
        -Condition ($targetHashBefore -eq $targetHashAfterStaleCheck) `
        -Message "A stale confirmation attempt must not mutate the target."

    Copy-Item `
        -LiteralPath (Join-Path $FixtureWorkspace "source.txt") `
        -Destination $tempSourcePath `
        -Force
    Copy-Item -LiteralPath $tempSourcePath -Destination $tempTargetPath -Force
    Copy-Item `
        -LiteralPath $tempSourcePath `
        -Destination (Join-Path $workspace "future.txt")

    $verificationText = (& $VerifyTool `
        -PreviewPath $previewOne `
        -RootPath $workspace `
        -ConfirmFingerprint ([string]$preview.hashes.fingerprint)) -join "`n"
    $verification = $verificationText | ConvertFrom-Json
    Assert-True `
        -Condition ([string]$verification.status -eq "verified") `
        -Message "Exact confirmed after-state and bound negative completeness should verify."

    [System.IO.File]::AppendAllText($tempTargetPath, "unauthorized-after-state")
    $wrongAfterStateObserved = $false
    try {
        & $VerifyTool `
            -PreviewPath $previewOne `
            -RootPath $workspace `
            -ConfirmFingerprint ([string]$preview.hashes.fingerprint) | Out-Null
    }
    catch {
        $wrongAfterStateObserved = $true
    }
    Assert-True `
        -Condition $wrongAfterStateObserved `
        -Message "Mutation verification must reject content not bound to expectedAfter."
}
finally {
    $fixtureSourceHashAfter = (Get-FileHash -LiteralPath (Join-Path $FixtureWorkspace "source.txt") -Algorithm SHA256).Hash
    $fixtureTargetHashAfter = (Get-FileHash -LiteralPath (Join-Path $FixtureWorkspace "target.txt") -Algorithm SHA256).Hash
    if ($fixtureSourceHashBefore -ne $fixtureSourceHashAfter -or
        $fixtureTargetHashBefore -ne $fixtureTargetHashAfter) {
        throw "Mutation-safety tests modified live repository fixtures."
    }

    if (Test-Path -LiteralPath $tempRoot -PathType Container) {
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        $resolvedTempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).
            TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        $tempPrefix = $resolvedTempBase + [System.IO.Path]::DirectorySeparatorChar
        if (-not $resolvedTempRoot.StartsWith($tempPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove mutation-safety test directory outside the system temp root: $resolvedTempRoot"
        }
        Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
    }
}

Write-Host "OK mutation safety tests passed."
