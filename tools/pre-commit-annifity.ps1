[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$GuardScript = Join-Path $Root "tools/check-self-contained.ps1"
$SyncScript = Join-Path $Root "tools/sync-ai-skill-structures.ps1"
$TestScript = Join-Path $Root "tools/test-annifity.ps1"

& $GuardScript
& $SyncScript
& $TestScript

git -C $Root add -A -- `
    AGENTS.md `
    CLAUDE.md `
    .claude-plugin/plugin.json `
    .claude/skills `
    .github/copilot-instructions.md `
    .github/skills `
    .cursor/rules `
    .agents/skills `
    .codex/skills

Write-Host "OK Annifity pre-commit sync, guard, self-test, and staging completed."
