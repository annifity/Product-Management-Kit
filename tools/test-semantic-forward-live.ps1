[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PowerShell = (Get-Process -Id $PID).Path
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-semantic-live-{0}" -f [guid]::NewGuid().ToString("N")
)

try {
    $runRoot = Join-Path $TempRoot "run"
    & $PowerShell -NoProfile -ExecutionPolicy Bypass `
        -File (Join-Path $PSScriptRoot "invoke-semantic-forward-live.ps1") `
        -CaseId "refine-without-redesign" `
        -CandidateRunnerPath (
            Join-Path $Root "tests/fixtures/semantic-forward/runners/mock-candidate.ps1"
        ) `
        -EvaluatorRunnerPath (
            Join-Path $Root "tests/fixtures/semantic-forward/runners/mock-evaluator.ps1"
        ) `
        -OutputDirectory $runRoot `
        -ManifestPath (
            Join-Path $Root "tests/fixtures/semantic-forward/cases.json"
        ) `
        -RunId "live-contract-test"
    if ($LASTEXITCODE -ne 0) {
        throw "Live semantic-forward orchestration did not pass."
    }
    foreach ($name in @(
        "candidate-task.json",
        "candidate-result.json",
        "evaluator-task.json",
        "blind-evaluation.json",
        "verdict.json",
        "run-record.json"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $runRoot $name))) {
            throw "Live semantic-forward run is missing '$name'."
        }
    }
    $verdict = [System.IO.File]::ReadAllText(
        (Join-Path $runRoot "verdict.json")
    ) | ConvertFrom-Json
    if ([string]$verdict.verdict -cne "pass") {
        throw "Live semantic-forward verdict did not pass."
    }
    Write-Host "OK live semantic-forward orchestration."
}
finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}
