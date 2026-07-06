[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ExpectedSkills = @(
    "brief",
    "change",
    "discovery",
    "docs",
    "execution",
    "experiment",
    "knowledge",
    "learn",
    "memories",
    "plan",
    "prd",
    "prototype",
    "ship",
    "spec",
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

$adapterRoots = @(
    ".claude/skills",
    ".codex/skills",
    ".github/skills",
    ".agents/skills"
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
foreach ($needle in @("tools/check-self-contained.ps1", "tools/sync-ai-skill-structures.ps1", "tools/test-annifity.ps1")) {
    if ($preCommitText -notmatch [regex]::Escape($needle)) {
        throw "tools/pre-commit-annifity.ps1 does not run $needle."
    }
}

Write-Host "OK Annifity structure self-test passed ($($ExpectedSkills.Count) skills)."
