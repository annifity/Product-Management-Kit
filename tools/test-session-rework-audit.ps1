[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Auditor = Join-Path $PSScriptRoot "audit-session-rework.ps1"
$FixturesRoot = Join-Path $Root "tests/fixtures/session-rework"
$PowerShell = (Get-Process -Id $PID).Path

if (-not (Test-Path -LiteralPath $Auditor -PathType Leaf)) {
    throw "Missing session rework auditor: tools/audit-session-rework.ps1"
}
if (-not (Test-Path -LiteralPath $FixturesRoot -PathType Container)) {
    throw "Missing session rework fixtures: tests/fixtures/session-rework"
}

function Invoke-Auditor {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [switch]$AllowNonJson
    )

    $output = @(
        & $PowerShell `
            -NoProfile `
            -ExecutionPolicy Bypass `
            -File $Auditor `
            @Arguments 2>&1
    )
    $exitCode = $LASTEXITCODE
    $text = ($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    $result = $null
    try {
        $result = $text | ConvertFrom-Json
    }
    catch {
        if (-not $AllowNonJson) {
            throw "Auditor returned invalid JSON. Output: $text"
        }
    }
    return [pscustomobject]@{
        exitCode = $exitCode
        text = $text
        result = $result
    }
}

function Assert-Blocked {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Code
    )

    $case = Invoke-Auditor -Arguments $Arguments
    if ($case.exitCode -ne 2) {
        throw "Expected blocked exit code 2 for '$Code' but got $($case.exitCode)."
    }
    if ($case.result.status -cne "blocked") {
        throw "Expected blocked status for '$Code' but got '$($case.result.status)'."
    }
    $codes = @($case.result.diagnostics | ForEach-Object { [string]$_.code })
    if ($codes -cnotcontains $Code) {
        throw "Expected diagnostic '$Code' but got: $($codes -join ', ')."
    }
    if (@($case.result.chains).Count -ne 0 -or $null -ne $case.result.metrics) {
        throw "Blocked audit '$Code' emitted chains or aggregate metrics."
    }
    if ($case.text -match [regex]::Escape($Root)) {
        throw "Blocked audit '$Code' exposed an absolute repository path."
    }
}

$manifestPath = Join-Path $FixturesRoot "valid/manifest.json"
$valid = Invoke-Auditor -Arguments @("-ManifestPath", $manifestPath)
$repeat = Invoke-Auditor -Arguments @("-ManifestPath", $manifestPath)

if ($valid.exitCode -ne 0 -or $valid.result.status -cne "complete") {
    $codes = @($valid.result.diagnostics | ForEach-Object { [string]$_.code })
    throw "Valid manifest audit failed. Diagnostics: $($codes -join ', ')."
}
if ($valid.text -cne $repeat.text) {
    throw "Equivalent session evidence did not produce byte-equivalent JSON."
}
if ($valid.result.schemaVersion -cne "1.0") {
    throw "Valid audit returned the wrong schema version."
}

$metrics = $valid.result.metrics
$expectedMetrics = [ordered]@{
    sessionsProvided = 2
    sessionsIncluded = 1
    sessionsExcluded = 1
    messagePayloads = 22
    uniqueMessagePayloads = 21
    duplicateMessagePayloads = 1
    observedChains = 5
    acceptedChains = 4
    unresolvedChains = 1
    correctionEvents = 4
    manualEditEvents = 1
    classifiedReworkEvents = 5
    firstPassDefectEvents = 4
    userScopeChangeEvents = 1
    firstPassDefectChains = 3
    userScopeChangeChains = 1
    manualEditChains = 1
}
foreach ($property in $expectedMetrics.GetEnumerator()) {
    if ([int]$metrics.($property.Key) -ne [int]$property.Value) {
        throw "Metric '$($property.Key)' expected $($property.Value) but got $($metrics.($property.Key))."
    }
}
if ([double]$metrics.firstPassDefectRate -ne 0.6 -or
    [double]$metrics.firstPassSuccessRate -ne 0.4 -or
    [double]$metrics.userScopeChangeRate -ne 0.2 -or
    [double]$metrics.averageCorrectionsPerChain -ne 0.8 -or
    [double]$metrics.averageClassificationConfidence -ne 0.9) {
    throw "Valid audit returned incorrect aggregate rates or confidence."
}

$includedSources = @($valid.result.sources | Where-Object { $_.status -ceq "included" })
$excludedSources = @($valid.result.sources | Where-Object { $_.status -ceq "excluded" })
if ($includedSources.Count -ne 1 -or
    $includedSources[0].sourceId -cne "session-root-001" -or
    $includedSources[0].skill.version -cne "git:0123456789abcdef") {
    throw "Valid audit did not preserve included source and skill-version evidence."
}
if ($excludedSources.Count -ne 1 -or
    $excludedSources[0].sourceId -cne "session-subagent-001" -or
    $excludedSources[0].reason -cne "declared_subagent") {
    throw "Declared subagent evidence was not excluded."
}

$defectChain = @(
    $valid.result.chains |
        Where-Object { $_.chainId -ceq "CHAIN-DEFECT" }
)
$scopeChain = @(
    $valid.result.chains |
        Where-Object { $_.chainId -ceq "CHAIN-SCOPE" }
)
$manualChain = @(
    $valid.result.chains |
        Where-Object { $_.chainId -ceq "CHAIN-MANUAL" }
)
$firstPassChain = @(
    $valid.result.chains |
        Where-Object { $_.chainId -ceq "CHAIN-FIRST-PASS" }
)
$machineMetricsChain = @(
    $valid.result.chains |
        Where-Object { $_.chainId -ceq "CHAIN-MACHINE-METRICS" }
)
if ($defectChain.Count -ne 1 -or
    -not [bool]$defectChain[0].firstPassDefect -or
    [bool]$defectChain[0].userScopeChange -or
    $defectChain[0].corrections[0].classification -cne "first_pass_defect" -or
    $defectChain[0].missedContext[0].kind -cne "policy") {
    throw "First-pass defect chain was not classified or traced correctly."
}
if ($scopeChain.Count -ne 1 -or
    [bool]$scopeChain[0].firstPassDefect -or
    -not [bool]$scopeChain[0].userScopeChange -or
    $scopeChain[0].outcome -cne "accepted_after_scope_change") {
    throw "User scope change was incorrectly attributed to first-pass quality."
}
if ($manualChain.Count -ne 1 -or
    $manualChain[0].manualEdits.Count -ne 1 -or
    $manualChain[0].manualEdits[0].classification -cne "first_pass_defect") {
    throw "Manual-edit evidence was not retained and classified."
}
if ($firstPassChain.Count -ne 1 -or
    $firstPassChain[0].outcome -cne "accepted_first_pass" -or
    $null -eq $firstPassChain[0].acceptedOutput) {
    throw "Accepted first output was not resolved correctly."
}
if ($machineMetricsChain.Count -ne 1 -or
    $machineMetricsChain[0].corrections.Count -ne 2 -or
    $machineMetricsChain[0].corrections[0].classification -cne "first_pass_defect" -or
    @($machineMetricsChain[0].corrections[0].causes) -cnotcontains "unsupported_content" -or
    @($machineMetricsChain[0].corrections[0].causes) -cnotcontains "invalid_diagram" -or
    @($machineMetricsChain[0].corrections[1].causes) -cnotcontains "repeat_after_fix") {
    throw "Machine-readable unsupported-content, invalid-diagram, or repeat-after-fix causes are missing."
}
$causeCounts = @{}
foreach ($causeCount in $metrics.causeCounts) {
    $causeCounts[[string]$causeCount.cause] = [int]$causeCount.events
}
foreach ($expectedCauseCount in @{
    "unsupported_content" = 1
    "invalid_diagram" = 2
    "repeat_after_fix" = 1
}.GetEnumerator()) {
    if (-not $causeCounts.ContainsKey($expectedCauseCount.Key) -or
        $causeCounts[$expectedCauseCount.Key] -ne $expectedCauseCount.Value) {
        throw "Cause aggregate '$($expectedCauseCount.Key)' is missing or incorrect."
    }
}
if (@($defectChain[0].firstOutput.sourceLinks) -cnotcontains "session-root-001#L3" -or
    @($defectChain[0].firstOutput.sourceLinks) -cnotcontains "session-root-001#L4") {
    throw "Duplicate message wrappers did not retain both source-line links."
}
$scopeLinks = @($scopeChain[0].sourceLinks)
$line7Index = [array]::IndexOf($scopeLinks, "session-root-001#L7")
$line10Index = [array]::IndexOf($scopeLinks, "session-root-001#L10")
if ($line7Index -lt 0 -or $line10Index -lt 0 -or $line7Index -gt $line10Index) {
    throw "Source line anchors are missing or not ordered by numeric line."
}

foreach ($forbidden in @(
    "northstar",
    "owner@example.com",
    "supersecret123",
    "hidden.person@example.com",
    "\\alice"
)) {
    if ($valid.text.IndexOf($forbidden, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        throw "Redacted audit output retained forbidden fixture value '$forbidden'."
    }
}
foreach ($placeholder in @(
    "[REDACTED:CUSTOMER]",
    "[REDACTED:EMAIL]",
    "[REDACTED:SECRET]",
    "[REDACTED:USER_HOME]"
)) {
    if ($valid.text.IndexOf($placeholder, [System.StringComparison]::Ordinal) -lt 0) {
        throw "Redacted audit output is missing placeholder '$placeholder'."
    }
}
if ($valid.text -match [regex]::Escape($Root)) {
    throw "Successful audit output exposed an absolute repository path."
}
if ([bool]$valid.result.privacy.rawContentIncluded -or
    $valid.result.privacy.sourcePathEmission -cne "source-id-only") {
    throw "Successful audit returned an unsafe privacy receipt."
}

$directPath = Join-Path $FixturesRoot "valid/direct-session.jsonl"
$direct = Invoke-Auditor -Arguments @("-SessionPath", $directPath)
if ($direct.exitCode -ne 0 -or
    $direct.result.status -cne "complete" -or
    $direct.result.metrics.observedChains -ne 1 -or
    $direct.result.chains[0].skill.version -cne "1.2.0") {
    throw "Explicit JSONL path mode did not produce the expected direct audit."
}

Assert-Blocked `
    -Arguments @(
        "-SessionPath",
        (Join-Path $FixturesRoot "malformed/malformed-json.jsonl")
    ) `
    -Code "JSONL_INVALID_JSON"
Assert-Blocked `
    -Arguments @(
        "-SessionPath",
        (Join-Path $FixturesRoot "malformed/unclassified-correction.jsonl")
    ) `
    -Code "REWORK_CLASSIFICATION_MISSING"
Assert-Blocked `
    -Arguments @(
        "-SessionPath",
        (Join-Path $FixturesRoot "malformed/undeclared-kind.jsonl")
    ) `
    -Code "SESSION_KIND_MISSING"
Assert-Blocked `
    -Arguments @(
        "-SessionPath",
        (Join-Path $FixturesRoot "malformed/repeat-without-fix.jsonl")
    ) `
    -Code "REPEAT_AFTER_FIX_SEQUENCE_INVALID"
Assert-Blocked `
    -Arguments @("-SessionPath", $FixturesRoot) `
    -Code "SESSION_PATH_INVALID"
Assert-Blocked `
    -Arguments @("-SessionPath", (Join-Path $FixturesRoot "*.jsonl")) `
    -Code "SESSION_PATH_INVALID"

$scriptErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseFile(
    $Auditor,
    [ref]$null,
    [ref]$scriptErrors
)
if ($scriptErrors.Count -gt 0) {
    throw "Session rework auditor has PowerShell syntax errors: $($scriptErrors -join '; ')."
}

Write-Host "OK session rework audit (determinism, classification, de-duplication, exclusion, redaction, and fail-closed cases)."
