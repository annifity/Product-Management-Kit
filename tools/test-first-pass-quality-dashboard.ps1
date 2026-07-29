[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Builder = Join-Path $PSScriptRoot "build-first-pass-quality-dashboard.ps1"
$Manifest = "tests/fixtures/first-pass-dashboard/manifest.json"

$json = @(
    & $Builder -ManifestPath $Manifest -AsJson
) -join [Environment]::NewLine
$result = $json | ConvertFrom-Json

if ($result.status -cne "complete" -or [int]$result.overall.chains -ne 4) {
    throw "Dashboard returned the wrong status or chain count."
}
if ([double]$result.overall.firstPassAcceptanceRate -ne 0.5 -or
    [double]$result.overall.medianCorrectionTurns -ne 0.5) {
    throw "Dashboard returned incorrect first-pass or median correction metrics."
}
if ([int]$result.overall.defectCorrectionEvents -ne 4 -or
    [double]$result.overall.repeatAfterFixRate -ne 0.25 -or
    [double]$result.overall.unsupportedContentDeletionRate -ne 0.5 -or
    [double]$result.overall.contextMissRate -ne 0.25 -or
    [double]$result.overall.invalidDiagramRate -ne 0.25) {
    throw "Dashboard returned incorrect cause-based metrics."
}

$storyRow = @($result.bySkillVersion | Where-Object {
    $_.skill -ceq "user-story" -and $_.version -ceq "2.0"
})
if ($storyRow.Count -ne 1 -or [int]$storyRow[0].chains -ne 3 -or
    [double]$storyRow[0].firstPassAcceptanceRate -ne 0.6667) {
    throw "Dashboard did not group exact skill/version metrics correctly."
}
if ($result.targets.firstPassAcceptanceRate.status -cne "not-met" -or
    $result.targets.unsupportedContentDeletionRate.status -cne "baseline-required") {
    throw "Dashboard target status is incorrect."
}

$fixturePath = Join-Path $Root "tests/fixtures/first-pass-dashboard/session-audit.json"
$fixture = [System.IO.File]::ReadAllText($fixturePath) | ConvertFrom-Json
$fixture.privacy.rawContentIncluded = $true
$tempPath = Join-Path $Root "tests/fixtures/first-pass-dashboard/.invalid-raw-content.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
try {
    [System.IO.File]::WriteAllText(
        $tempPath,
        (($fixture | ConvertTo-Json -Depth 20) + "`n"),
        $utf8NoBom
    )
    $failed = $false
    try {
        & $Builder -InputPaths "tests/fixtures/first-pass-dashboard/.invalid-raw-content.json" | Out-Null
    }
    catch {
        $failed = $_.Exception.Message -match "privacy-safe"
    }
    if (-not $failed) {
        throw "Dashboard accepted an observation containing raw content."
    }
}
finally {
    if (Test-Path -LiteralPath $tempPath) {
        Remove-Item -LiteralPath $tempPath -Force
    }
}

Write-Host "OK first-pass quality dashboard metrics and privacy gates."

