[CmdletBinding()]
param(
    # Optional explicit file list; when omitted, scans all *.md under skills/ and _refs/.
    [string[]]$Files
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Self-containment guard. The whole point of Annifity is that it installs and runs on its
# own — a user must never have to download some OTHER skill repo to make it work. This
# catches the common way that breaks: a skill or workflow telling the model to invoke a
# skill / command / CLI that lives in a different, separately-installed package.
#
# If you legitimately need one of these, bundle its content into skills/ or _refs/ and
# reference the bundled copy instead.

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ScanRoots = @((Join-Path $Root "skills"), (Join-Path $Root "_refs"))

# Each rule: a human label + a regex matching a reference to something OUTSIDE Annifity.
# Patterns are deliberately narrow (require a namespace colon, slash, or a known external
# repo/CLI token) so ordinary prose like "Design: Figma link" is never flagged.
$Rules = @(
    @{ Label = "external plugin skill (superpowers:)";              Pattern = "superpowers:[a-z-]+" }
    @{ Label = "external plugin skill (caveman:)";                  Pattern = "caveman:[a-z-]+" }
    @{ Label = "external plugin skill (skill-creator)";             Pattern = "\bskill-creator\b" }
    @{ Label = "external slash-skill (/design:*)";                  Pattern = "/design:[a-z-]+" }
    @{ Label = "external slash-skill (/product-management:*)";      Pattern = "/product-management:[a-z-]+" }
    @{ Label = "external workflow command (opsx:)";                 Pattern = "opsx:[a-z-]+" }
    @{ Label = "external skill repo (Product-Manager-Skills-main)"; Pattern = "Product-Manager-Skills-main" }
    @{ Label = "external skill repo (agentic-product-manager)";     Pattern = "agentic-product-manager" }
    @{ Label = "author-specific path (.templates/anniefunny)";      Pattern = "\.templates/anniefunny" }
    @{ Label = "external CLI dependency (openspec)";                Pattern = "\bopenspec\b" }
)

function Test-InScan {
    param([string]$Path)
    $u = $Path.Replace("\", "/")
    return ($u.EndsWith(".md")) -and (($u -match "(^|/)skills/") -or ($u -match "(^|/)_refs/"))
}

if ($Files -and $Files.Count -gt 0) {
    $targets = $Files | Where-Object { Test-InScan $_ }
}
else {
    $targets = $ScanRoots |
        Where-Object { Test-Path -LiteralPath $_ } |
        ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -Filter "*.md" -File } |
        Select-Object -ExpandProperty FullName
}

$hits = @()
foreach ($file in $targets) {
    if (-not (Test-Path -LiteralPath $file)) { continue }
    $lineNo = 0
    foreach ($line in [System.IO.File]::ReadAllLines($file)) {
        $lineNo++
        foreach ($rule in $Rules) {
            $m = [regex]::Match($line, $rule.Pattern)
            if ($m.Success) {
                $hits += "{0}:{1}: {2} -> `"{3}`"" -f $file, $lineNo, $rule.Label, $m.Value
            }
        }
    }
}

if ($hits.Count -gt 0) {
    Write-Host "X external-dependency guard failed - these reference something outside Annifity:" -ForegroundColor Red
    foreach ($h in $hits) { Write-Host "  - $h" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Fix: bundle the dependency (clone its content into skills/ or _refs/) and reference the bundled copy."
    exit 1
}

$count = @($targets).Count
Write-Host "OK self-contained ($count file(s) scanned, no external skill deps)."
