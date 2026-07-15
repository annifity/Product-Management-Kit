[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$GuardScript = Join-Path $Root "tools/check-self-contained.ps1"
$SkillFormatTestScript = Join-Path $Root "tools/test-skill-format.ps1"
$RefCheckScript = Join-Path $Root "tools/check-ref-integrity.ps1"
$RoutingTestScript = Join-Path $Root "tools/test-skill-routing.ps1"
$SyncScript = Join-Path $Root "tools/sync-ai-skill-structures.ps1"
$DocsBuildScript = Join-Path $Root "tools/build-docs-site.ps1"
$ContractTestScript = Join-Path $Root "tools/test-skill-contracts.ps1"
$TestScript = Join-Path $Root "tools/test-annifity.ps1"

& $GuardScript
& $SkillFormatTestScript
& $RefCheckScript
& $RoutingTestScript
& $SyncScript
& $DocsBuildScript
& $ContractTestScript
& $TestScript

git -C $Root add -A -- `
    AGENTS.md `
    CLAUDE.md `
    .claude-plugin/plugin.json `
    .claude/skills `
    .github/copilot-instructions.md `
    .github/workflows `
    .github/skills `
    .cursor/rules `
    .codex/skills `
    docs/data/catalog.js

# Stage the one-time removal if an older checkout still tracks the deprecated
# duplicate adapter root. Avoid an unmatched pathspec after the migration lands.
$trackedDeprecatedAdapters = @(git -C $Root ls-files -- .agents/skills)
if ($trackedDeprecatedAdapters.Count -gt 0) {
    git -C $Root add -A -- .agents/skills
}

Write-Host "OK Annifity pre-commit sync, guard, self-test, and staging completed."
