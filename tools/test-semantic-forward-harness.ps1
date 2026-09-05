[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ManifestPath = Join-Path $Root "tests/fixtures/semantic-forward/cases.json"
$PrepareCandidate = Join-Path $PSScriptRoot "new-semantic-forward-run.ps1"
$PrepareEvaluator = Join-Path $PSScriptRoot "new-semantic-forward-evaluator-task.ps1"
$Evaluate = Join-Path $PSScriptRoot "evaluate-semantic-forward-run.ps1"
$PowerShell = (Get-Process -Id $PID).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-semantic-forward-{0}" -f [guid]::NewGuid().ToString("N")
)

function Write-Json {
    param([string]$Path, $Value)
    [System.IO.File]::WriteAllText(
        $Path,
        (($Value | ConvertTo-Json -Depth 20) + "`n"),
        $Utf8NoBom
    )
}

function Invoke-Verdict {
    param(
        [string]$CaseId,
        [string]$CandidateTask,
        [string]$CandidateResult,
        [string]$Evaluation
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = @(
            & $PowerShell -NoProfile -ExecutionPolicy Bypass `
                -File $Evaluate `
                -CaseId $CaseId `
                -ManifestPath $ManifestPath `
                -CandidateTaskPath $CandidateTask `
                -CandidateResultPath $CandidateResult `
                -BlindEvaluationPath $Evaluation `
                -AsJson 2>&1
        )
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
        $global:LASTEXITCODE = 0
    }
    return [pscustomobject]@{
        exitCode = $exitCode
        text = ($output -join [Environment]::NewLine)
    }
}

function Get-HiddenOracleTerms {
    param([Parameter(Mandatory = $true)]$Case)

    $terms = [System.Collections.Generic.List[string]]::new()
    foreach ($term in @($Case.oracle.requiredTerms)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$term)) {
            $terms.Add([string]$term)
        }
    }
    foreach ($term in @($Case.oracle.prohibitedTerms)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$term)) {
            $terms.Add([string]$term)
        }
    }
    if ($null -ne $Case.oracle.PSObject.Properties["expectedBaseline"] -and
        -not [string]::IsNullOrWhiteSpace([string]$Case.oracle.expectedBaseline)) {
        $terms.Add([string]$Case.oracle.expectedBaseline)
    }
    return [string[]]@($terms | Sort-Object -Unique)
}

function Assert-NoHiddenOracleTerms {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)]$Case,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($term in @(Get-HiddenOracleTerms -Case $Case)) {
        if ($Text.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "$Context exposed a hidden oracle term."
        }
    }
}

try {
    New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
    $manifest = [System.IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json
    $caseIds = @($manifest.cases | ForEach-Object { [string]$_.caseId })
    if (@($caseIds | Sort-Object -Unique).Count -ne $caseIds.Count) {
        throw "Semantic-forward corpus must contain unique anonymized regression cases."
    }
    $canonicalSkills = @(
        Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Directory |
            Select-Object -ExpandProperty Name |
            Sort-Object
    )
    $coveredSkills = @(
        $manifest.cases |
            ForEach-Object { [string]$_.skill } |
            Sort-Object -Unique
    )
    $missingSkills = @($canonicalSkills | Where-Object { $coveredSkills -cnotcontains $_ })
    $unknownSkills = @($coveredSkills | Where-Object { $canonicalSkills -cnotcontains $_ })
    if ($missingSkills.Count -gt 0 -or $unknownSkills.Count -gt 0) {
        throw (
            "Semantic-forward corpus skill coverage mismatch. Missing: [{0}]. Unknown: [{1}]." -f
            ($missingSkills -join ", "),
            ($unknownSkills -join ", ")
        )
    }

    foreach ($caseId in $caseIds) {
        $caseRoot = Join-Path $TempRoot $caseId
        & $PrepareCandidate `
            -CaseId $caseId `
            -ManifestPath $ManifestPath `
            -OutputDirectory $caseRoot `
            -RunId "test-$caseId" | Out-Null
        $taskPath = Join-Path $caseRoot "candidate-task.json"
        $taskText = [System.IO.File]::ReadAllText($taskPath)
        $task = $taskText | ConvertFrom-Json
        if ([string]$task.taskFingerprint -cnotmatch "^sha256:[0-9a-f]{64}$" -or
            @($task.sources).Count -eq 0 -or
            @($task.sourceHashes.PSObject.Properties).Count -eq 0) {
            throw "Candidate task '$caseId' is missing its canonical task/source binding."
        }
        foreach ($leak in @('"oracle"', "expectedBaseline", "requiredTerms", "prohibitedTerms")) {
            if ($taskText.IndexOf($leak, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                throw "Candidate task '$caseId' leaked '$leak'."
            }
        }
    }

    $passRoot = Join-Path $TempRoot "refine-without-redesign"
    $candidateTaskPath = Join-Path $passRoot "candidate-task.json"
    $candidateTask = [System.IO.File]::ReadAllText($candidateTaskPath) | ConvertFrom-Json
    $candidateResultPath = Join-Path $passRoot "candidate-result.json"
    $candidateResult = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        caseId = "refine-without-redesign"
        runId = "test-refine-without-redesign"
        contextId = "candidate-context-001"
        freshContext = $true
        additionalContextUsed = $false
        sourceHashes = $candidateTask.sourceHashes
        output = @"
# OFF-004@1.0 - Offboarding

Keep one story for People Operations to complete the confirmed Offboarding
workflow. The wording is refined without changing accepted scope.
"@
    }
    Write-Json -Path $candidateResultPath -Value $candidateResult

    $evaluatorTaskPath = Join-Path $passRoot "evaluator-task.json"
    & $PrepareEvaluator `
        -CandidateTaskPath $candidateTaskPath `
        -CandidateResultPath $candidateResultPath `
        -OutputPath $evaluatorTaskPath | Out-Null
    $evaluatorTaskText = [System.IO.File]::ReadAllText($evaluatorTaskPath)
    foreach ($leak in @('"oracle"', "expectedBaseline", "requiredTerms", "prohibitedTerms")) {
        if ($evaluatorTaskText.IndexOf($leak, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "Evaluator task leaked '$leak'."
        }
    }

    $evaluationPath = Join-Path $passRoot "blind-evaluation.json"
    Write-Json -Path $evaluationPath -Value ([pscustomobject][ordered]@{
        schemaVersion = "1.0"
        caseId = "refine-without-redesign"
        runId = "test-refine-without-redesign"
        contextId = "evaluator-context-001"
        independentContext = $true
        sawExpectedAnswer = $false
        usabilityScore = 4
        usabilityReason = "Directly actionable."
    })

    $pass = Invoke-Verdict `
        -CaseId "refine-without-redesign" `
        -CandidateTask $candidateTaskPath `
        -CandidateResult $candidateResultPath `
        -Evaluation $evaluationPath
    if ($pass.exitCode -ne 0) {
        throw "Passing semantic-forward case failed: $($pass.text)"
    }
    try {
        $passResult = $pass.text | ConvertFrom-Json
    }
    catch {
        throw "Passing semantic-forward case returned invalid JSON: $($pass.text)"
    }
    if ($passResult.verdict -cne "pass" -or
        [double]$passResult.scores.contextAdherence -lt 3 -or
        [double]$passResult.scores.usability -ne 4) {
        throw "Passing semantic-forward verdict returned incorrect scores."
    }
    $selectedCase = @(
        $manifest.cases |
            Where-Object { [string]$_.caseId -ceq "refine-without-redesign" }
    )[0]
    Assert-NoHiddenOracleTerms `
        -Text $pass.text `
        -Case $selectedCase `
        -Context "Passing candidate-visible verdict"

    $failingResultPath = Join-Path $passRoot "candidate-result-fail.json"
    $candidateResult.output += "`nIT Admin receives an acknowledgement SLA and retry workflow."
    Write-Json -Path $failingResultPath -Value $candidateResult
    $fail = Invoke-Verdict `
        -CaseId "refine-without-redesign" `
        -CandidateTask $candidateTaskPath `
        -CandidateResult $failingResultPath `
        -Evaluation $evaluationPath
    if ($fail.exitCode -ne 2) {
        throw "Prohibited semantic-forward output expected exit 2 but got $($fail.exitCode): $($fail.text)"
    }
    $failResult = $fail.text | ConvertFrom-Json
    if ($failResult.verdict -cne "fail" -or
        @($failResult.hardFailures) -cnotcontains "prohibited-content") {
        throw "Prohibited semantic-forward output was not diagnosed."
    }
    Assert-NoHiddenOracleTerms `
        -Text $fail.text `
        -Case $selectedCase `
        -Context "Failing candidate-visible verdict"
    foreach ($removedEvidenceField in @(
        "missingRequiredTerms",
        "prohibitedTermsFound",
        "maxWords",
        "candidateContextId",
        "evaluatorContextId"
    )) {
        if ($null -ne $failResult.evidence.PSObject.Properties[$removedEvidenceField]) {
            throw "Candidate-visible verdict retained oracle-bearing evidence '$removedEvidenceField'."
        }
    }
    if ([int]$failResult.evidence.prohibitedFoundCount -lt 1 -or
        [int]$failResult.evidence.prohibitedTermCount -lt
            [int]$failResult.evidence.prohibitedFoundCount) {
        throw "Candidate-visible verdict must return aggregate prohibited-term counts."
    }
    foreach ($failureCode in @($failResult.hardFailures)) {
        if ([string]$failureCode -cnotmatch "^[a-z0-9]+(?:-[a-z0-9]+)*$") {
            throw "Candidate-visible verdict returned a non-stable failure code."
        }
    }

    $promptTamper = [System.IO.File]::ReadAllText($candidateTaskPath) | ConvertFrom-Json
    $promptTamper.prompt = "Fabricated prompt."

    $contextTamper = [System.IO.File]::ReadAllText($candidateTaskPath) | ConvertFrom-Json
    $contextTamper.contextPolicy.allowedSourcesOnly = $false

    $emptySourceTamper = [System.IO.File]::ReadAllText($candidateTaskPath) | ConvertFrom-Json
    $emptySourceTamper.sources = @()
    $emptySourceTamper.sourceHashes = [pscustomobject]@{}

    $sourceHashTamper = [System.IO.File]::ReadAllText($candidateTaskPath) | ConvertFrom-Json
    $sourceHashTamper.sources[0].sha256 = "0" * 64

    $fingerprintTamper = [System.IO.File]::ReadAllText($candidateTaskPath) | ConvertFrom-Json
    $fingerprintTamper.taskFingerprint = "sha256:" + ("0" * 64)

    $tamperCases = @(
        [pscustomobject]@{ name = "prompt"; task = $promptTamper },
        [pscustomobject]@{ name = "context-policy"; task = $contextTamper },
        [pscustomobject]@{ name = "empty-source"; task = $emptySourceTamper },
        [pscustomobject]@{ name = "source-hash"; task = $sourceHashTamper },
        [pscustomobject]@{ name = "fingerprint"; task = $fingerprintTamper }
    )
    foreach ($tamperCase in $tamperCases) {
        $tamperedTaskPath = Join-Path $passRoot (
            "candidate-task-tampered-{0}.json" -f $tamperCase.name
        )
        Write-Json -Path $tamperedTaskPath -Value $tamperCase.task
        $tamperedVerdict = Invoke-Verdict `
            -CaseId "refine-without-redesign" `
            -CandidateTask $tamperedTaskPath `
            -CandidateResult $candidateResultPath `
            -Evaluation $evaluationPath
        if ($tamperedVerdict.exitCode -ne 2) {
            throw "Tampered '$($tamperCase.name)' task did not fail closed: $($tamperedVerdict.text)"
        }
        $tamperedResult = $tamperedVerdict.text | ConvertFrom-Json
        if ($tamperedResult.verdict -cne "fail" -or
            @($tamperedResult.hardFailures).Count -ne 1 -or
            [string]$tamperedResult.hardFailures[0] -cne "task-binding-invalid") {
            throw "Tampered '$($tamperCase.name)' task did not return the stable binding failure."
        }
        Assert-NoHiddenOracleTerms `
            -Text $tamperedVerdict.text `
            -Case $selectedCase `
            -Context "Tampered '$($tamperCase.name)' candidate-visible verdict"
    }

    $tamperedEvaluatorOutput = Join-Path $passRoot "tampered-evaluator-task.json"
    $tamperedEvaluatorRejected = $false
    try {
        & $PrepareEvaluator `
            -CandidateTaskPath (
                Join-Path $passRoot "candidate-task-tampered-empty-source.json"
            ) `
            -CandidateResultPath $candidateResultPath `
            -OutputPath $tamperedEvaluatorOutput | Out-Null
    }
    catch {
        $tamperedEvaluatorRejected = $_.Exception.Message -match "task-binding-invalid"
    }
    if (-not $tamperedEvaluatorRejected -or
        (Test-Path -LiteralPath $tamperedEvaluatorOutput)) {
        throw "Blind evaluator task generator accepted a fabricated empty-source task."
    }

    $leakedEvaluationPath = Join-Path $passRoot "blind-evaluation-leaked.json"
    Write-Json -Path $leakedEvaluationPath -Value ([pscustomobject][ordered]@{
        schemaVersion = "1.0"
        caseId = "refine-without-redesign"
        runId = "test-refine-without-redesign"
        contextId = "evaluator-context-002"
        independentContext = $true
        sawExpectedAnswer = $false
        usabilityScore = 4
        oracle = "leaked"
    })
    $leak = Invoke-Verdict `
        -CaseId "refine-without-redesign" `
        -CandidateTask $candidateTaskPath `
        -CandidateResult $candidateResultPath `
        -Evaluation $leakedEvaluationPath
    if ($leak.exitCode -eq 0) {
        throw "Leaked evaluator oracle was accepted."
    }

    Write-Host (
        "OK semantic forward-test harness ({0} blind cases; oracle-redaction and task-binding regressions)." `
            -f $caseIds.Count
    )
}
finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}
