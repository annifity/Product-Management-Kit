[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CandidateTaskPath,
    [Parameter(Mandatory = $true)][string]$CandidateResultPath,
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [string]$ManifestPath = "tests/fixtures/semantic-forward/cases.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-JsonFile {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label does not exist: $Path"
    }
    return [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path).Path) | ConvertFrom-Json
}

function Test-CanonicalCandidateTask {
    param(
        [Parameter(Mandatory = $true)][string]$StableCaseId,
        [Parameter(Mandatory = $true)][string]$StableRunId,
        [Parameter(Mandatory = $true)][string]$SubmittedTaskPath
    )

    $prepareCandidate = Join-Path $PSScriptRoot "new-semantic-forward-run.ps1"
    $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).
        TrimEnd([char[]]"\/")
    $tempRoot = Join-Path $tempBase (
        "annifity-semantic-evaluator-binding-{0}" -f [guid]::NewGuid().ToString("N")
    )
    try {
        [void](New-Item -ItemType Directory -Path $tempRoot)
        & $prepareCandidate `
            -CaseId $StableCaseId `
            -ManifestPath $ManifestPath `
            -OutputDirectory $tempRoot `
            -RunId $StableRunId | Out-Null

        $expectedPath = Join-Path $tempRoot "candidate-task.json"
        $submittedPath = (Resolve-Path -LiteralPath $SubmittedTaskPath).Path
        $expectedText = [System.IO.File]::ReadAllText($expectedPath)
        $submittedText = [System.IO.File]::ReadAllText($submittedPath)
        if ($expectedText -cne $submittedText) {
            return $false
        }
        $expectedTask = $expectedText | ConvertFrom-Json
        return [string]$expectedTask.taskFingerprint -cmatch "^sha256:[0-9a-f]{64}$"
    }
    catch {
        return $false
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot -PathType Container) {
            $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
            $tempPrefix = $tempBase + [System.IO.Path]::DirectorySeparatorChar
            if (-not $resolvedTempRoot.StartsWith(
                $tempPrefix,
                [System.StringComparison]::OrdinalIgnoreCase
            )) {
                throw "semantic-binding-temp-path-invalid"
            }
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }
}

$task = Read-JsonFile -Path $CandidateTaskPath -Label "Candidate task"
$candidate = Read-JsonFile -Path $CandidateResultPath -Label "Candidate result"

if ([string]::IsNullOrWhiteSpace([string]$task.caseId) -or
    [string]::IsNullOrWhiteSpace([string]$task.runId) -or
    -not (Test-CanonicalCandidateTask `
        -StableCaseId ([string]$task.caseId) `
        -StableRunId ([string]$task.runId) `
        -SubmittedTaskPath $CandidateTaskPath)) {
    throw "task-binding-invalid"
}

if ([string]$task.schemaVersion -cne "1.0" -or [string]$candidate.schemaVersion -cne "1.0") {
    throw "Unsupported semantic-forward result schema."
}
if ([string]$task.caseId -cne [string]$candidate.caseId -or
    [string]$task.runId -cne [string]$candidate.runId) {
    throw "Candidate result does not match the prepared task."
}
if ($candidate.freshContext -isnot [bool] -or -not [bool]$candidate.freshContext) {
    throw "Candidate result must declare a fresh context."
}
if ($candidate.additionalContextUsed -isnot [bool] -or [bool]$candidate.additionalContextUsed) {
    throw "Candidate result used undeclared context."
}
if ([string]::IsNullOrWhiteSpace([string]$candidate.contextId) -or
    [string]::IsNullOrWhiteSpace([string]$candidate.output)) {
    throw "Candidate result is missing contextId or output."
}

$expectedHashProperties = @($task.sourceHashes.PSObject.Properties)
$actualHashProperties = @($candidate.sourceHashes.PSObject.Properties)
if ($expectedHashProperties.Count -ne $actualHashProperties.Count) {
    throw "Candidate result source-hash set differs from the task."
}
foreach ($property in $expectedHashProperties) {
    $actual = $candidate.sourceHashes.PSObject.Properties[$property.Name]
    if ($null -eq $actual -or [string]$actual.Value -cne [string]$property.Value) {
        throw "Candidate result source hash drifted for '$($property.Name)'."
    }
}

$evaluatorTask = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    caseId = [string]$task.caseId
    runId = [string]$task.runId
    taskFingerprint = [string]$task.taskFingerprint
    prompt = "Independently rate only the candidate's usability from 0 to 4. Use a fresh context. Do not infer or search for an expected answer."
    contextPolicy = [pscustomobject][ordered]@{
        independentFreshThread = $true
        expectedAnswerWithheld = $true
        oracleWithheld = $true
    }
    rubric = [pscustomobject][ordered]@{
        score0 = "Not usable: incoherent or cannot support the requested handoff."
        score1 = "Major interpretation or rewrite is required."
        score2 = "Partly usable but material clarification is still required."
        score3 = "Usable with only non-material cleanup."
        score4 = "Directly usable, clear, actionable, and internally coherent."
    }
    originalPrompt = [string]$task.prompt
    sources = @($task.sources)
    candidateOutput = [string]$candidate.output
    candidateContextId = [string]$candidate.contextId
}
$json = ($evaluatorTask | ConvertTo-Json -Depth 12) + "`n"
foreach ($leak in @('"oracle"', "expectedBaseline", "requiredTerms", "prohibitedTerms")) {
    if ($json.IndexOf($leak, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Evaluator task leaked hidden oracle content: $leak"
    }
}

$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
if (Test-Path -LiteralPath $outputFullPath) {
    throw "Refusing to overwrite evaluator task: $outputFullPath"
}
$parent = [System.IO.Path]::GetDirectoryName($outputFullPath)
if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
[System.IO.File]::WriteAllText($outputFullPath, $json, $Utf8NoBom)
Write-Output "OK blind evaluator task: $outputFullPath"
