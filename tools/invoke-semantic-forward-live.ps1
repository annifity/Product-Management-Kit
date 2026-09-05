[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CaseId,
    [Parameter(Mandatory = $true)][string]$CandidateRunnerPath,
    [Parameter(Mandatory = $true)][string]$EvaluatorRunnerPath,
    [Parameter(Mandatory = $true)][string]$OutputDirectory,
    [string]$ManifestPath = "tests/fixtures/semantic-forward/cases.json",
    [string]$RunId = ("live-{0}" -f [guid]::NewGuid().ToString("N"))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PowerShell = (Get-Process -Id $PID).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Resolve-Runner {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label runner does not exist: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

$candidateRunner = Resolve-Runner $CandidateRunnerPath "Candidate"
$evaluatorRunner = Resolve-Runner $EvaluatorRunnerPath "Evaluator"
$manifest = (Resolve-Path -LiteralPath $ManifestPath).Path
$runRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $runRoot) {
    throw "Refusing to overwrite semantic-forward run directory: $runRoot"
}
New-Item -ItemType Directory -Path $runRoot | Out-Null

$candidateTask = Join-Path $runRoot "candidate-task.json"
$candidateResult = Join-Path $runRoot "candidate-result.json"
$evaluatorTask = Join-Path $runRoot "evaluator-task.json"
$evaluation = Join-Path $runRoot "blind-evaluation.json"
$verdictPath = Join-Path $runRoot "verdict.json"

& (Join-Path $PSScriptRoot "new-semantic-forward-run.ps1") `
    -CaseId $CaseId `
    -ManifestPath $manifest `
    -OutputDirectory $runRoot `
    -RunId $RunId | Out-Null

& $PowerShell -NoProfile -ExecutionPolicy Bypass -File $candidateRunner `
    -TaskPath $candidateTask `
    -ResultPath $candidateResult
if ($LASTEXITCODE -ne 0 -or
    -not (Test-Path -LiteralPath $candidateResult -PathType Leaf)) {
    throw "Candidate runner failed to produce a result."
}

& (Join-Path $PSScriptRoot "new-semantic-forward-evaluator-task.ps1") `
    -CandidateTaskPath $candidateTask `
    -CandidateResultPath $candidateResult `
    -OutputPath $evaluatorTask `
    -ManifestPath $manifest | Out-Null

& $PowerShell -NoProfile -ExecutionPolicy Bypass -File $evaluatorRunner `
    -TaskPath $evaluatorTask `
    -ResultPath $evaluation
if ($LASTEXITCODE -ne 0 -or
    -not (Test-Path -LiteralPath $evaluation -PathType Leaf)) {
    throw "Evaluator runner failed to produce an evaluation."
}

$previous = $ErrorActionPreference
$ErrorActionPreference = "Continue"
try {
    $verdictText = @(
        & $PowerShell -NoProfile -ExecutionPolicy Bypass `
            -File (Join-Path $PSScriptRoot "evaluate-semantic-forward-run.ps1") `
            -CaseId $CaseId `
            -ManifestPath $manifest `
            -CandidateTaskPath $candidateTask `
            -CandidateResultPath $candidateResult `
            -BlindEvaluationPath $evaluation `
            -AsJson 2>&1
    ) -join [Environment]::NewLine
    $verdictExitCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $previous
    $global:LASTEXITCODE = 0
}
[void]($verdictText | ConvertFrom-Json)
[System.IO.File]::WriteAllText($verdictPath, "$verdictText`n", $Utf8NoBom)

$runRecord = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    caseId = $CaseId
    runId = $RunId
    candidateRunner = [System.IO.Path]::GetFileName($candidateRunner)
    evaluatorRunner = [System.IO.Path]::GetFileName($evaluatorRunner)
    candidateTask = "candidate-task.json"
    candidateResult = "candidate-result.json"
    evaluatorTask = "evaluator-task.json"
    blindEvaluation = "blind-evaluation.json"
    verdict = "verdict.json"
    exitCode = $verdictExitCode
}
[System.IO.File]::WriteAllText(
    (Join-Path $runRoot "run-record.json"),
    (($runRecord | ConvertTo-Json -Depth 10) + "`n"),
    $Utf8NoBom
)
Write-Host "Semantic-forward live run complete: $runRoot"
exit $verdictExitCode
