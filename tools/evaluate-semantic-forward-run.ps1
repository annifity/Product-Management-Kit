[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$CaseId,
    [string]$ManifestPath = "tests/fixtures/semantic-forward/cases.json",
    [Parameter(Mandatory = $true)][string]$CandidateTaskPath,
    [Parameter(Mandatory = $true)][string]$CandidateResultPath,
    [Parameter(Mandatory = $true)][string]$BlindEvaluationPath,
    [string]$OutputPath,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Resolve-InputFile {
    param([string]$Path, [string]$Label)
    $fullPath = if ([System.IO.Path]::IsPathRooted($Path)) {
        [System.IO.Path]::GetFullPath($Path)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
    }
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "$Label does not exist: $Path"
    }
    return $fullPath
}

function Read-JsonFile {
    param([string]$Path, [string]$Label)
    $fullPath = Resolve-InputFile -Path $Path -Label $Label
    return [System.IO.File]::ReadAllText($fullPath) | ConvertFrom-Json
}

function Has-Property {
    param($Object, [string]$Name)
    return $null -ne $Object.PSObject.Properties[$Name]
}

function Contains-Term {
    param([string]$Text, [string]$Term)
    return $Text.IndexOf($Term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
}

function Stop-StableFailure {
    param(
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$CorpusId,
        [Parameter(Mandatory = $true)][string]$StableCaseId,
        [string]$StableRunId
    )

    $failure = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        corpusId = $CorpusId
        caseId = $StableCaseId
        runId = $StableRunId
        verdict = "fail"
        scores = [pscustomobject][ordered]@{
            unsupportedBehavior = "not-evaluated"
            contextAdherence = "not-evaluated"
            minimality = "not-evaluated"
            baselineSelection = "not-evaluated"
            usability = "not-evaluated"
        }
        evidence = [pscustomobject][ordered]@{
            requiredTermCount = 0
            missingRequiredCount = 0
            prohibitedTermCount = 0
            prohibitedFoundCount = 0
            wordCount = 0
            distinctContextCount = 0
        }
        hardFailures = @($Code)
    }
    $failureJson = ($failure | ConvertTo-Json -Depth 12) + "`n"
    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
        if (Test-Path -LiteralPath $outputFullPath) {
            throw "semantic-verdict-output-exists"
        }
        $parent = [System.IO.Path]::GetDirectoryName($outputFullPath)
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        [System.IO.File]::WriteAllText($outputFullPath, $failureJson, $Utf8NoBom)
    }
    if ($AsJson) {
        Write-Output $failureJson.TrimEnd()
    }
    else {
        Write-Output "FAIL semantic forward test '$StableCaseId'"
        Write-Output "Hard failures: $Code"
    }
    exit 2
}

function Test-CanonicalCandidateTask {
    param(
        [Parameter(Mandatory = $true)][string]$StableCaseId,
        [Parameter(Mandatory = $true)][string]$StableRunId,
        [Parameter(Mandatory = $true)][string]$SubmittedTaskPath,
        [Parameter(Mandatory = $true)][string]$CanonicalManifestPath
    )

    $prepareCandidate = Join-Path $PSScriptRoot "new-semantic-forward-run.ps1"
    if (-not (Test-Path -LiteralPath $prepareCandidate -PathType Leaf)) {
        return $false
    }

    $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).
        TrimEnd([char[]]"\/")
    $tempRoot = Join-Path $tempBase (
        "annifity-semantic-binding-{0}" -f [guid]::NewGuid().ToString("N")
    )
    try {
        [void](New-Item -ItemType Directory -Path $tempRoot)
        & $prepareCandidate `
            -CaseId $StableCaseId `
            -ManifestPath $CanonicalManifestPath `
            -OutputDirectory $tempRoot `
            -RunId $StableRunId | Out-Null

        $expectedPath = Join-Path $tempRoot "candidate-task.json"
        $submittedPath = Resolve-InputFile `
            -Path $SubmittedTaskPath `
            -Label "Candidate task"
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

$manifest = Read-JsonFile -Path $ManifestPath -Label "Manifest"
$candidateTask = Read-JsonFile -Path $CandidateTaskPath -Label "Candidate task"
$candidate = Read-JsonFile -Path $CandidateResultPath -Label "Candidate result"
$evaluation = Read-JsonFile -Path $BlindEvaluationPath -Label "Blind evaluation"

$cases = @($manifest.cases | Where-Object { [string]$_.caseId -ceq $CaseId })
if ($cases.Count -ne 1) {
    throw "Case '$CaseId' must resolve exactly once."
}
$case = $cases[0]
$submittedRunId = if (Has-Property -Object $candidateTask -Name "runId") {
    [string]$candidateTask.runId
}
else {
    ""
}
if ([string]::IsNullOrWhiteSpace($submittedRunId) -or
    -not (Test-CanonicalCandidateTask `
        -StableCaseId $CaseId `
        -StableRunId $submittedRunId `
        -SubmittedTaskPath $CandidateTaskPath `
        -CanonicalManifestPath $ManifestPath)) {
    Stop-StableFailure `
        -Code "task-binding-invalid" `
        -CorpusId ([string]$manifest.corpusId) `
        -StableCaseId $CaseId `
        -StableRunId $submittedRunId
}
$oracle = $case.oracle

foreach ($record in @($candidateTask, $candidate, $evaluation)) {
    if ([string]$record.schemaVersion -cne "1.0" -or
        [string]$record.caseId -cne $CaseId -or
        [string]$record.runId -cne [string]$candidateTask.runId) {
        throw "Semantic-forward records do not share one schema, case, and run."
    }
}
if (Has-Property -Object $candidateTask -Name "oracle") {
    throw "Candidate task contains the hidden oracle."
}
foreach ($leak in @("oracle", "expectedAnswer", "expectedBaseline", "requiredTerms", "prohibitedTerms")) {
    if (Has-Property -Object $evaluation -Name $leak) {
        throw "Blind evaluation contains leaked field '$leak'."
    }
}

$hardFailures = New-Object System.Collections.Generic.List[string]
if ($candidate.freshContext -isnot [bool] -or -not [bool]$candidate.freshContext) {
    $hardFailures.Add("candidate-not-fresh") | Out-Null
}
if ($candidate.additionalContextUsed -isnot [bool] -or [bool]$candidate.additionalContextUsed) {
    $hardFailures.Add("candidate-used-additional-context") | Out-Null
}
if ($evaluation.independentContext -isnot [bool] -or -not [bool]$evaluation.independentContext) {
    $hardFailures.Add("evaluator-not-independent") | Out-Null
}
if ($evaluation.sawExpectedAnswer -isnot [bool] -or [bool]$evaluation.sawExpectedAnswer) {
    $hardFailures.Add("evaluator-saw-expected-answer") | Out-Null
}
if ([string]$candidate.contextId -ceq [string]$evaluation.contextId) {
    $hardFailures.Add("context-id-reused") | Out-Null
}

$expectedHashes = @($candidateTask.sourceHashes.PSObject.Properties)
$actualHashes = @($candidate.sourceHashes.PSObject.Properties)
if ($expectedHashes.Count -ne $actualHashes.Count) {
    $hardFailures.Add("source-hash-set-drift") | Out-Null
}
else {
    foreach ($property in $expectedHashes) {
        $actual = $candidate.sourceHashes.PSObject.Properties[$property.Name]
        if ($null -eq $actual -or [string]$actual.Value -cne [string]$property.Value) {
            $hardFailures.Add("source-hash-drift") | Out-Null
        }
    }
}

$output = [string]$candidate.output
$requiredTerms = if (Has-Property -Object $oracle -Name "requiredTerms") {
    @($oracle.requiredTerms | ForEach-Object { [string]$_ })
}
else { @() }
$prohibitedTerms = if (Has-Property -Object $oracle -Name "prohibitedTerms") {
    @($oracle.prohibitedTerms | ForEach-Object { [string]$_ })
}
else { @() }

$missingRequired = @($requiredTerms | Where-Object { -not (Contains-Term -Text $output -Term $_) })
$foundProhibited = @($prohibitedTerms | Where-Object { Contains-Term -Text $output -Term $_ })
if ($foundProhibited.Count -gt 0) {
    $hardFailures.Add("prohibited-content") | Out-Null
}

$contextScore = if ($requiredTerms.Count -eq 0) {
    4.0
}
else {
    [math]::Round((($requiredTerms.Count - $missingRequired.Count) / [double]$requiredTerms.Count) * 4, 2)
}
$unsupportedScore = if ($foundProhibited.Count -eq 0) { 4.0 } else { 0.0 }

$wordCount = @([regex]::Matches($output, "\b[\p{L}\p{N}][\p{L}\p{N}'-]*\b")).Count
$maxWords = if (Has-Property -Object $oracle -Name "maxWords") { [int]$oracle.maxWords } else { 0 }
$minimalityApplicable = $maxWords -gt 0
$minimalityScore = if (-not $minimalityApplicable -or $wordCount -le $maxWords) { 4.0 } else { 0.0 }

$baselineApplicable = (Has-Property -Object $oracle -Name "expectedBaseline") -and
    -not [string]::IsNullOrWhiteSpace([string]$oracle.expectedBaseline)
$baselineScore = 4.0
if ($baselineApplicable -and -not (Contains-Term -Text $output -Term ([string]$oracle.expectedBaseline))) {
    $baselineScore = 0.0
    $hardFailures.Add("wrong-or-missing-baseline") | Out-Null
}

$usability = 0
if (-not ([int]::TryParse([string]$evaluation.usabilityScore, [ref]$usability)) -or
    $usability -lt 0 -or $usability -gt 4) {
    throw "Blind evaluation usabilityScore must be an integer from 0 to 4."
}

$scores = [pscustomobject][ordered]@{
    unsupportedBehavior = $unsupportedScore
    contextAdherence = $contextScore
    minimality = $minimalityScore
    baselineSelection = if ($baselineApplicable) { $baselineScore } else { "not-applicable" }
    usability = $usability
}
$scoreFailures = @()
foreach ($score in @(
    $unsupportedScore,
    $contextScore,
    $minimalityScore,
    $(if ($baselineApplicable) { $baselineScore } else { 4.0 }),
    [double]$usability
)) {
    if ($score -lt 3) {
        $scoreFailures += $score
    }
}

$result = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    corpusId = [string]$manifest.corpusId
    caseId = $CaseId
    runId = [string]$candidateTask.runId
    verdict = if ($hardFailures.Count -eq 0 -and $scoreFailures.Count -eq 0) { "pass" } else { "fail" }
    scores = $scores
    evidence = [pscustomobject][ordered]@{
        requiredTermCount = $requiredTerms.Count
        missingRequiredCount = $missingRequired.Count
        prohibitedTermCount = $prohibitedTerms.Count
        prohibitedFoundCount = $foundProhibited.Count
        wordCount = $wordCount
        distinctContextCount = @(
            @([string]$candidate.contextId, [string]$evaluation.contextId) |
                Sort-Object -Unique
        ).Count
    }
    hardFailures = @($hardFailures | Sort-Object -Unique)
}
$json = ($result | ConvertTo-Json -Depth 12) + "`n"
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
    if (Test-Path -LiteralPath $outputFullPath) {
        throw "Refusing to overwrite semantic-forward verdict: $outputFullPath"
    }
    $parent = [System.IO.Path]::GetDirectoryName($outputFullPath)
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($outputFullPath, $json, $Utf8NoBom)
}
if ($AsJson) {
    Write-Output $json.TrimEnd()
}
else {
    Write-Output "$($result.verdict.ToUpperInvariant()) semantic forward test '$CaseId'"
    Write-Output "Scores: unsupported=$unsupportedScore context=$contextScore minimality=$minimalityScore baseline=$($scores.baselineSelection) usability=$usability"
    if ($result.verdict -eq "fail") {
        Write-Output "Hard failures: $(@($result.hardFailures) -join ', ')"
    }
}
if ($result.verdict -eq "fail") { exit 2 }
exit 0
