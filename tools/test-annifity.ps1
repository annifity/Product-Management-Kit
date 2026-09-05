[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PowerShell = (Get-Process -Id $PID).Path
$ExpectedSkills = @(
    "analytics",
    "brief",
    "change",
    "commercial",
    "competitive-intelligence",
    "design",
    "discovery",
    "docs",
    "execution",
    "experiment",
    "growth",
    "gtm",
    "knowledge",
    "learn",
    "memories",
    "plan",
    "prd",
    "prototype",
    "prioritize",
    "ship",
    "spec",
    "strategy",
    "uat",
    "validate",
    "user-story"
)

function ConvertTo-RepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $fullPath = (Resolve-Path -LiteralPath $Path).Path
    return $fullPath.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
}

function Assert-EqualList {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string[]]$Actual
    )

    $expectedText = ($Expected | Sort-Object) -join "`n"
    $actualText = ($Actual | Sort-Object) -join "`n"
    if ($expectedText -ne $actualText) {
        throw "$Label mismatch.`nExpected:`n$expectedText`nActual:`n$actualText"
    }
}

$skillsRoot = Join-Path $Root "skills"
if (-not (Test-Path -LiteralPath $skillsRoot)) {
    throw "Missing skills directory."
}

$canonicalDirs = Get-ChildItem -LiteralPath $skillsRoot -Directory |
    Select-Object -ExpandProperty Name
Assert-EqualList -Label "Canonical skill directories" -Expected $ExpectedSkills -Actual $canonicalDirs

$canonicalSkillFiles = Get-ChildItem -LiteralPath $skillsRoot -Recurse -Filter "SKILL.md" -File
$canonicalSkillRelPaths = @($canonicalSkillFiles | ForEach-Object { ConvertTo-RepoPath $_.FullName })
$expectedSkillRelPaths = @($ExpectedSkills | ForEach-Object { "skills/$_/SKILL.md" })
Assert-EqualList -Label "Canonical SKILL.md files" -Expected $expectedSkillRelPaths -Actual $canonicalSkillRelPaths

$phaseGateSkills = @("brief", "design", "discovery", "execution", "experiment", "learn", "plan", "prototype", "ship", "spec", "strategy", "validate")
foreach ($skill in $ExpectedSkills) {
    $skillText = [System.IO.File]::ReadAllText((Join-Path $skillsRoot "$skill/SKILL.md"))
    if ($skillText -notmatch "(?m)^## Input Contract\s*$") {
        throw "Canonical skill '$skill' must declare an explicit Input Contract."
    }
    if ($skillText -notmatch "(?m)^## Output\s*$") {
        throw "Canonical skill '$skill' must declare an explicit Output contract."
    }
    if ($skillText -notmatch "(?m)^## Handoff\s*$") {
        throw "Canonical skill '$skill' must declare an explicit Handoff."
    }
    if ($phaseGateSkills -contains $skill -and $skillText -notmatch [regex]::Escape("_refs/operating-model/phase-gates.md")) {
        throw "Lifecycle skill '$skill' must route directly to _refs/operating-model/phase-gates.md."
    }
}

$jiraIntegrationText = [System.IO.File]::ReadAllText((Join-Path $Root "_refs/integrations/jira.md"))
foreach ($pattern in @("(?i)preview", "(?i)explicit (user )?approval", "(?i)not approval", "(?i)create.*update.*bulk")) {
    if ($jiraIntegrationText -notmatch $pattern) {
        throw "Jira integration is missing the external-mutation safety contract: $pattern"
    }
}

$specText = [System.IO.File]::ReadAllText((Join-Path $skillsRoot "spec/SKILL.md"))
if ($specText -notmatch '(?i)stop and route to `discovery`') {
    throw "Spec must stop and route an unconfirmed raw ask to discovery."
}

$shipText = [System.IO.File]::ReadAllText((Join-Path $skillsRoot "ship/SKILL.md"))
foreach ($pattern in @("(?i)named owner", "(?i)explicit user approval")) {
    if ($shipText -notmatch $pattern) {
        throw "Ship is missing a release-safety gate: $pattern"
    }
}

$adapterRoots = @(
    ".claude/skills",
    ".codex/skills",
    ".github/skills"
)

foreach ($adapterRoot in $adapterRoots) {
    $fullRoot = Join-Path $Root $adapterRoot
    if (-not (Test-Path -LiteralPath $fullRoot)) {
        throw "Missing generated adapter root: $adapterRoot"
    }

    $adapterDirs = Get-ChildItem -LiteralPath $fullRoot -Directory |
        Select-Object -ExpandProperty Name
    Assert-EqualList -Label "$adapterRoot skill adapters" -Expected $ExpectedSkills -Actual $adapterDirs

    foreach ($skill in $ExpectedSkills) {
        $adapterSkill = Join-Path $fullRoot "$skill/SKILL.md"
        if (-not (Test-Path -LiteralPath $adapterSkill)) {
            throw "Missing generated adapter: $adapterRoot/$skill/SKILL.md"
        }
    }
}

if (Test-Path -LiteralPath (Join-Path $Root ".agents/skills")) {
    throw ".agents/skills duplicates the explicit .codex skill surface and must not be generated."
}

$cursorRoot = Join-Path $Root ".cursor/rules"
if (-not (Test-Path -LiteralPath $cursorRoot)) {
    throw "Missing Cursor rules directory."
}

$cursorRules = Get-ChildItem -LiteralPath $cursorRoot -Filter "annifity-*.mdc" -File |
    Where-Object { $_.Name -ne "annifity-index.mdc" } |
    ForEach-Object { $_.BaseName -replace "^annifity-", "" }
Assert-EqualList -Label "Cursor skill rules" -Expected $ExpectedSkills -Actual @($cursorRules)

$lefthookConfig = Join-Path $Root "lefthook.yml"
if (-not (Test-Path -LiteralPath $lefthookConfig)) {
    throw "Missing lefthook.yml."
}

$lefthookText = [System.IO.File]::ReadAllText($lefthookConfig)
if ($lefthookText -notmatch [regex]::Escape("tools/pre-commit-annifity.ps1")) {
    throw "lefthook.yml does not run tools/pre-commit-annifity.ps1."
}

$preCommitScript = Join-Path $Root "tools/pre-commit-annifity.ps1"
if (-not (Test-Path -LiteralPath $preCommitScript)) {
    throw "Missing tools/pre-commit-annifity.ps1."
}

$preCommitText = [System.IO.File]::ReadAllText($preCommitScript)
foreach ($needle in @("tools/check-self-contained.ps1", "tools/test-skill-format.ps1", "tools/test-skill-routing.ps1", "tools/sync-ai-skill-structures.ps1", "tools/test-annifity.ps1")) {
    if ($preCommitText -notmatch [regex]::Escape($needle)) {
        throw "tools/pre-commit-annifity.ps1 does not run $needle."
    }
}

$requiredProductBuilderFiles = @(
    ".github/workflows/check.yml",
    ".github/workflows/deploy-docs.yml",
    "_refs/operating-model/routing.md",
    "_refs/operating-model/builder-packs.md",
    "_refs/checklists/stakeholder-governance.md",
    "_refs/checklists/security-privacy-accessibility.md",
    "examples/end-to-end/product-builder-kit-example.md",
    "tools/check-ref-integrity.ps1",
    "tools/test-skill-format.ps1",
    "tools/test-skill-routing.ps1",
    "tools/test-skill-contracts.ps1",
    "tools/resolve-artifact-profile.ps1",
    "tools/test-artifact-profile-resolution.ps1",
    "tools/resolve-authoritative-baseline.ps1",
    "tools/test-authoritative-baseline.ps1",
    "tools/new-artifact-registry-migration.ps1",
    "tools/test-artifact-registry-migration.ps1",
    "tools/test-negative-completeness.ps1",
    "tools/new-mutation-preview.ps1",
    "tools/confirm-mutation-preview.ps1",
    "tools/verify-mutation-result.ps1",
    "tools/test-mutation-safety.ps1",
    "_refs/schemas/artifact-generation-contract.md",
    "_refs/operating-model/artifact-profile-resolution.md",
    "_refs/schemas/artifact-state-registry.md",
    "_refs/operating-model/authoritative-baseline-resolution.md",
    "_refs/checklists/material-decision-preflight.md",
    "_refs/checklists/source-backed-minimality.md",
    "_refs/checklists/negative-completeness.md",
    "_refs/workflows/local-mutation-safety.md",
    "_refs/schemas/mutation-preview.md",
    "_refs/templates/docs/generation-receipt.md",
    "_refs/schemas/session-rework-observation.md",
    "_refs/schemas/semantic-forward-test.md",
    "_refs/schemas/skill-output-contract.md",
    "_refs/schemas/first-pass-quality-dashboard.md",
    "_refs/schemas/drawio-validation-manifest.md",
    "_refs/schemas/context-consistency-manifest.md",
    "_refs/operating-model/phase-gates.md",
    "_refs/schemas/initiative-state.md",
    "_refs/workflows/spec-to-design.md",
    "_refs/schemas/design-contract.md",
    "_refs/schemas/design-artifact-manifest.md",
    "_refs/checklists/design-readiness.md",
    "_refs/checklists/design-quality.md",
    "_refs/templates/design/design-handoff.md",
    "_refs/templates/design/portable-html.html",
    "tools/new-design-package.ps1",
    "tools/validate-design-package.ps1",
    "tools/test-design-package.ps1",
    "tools/calculate-finance-metrics.ps1",
    "tools/estimate-experiment-sample.ps1",
    "tools/test-pm-calculators.ps1",
    "tools/test-pm-decision-quality.ps1",
    "tools/test-task-progress-contract.ps1",
    "tests/fixtures/task-progress/cases.json",
    "_refs/operating-model/task-progress.md",
    "_refs/schemas/task-progress-state.md",
    "_refs/templates/docs/task-progress-checklist.md",
    "_refs/checklists/task-progress-quality.md",
    "_refs/operating-model/artifact-quality-system.md",
    "_refs/operating-model/methodology-catalog.md",
    "_refs/workflows/pm-decision-challenge.md",
    "_refs/checklists/pm-decision-quality.md",
    "tools/audit-session-rework.ps1",
    "tools/test-session-rework-audit.ps1",
    "tools/new-semantic-forward-run.ps1",
    "tools/new-semantic-forward-evaluator-task.ps1",
    "tools/evaluate-semantic-forward-run.ps1",
    "tools/test-semantic-forward-harness.ps1",
    "tools/test-output-contract-conformance.ps1",
    "tools/build-first-pass-quality-dashboard.ps1",
    "tools/test-first-pass-quality-dashboard.ps1",
    "tools/validate-drawio.ps1",
    "tools/test-drawio-validation.ps1",
    "tools/lint-context-consistency.ps1",
    "tools/test-context-consistency-linter.ps1",
    "tools/phase-gate-approval-attestation.psm1",
    "tools/resolve-phase-gate-approval.ps1",
    "tools/sign-phase-gate-approval.ps1",
    "tools/test-phase-gate-approval.ps1",
    "tools/repo-root-manifest.schema.json",
    "tools/repo-root-manifest.json",
    "tools/invoke-repo-doctor.ps1",
    "tools/test-repo-doctor.ps1",
    "tests/fixtures/routing/skill-routing-cases.json",
    "tools/init-annifity-workspace.ps1",
    "docs/data/catalog.js"
)

foreach ($relativePath in $requiredProductBuilderFiles) {
    $fullPath = Join-Path $Root $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing Product Builder Kit file: $relativePath"
    }
}

$hasPackageLock = Test-Path -LiteralPath (Join-Path $Root "package-lock.json")
foreach ($workflow in @(".github/workflows/check.yml", ".github/workflows/deploy-docs.yml")) {
    $workflowText = [System.IO.File]::ReadAllText((Join-Path $Root $workflow))
    if (-not $hasPackageLock -and $workflowText -match "\bnpm ci\b") {
        throw "$workflow must not use npm ci without package-lock.json."
    }
    if (-not $hasPackageLock -and $workflowText -match "\bnpm install\b" -and $workflowText -notmatch "--no-package-lock") {
        throw "$workflow must use npm install --no-package-lock when package-lock.json is absent."
    }
    if ($hasPackageLock -and $workflowText -notmatch "\bnpm ci\b") {
        throw "$workflow must use npm ci when package-lock.json is present."
    }
}

$packageJsonPath = Join-Path $Root "package.json"
$packageJson = Get-Content -Raw -LiteralPath $packageJsonPath | ConvertFrom-Json
if ($packageJson.description -notmatch "Product Builder Kit") {
    throw "package.json description must position Annifity as a Product Builder Kit."
}

$requiredScripts = @(
    "skill:validate",
    "ref:check",
    "routing:test",
    "sync:check",
    "contract:test",
    "profile:test",
    "baseline:test",
    "registry-migration:test",
    "mutation:test",
    "design:test",
    "pm-calculators:test",
    "pm-quality:test",
    "task-progress:test",
    "p0:test",
    "session-audit:test",
    "semantic:test",
    "output-contract:test",
    "drawio:test",
    "context:test",
    "p1:test",
    "phase-gate:test",
    "repo-doctor:test",
    "dashboard:test",
    "p2:test",
    "doctor",
    "workspace:init"
)
foreach ($scriptName in $requiredScripts) {
    if (-not ($packageJson.scripts.PSObject.Properties.Name -contains $scriptName)) {
        throw "package.json missing script: $scriptName"
    }
}

$readmePath = Join-Path $Root "README.md"
$readmeText = [System.IO.File]::ReadAllText($readmePath)
foreach ($needle in @("Product Builder Kit", "Builder Packs", "Build Handoff Pack", "Release Pack")) {
    if ($readmeText -notmatch [regex]::Escape($needle)) {
        throw "README.md missing Product Builder Kit positioning text: $needle"
    }
}

foreach ($instructionFile in @("README.md", "AGENTS.md", "CLAUDE.md")) {
    $instructionText = [System.IO.File]::ReadAllText((Join-Path $Root $instructionFile))
    if ($instructionText -match [regex]::Escape(".agents/skills")) {
        throw "$instructionFile still advertises the deprecated duplicate .agents/skills adapter root."
    }
    if ($instructionText -notmatch "project-local") {
        throw "$instructionFile must explain that generated adapters are project-local."
    }
}

foreach ($userFacingInstruction in @("AGENTS.md", "CLAUDE.md", ".github/copilot-instructions.md")) {
    $instructionText = [System.IO.File]::ReadAllText((Join-Path $Root $userFacingInstruction))
    foreach ($requiredBoundary in @(
        "generation result",
        "machine audit details",
        "plain language",
        "explicit"
    )) {
        if ($instructionText -notmatch [regex]::Escape($requiredBoundary)) {
            throw "$userFacingInstruction is missing the user-facing technical boundary: $requiredBoundary"
        }
    }
}

$docsIndexPath = Join-Path $Root "docs/index.html"
$docsIndexText = [System.IO.File]::ReadAllText($docsIndexPath)
foreach ($needle in @("Product Builder Kit", "Builder packs", "GitHub Pages", "skillCount", "data/catalog.js")) {
    if ($docsIndexText -notmatch [regex]::Escape($needle)) {
        throw "docs/index.html missing expected Product Builder Kit docs text: $needle"
    }
}

foreach ($staleValue in @(">13<", ">86<", ">10<", ">0<")) {
    if ($docsIndexText -match [regex]::Escape($staleValue)) {
        throw "docs/index.html still contains stale hardcoded catalog value: $staleValue"
    }
}

foreach ($mustNotBeIgnored in @("docs/data/catalog.js", "tests/fixtures/routing/skill-routing-cases.json", "skills/docs/SKILL.md", "_refs/templates/docs/docs-index.md")) {
    & git -C $Root check-ignore --no-index -q $mustNotBeIgnored
    if ($LASTEXITCODE -eq 0) {
        throw "$mustNotBeIgnored must not be ignored."
    }
    $global:LASTEXITCODE = 0
}

foreach ($needle in @("tools/build-docs-site.ps1", "tools/check-ref-integrity.ps1", "tools/test-skill-format.ps1", "tools/test-skill-routing.ps1", "docs/data/catalog.js")) {
    if ($preCommitText -notmatch [regex]::Escape($needle)) {
        throw "tools/pre-commit-annifity.ps1 missing Product Builder Kit precommit step/path: $needle"
    }
}

$catalogPath = Join-Path $Root "docs/data/catalog.js"
$catalogText = [System.IO.File]::ReadAllText($catalogPath)
if ($catalogText.Contains("`r`n")) {
    throw "docs/data/catalog.js must use LF line endings so generated docs stay deterministic."
}
$catalogMatch = [regex]::Match($catalogText, "(?s)^window\.ANNIFITY_CATALOG\s*=\s*(.+);\s*$")
if (-not $catalogMatch.Success) {
    throw "docs/data/catalog.js must assign window.ANNIFITY_CATALOG."
}

$catalog = $catalogMatch.Groups[1].Value | ConvertFrom-Json
if ($catalog.summary.skillCount -ne $ExpectedSkills.Count) {
    throw "Catalog skillCount $($catalog.summary.skillCount) does not match expected $($ExpectedSkills.Count)."
}
if ($catalog.summary.workflowCount -lt 17) {
    throw "Catalog workflowCount should include all workflow refs."
}
if ($catalog.summary.templateCount -lt 60) {
    throw "Catalog templateCount should include template refs."
}

& (Join-Path $Root "tools/check-ref-integrity.ps1")
& (Join-Path $Root "tools/test-skill-format.ps1")
& (Join-Path $Root "tools/check-ref-integrity.ps1") -Files (Join-Path $Root "skills/discovery/SKILL.md")
$routingTestScript = Join-Path $Root "tools/test-skill-routing.ps1"
& $routingTestScript

# Prove that prompt text is part of the routing contract rather than decorative fixture data.
$routingFixturePath = Join-Path $Root "tests/fixtures/routing/skill-routing-cases.json"
$mutatedRoutingFixturePath = Join-Path ([System.IO.Path]::GetTempPath()) ("annifity-routing-{0}.json" -f [guid]::NewGuid().ToString("N"))
try {
    $mutatedRoutingFixture = Get-Content -Raw -LiteralPath $routingFixturePath -Encoding UTF8 | ConvertFrom-Json
    $mutatedRoutingFixture.cases[0].prompt = "Rotate database encryption keys for a staging cluster tonight."
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText(
        $mutatedRoutingFixturePath,
        ($mutatedRoutingFixture | ConvertTo-Json -Depth 12),
        $utf8NoBom
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & $PowerShell -NoProfile -ExecutionPolicy Bypass -File $routingTestScript -FixturePath $mutatedRoutingFixturePath 1>$null 2>$null
    $mutatedRoutingExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    $global:LASTEXITCODE = 0
    if ($mutatedRoutingExitCode -eq 0) {
        throw "Routing preflight must reject an unrelated prompt even when fixture metadata remains valid."
    }
}
finally {
    if (Test-Path -LiteralPath $mutatedRoutingFixturePath) {
        Remove-Item -LiteralPath $mutatedRoutingFixturePath -Force
    }
}
& (Join-Path $Root "tools/test-skill-contracts.ps1")
& (Join-Path $Root "tools/test-output-contract-conformance.ps1")
& (Join-Path $Root "tools/test-pm-calculators.ps1")
& (Join-Path $Root "tools/test-pm-decision-quality.ps1")
& (Join-Path $Root "tools/test-task-progress-contract.ps1")
& (Join-Path $Root "tools/test-artifact-profile-resolution.ps1")
& (Join-Path $Root "tools/test-authoritative-baseline.ps1")
& (Join-Path $Root "tools/test-artifact-registry-migration.ps1")
& (Join-Path $Root "tools/test-mutation-safety.ps1")
& (Join-Path $Root "tools/test-design-package.ps1")
& (Join-Path $Root "tools/test-session-rework-audit.ps1")
& (Join-Path $Root "tools/test-semantic-forward-harness.ps1")
& (Join-Path $Root "tools/test-semantic-forward-live.ps1")
& (Join-Path $Root "tools/test-first-pass-quality-dashboard.ps1")
& (Join-Path $Root "tools/test-drawio-validation.ps1")
& (Join-Path $Root "tools/test-context-consistency-linter.ps1")
& (Join-Path $Root "tools/test-phase-gate-approval.ps1")
& (Join-Path $Root "tools/test-ai-evaluation-verdict.ps1")
& (Join-Path $Root "tools/test-repo-doctor.ps1")

Write-Host "OK Annifity structure self-test passed ($($ExpectedSkills.Count) skills)."
