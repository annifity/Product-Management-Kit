[CmdletBinding()]
param(
    [string[]]$Files
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ScanRoots = @(
    (Join-Path $Root "skills"),
    (Join-Path $Root "_refs"),
    (Join-Path $Root "README.md")
)

function ConvertTo-RepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $fullPath = (Resolve-Path -LiteralPath $Path).Path
    return $fullPath.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
}

function Test-ScannableFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = $Path.Replace("\", "/")
    return ($normalized.EndsWith(".md") -or $normalized.EndsWith(".html")) -and
        (($normalized -match "(^|/)skills/") -or
         ($normalized -match "(^|/)_refs/") -or
         ($normalized.EndsWith("/README.md")))
}

if ($Files -and $Files.Count -gt 0) {
    $targets = @($Files | Where-Object { Test-Path -LiteralPath $_ } | Where-Object { Test-ScannableFile $_ })
}
else {
    $targets = @(
        foreach ($rootPath in $ScanRoots) {
            if (-not (Test-Path -LiteralPath $rootPath)) { continue }
            $item = Get-Item -LiteralPath $rootPath
            if ($item.PSIsContainer) {
                Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Include "*.md", "*.html" |
                    Select-Object -ExpandProperty FullName
            }
            else {
                $item.FullName
            }
        }
    )
}

$missing = @()
$refsUsedBySkills = @{}
$allRefFiles = @{}
$foundationalRefs = @(
    "_refs/integrations/claude.md",
    "_refs/integrations/codex.md",
    "_refs/integrations/copilot.md",
    "_refs/integrations/cursor.md",
    "_refs/operating-model/annifity-principles.md",
    "_refs/operating-model/language-policy.md"
)

Get-ChildItem -LiteralPath (Join-Path $Root "_refs") -Recurse -File |
    ForEach-Object {
        $allRefFiles[(ConvertTo-RepoPath $_.FullName)] = $true
    }

foreach ($file in $targets) {
    $content = [System.IO.File]::ReadAllText($file)
    $repoPath = ConvertTo-RepoPath $file
    foreach ($match in [regex]::Matches($content, "_refs/[A-Za-z0-9_./-]+")) {
        $ref = $match.Value.TrimEnd(".", ",", ":", ";", ")", "]", "'", '"')
        if ([string]::IsNullOrWhiteSpace($ref)) { continue }

        $fullRef = Join-Path $Root ($ref.Replace("/", [System.IO.Path]::DirectorySeparatorChar))
        if (-not (Test-Path -LiteralPath $fullRef)) {
            $missing += "$repoPath -> $ref"
            continue
        }

        if ($repoPath -match "^skills/") {
            $refsUsedBySkills[$ref] = $true
        }
    }
}

if ($missing.Count -gt 0) {
    Write-Host "X ref integrity failed - missing referenced files or directories:" -ForegroundColor Red
    foreach ($item in ($missing | Sort-Object -Unique)) {
        Write-Host "  - $item" -ForegroundColor Red
    }
    exit 1
}

$unused = @(
    $allRefFiles.Keys |
        Where-Object { $_ -notmatch "^_refs/index\.md$" } |
        Where-Object { $foundationalRefs -notcontains $_ } |
        Where-Object { -not $refsUsedBySkills.ContainsKey($_) } |
        Sort-Object
)

if ($unused.Count -gt 0) {
    Write-Host "WARN ref integrity: $($unused.Count) _refs file(s) are not directly referenced by a skill."
}

Write-Host "OK ref integrity ($($targets.Count) file(s) scanned, no missing _refs links)."
