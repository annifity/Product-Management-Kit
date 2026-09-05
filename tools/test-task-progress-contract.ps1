[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Read-RepoText {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $path = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing task-progress contract file: $RelativePath"
    }
    return [System.IO.File]::ReadAllText($path)
}

$requiredFiles = @(
    "_refs/operating-model/task-progress.md",
    "_refs/schemas/task-progress-state.md",
    "_refs/templates/docs/task-progress-checklist.md",
    "_refs/checklists/task-progress-quality.md",
    "tests/fixtures/task-progress/cases.json"
)
foreach ($file in $requiredFiles) {
    [void](Read-RepoText $file)
}

$operatingModel = Read-RepoText "_refs/operating-model/task-progress.md"
foreach ($term in @(
    "before the first tool call or mutation",
    "[ ] Pending",
    "[~] In progress",
    "[x] Completed",
    "[!] Blocked",
    "[-] Skipped",
    "observable evidence",
    "Do not republish unchanged state",
    "After interruption or context compaction",
    "does not imply that its gate passed",
    "Do not claim completion"
)) {
    if ($operatingModel.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Task-progress operating model is missing required behavior: $term"
    }
}

$schema = Read-RepoText "_refs/schemas/task-progress-state.md"
foreach ($term in @(
    "pending | in_progress | completed | blocked | skipped",
    "completed_with_skips",
    "non-empty evidence",
    'concrete `blocker` and `next_action`',
    "stable",
    "timestamps",
    "lifecycle-gate approval"
)) {
    if ($schema.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Task-progress state schema is missing invariant: $term"
    }
}

$quality = Read-RepoText "_refs/checklists/task-progress-quality.md"
foreach ($term in @("Claude Code", "Codex", "GitHub Copilot", "Cursor", "Markdown-only", "native task tool")) {
    if ($quality.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Task-progress quality gate is missing portability coverage: $term"
    }
}

$fixture = (Read-RepoText "tests/fixtures/task-progress/cases.json") | ConvertFrom-Json
$caseIds = @($fixture.cases | ForEach-Object { $_.caseId })
$requiredCases = @(
    "multi-step-prd",
    "discovery-to-spec",
    "multi-file-audit",
    "blocked-task",
    "plan-change",
    "interruption-recovery",
    "simple-question",
    "small-one-step-edit",
    "gate-boundary",
    "completion-without-evidence",
    "unchanged-status",
    "business-facing-summary"
)
foreach ($caseId in $requiredCases) {
    if ($caseIds -notcontains $caseId) {
        throw "Task-progress semantic suite is missing case: $caseId"
    }
}
if (@($caseIds | Select-Object -Unique).Count -ne $caseIds.Count) {
    throw "Task-progress semantic suite contains duplicate case IDs."
}
if (@($fixture.cases | Where-Object { $_.category -eq "positive" }).Count -lt 6) {
    throw "Task-progress semantic suite must include at least six positive cases."
}
if (@($fixture.cases | Where-Object { $_.category -eq "negative" }).Count -lt 6) {
    throw "Task-progress semantic suite must include at least six negative cases."
}
foreach ($case in $fixture.cases) {
    if ([string]::IsNullOrWhiteSpace([string]$case.prompt) -or @($case.requiredBehavior).Count -eq 0) {
        throw "Task-progress semantic case '$($case.caseId)' lacks a prompt or observable behavior."
    }
}

$expectedPlatforms = @("Claude Code", "Codex", "GitHub Copilot", "Cursor", "Markdown-only runtime")
foreach ($platform in $expectedPlatforms) {
    if (@($fixture.platforms) -notcontains $platform) {
        throw "Task-progress semantic suite is missing platform: $platform"
    }
}

foreach ($instructionFile in @("AGENTS.md", "CLAUDE.md", ".github/copilot-instructions.md", ".cursor/rules/annifity-index.mdc")) {
    $text = Read-RepoText $instructionFile
    foreach ($term in @("_refs/operating-model/task-progress.md", "before execution", "one-step", "gate")) {
        if ($text.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "$instructionFile is missing task-progress runtime behavior: $term"
        }
    }
}

$authoring = Read-RepoText "_refs/operating-model/skill-authoring.md"
foreach ($term in @("completion evidence", "blocker representation", "runtime-portability")) {
    if ($authoring.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Skill authoring standard is missing task-progress requirement: $term"
    }
}

Write-Host "OK task-progress contract and semantic fixtures passed ($($fixture.cases.Count) cases, $($fixture.platforms.Count) platforms)."
