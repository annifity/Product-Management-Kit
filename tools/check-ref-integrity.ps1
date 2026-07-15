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
Get-ChildItem -LiteralPath (Join-Path $Root "_refs") -Recurse -File |
    ForEach-Object {
        $allRefFiles[(ConvertTo-RepoPath $_.FullName)] = $true
    }

# Orphan detection is repository-wide even when -Files limits missing-link checks.
# Build direct inbound routes from every canonical skill so incremental runs do not
# report valid references as orphaned merely because their owning skill was omitted.
Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Directory |
    ForEach-Object {
        $skillPath = Join-Path $_.FullName "SKILL.md"
        if (-not (Test-Path -LiteralPath $skillPath)) { return }

        $skillContent = [System.IO.File]::ReadAllText($skillPath)
        foreach ($match in [regex]::Matches($skillContent, "_refs/[A-Za-z0-9_./-]+")) {
            $ref = $match.Value.TrimEnd(".", ",", ":", ";", ")", "]", "'", '"')
            if (-not [string]::IsNullOrWhiteSpace($ref)) {
                $refsUsedBySkills[$ref] = $true
            }
        }
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
        Where-Object { -not $refsUsedBySkills.ContainsKey($_) } |
        Sort-Object
)

if ($unused.Count -gt 0) {
    Write-Host "X ref integrity failed - $($unused.Count) _refs file(s) have no direct canonical skill route:" -ForegroundColor Red
    foreach ($item in $unused) {
        Write-Host "  - $item" -ForegroundColor Red
    }
    exit 1
}

Write-Host "OK ref integrity ($($targets.Count) file(s) scanned, no missing _refs links)."
