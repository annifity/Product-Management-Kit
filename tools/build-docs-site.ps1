[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$DocsData = Join-Path $Root "docs/data"
$CatalogPath = Join-Path $DocsData "catalog.js"

if (-not (Test-Path -LiteralPath $DocsData)) {
    New-Item -ItemType Directory -Path $DocsData | Out-Null
}

function ConvertTo-RepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Resolve-Path -LiteralPath $Path).Path.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
}

function Read-Text {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.File]::ReadAllText($Path, $Utf8NoBom)
}

function Get-ScalarValue {
    param([Parameter(Mandatory = $true)][string]$Value)
    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2) {
        if (($trimmed.StartsWith("'")) -and ($trimmed.EndsWith("'"))) {
            return $trimmed.Substring(1, $trimmed.Length - 2).Replace("''", "'")
        }
        if (($trimmed.StartsWith('"')) -and ($trimmed.EndsWith('"'))) {
            return $trimmed.Substring(1, $trimmed.Length - 2).Replace('\"', '"')
        }
    }
    return $trimmed
}

function Get-SkillMetadata {
    param([Parameter(Mandatory = $true)][string]$Path)

    $content = (Read-Text -Path $Path) -replace "`r`n", "`n"
    $lines = $content -split "`n"
    if ($lines.Count -lt 3 -or $lines[0].Trim() -ne "---") {
        throw "Missing YAML frontmatter: $(ConvertTo-RepoPath $Path)"
    }

    $endIndex = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq "---") {
            $endIndex = $i
            break
        }
    }
    if ($endIndex -lt 0) {
        throw "Unclosed YAML frontmatter: $(ConvertTo-RepoPath $Path)"
    }

    $name = $null
    $description = $null
    for ($i = 1; $i -lt $endIndex; $i++) {
        $line = $lines[$i]
        if ($line -match "^\s*name\s*:\s*(.+?)\s*$") {
            $name = Get-ScalarValue $Matches[1]
        }
        elseif ($line -match "^\s*description\s*:\s*(.+?)\s*$") {
            $description = Get-ScalarValue $Matches[1]
        }
    }

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($description)) {
        throw "Missing name or description in $(ConvertTo-RepoPath $Path)"
    }

    $refs = @()
    foreach ($match in [regex]::Matches($content, "_refs/[A-Za-z0-9_./-]+")) {
        $ref = $match.Value.TrimEnd(".")
        if ($ref -notmatch "/$" -and -not ($refs -contains $ref)) {
            $refs += $ref
        }
    }

    return [ordered]@{
        name = $name
        description = $description
        source = ConvertTo-RepoPath $Path
        references = @($refs | Sort-Object)
    }
}

function Get-CatalogGeneratedAt {
    if ($env:ANNIFITY_CATALOG_TIMESTAMP) {
        return $env:ANNIFITY_CATALOG_TIMESTAMP
    }

    if (Test-Path -LiteralPath $CatalogPath) {
        $existing = [System.IO.File]::ReadAllText($CatalogPath, $Utf8NoBom)
        $match = [regex]::Match($existing, '"generatedAt"\s*:\s*"([^"]+)"')
        if ($match.Success) {
            return $match.Groups[1].Value
        }
    }

    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$skillsRoot = Join-Path $Root "skills"
$skillFiles = Get-ChildItem -LiteralPath $skillsRoot -Directory |
    ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Filter "SKILL.md" -File } |
    Sort-Object FullName

$skills = @($skillFiles | ForEach-Object { Get-SkillMetadata -Path $_.FullName })

$refsRoot = Join-Path $Root "_refs"
$references = @(
    Get-ChildItem -LiteralPath $refsRoot -Recurse -File |
        Sort-Object FullName |
        ForEach-Object {
            $rel = ConvertTo-RepoPath $_.FullName
            $parts = $rel.Split("/")
            $group = if ($parts.Count -gt 2) { $parts[1] } else { "overview" }
            [ordered]@{
                path = $rel
                group = $group
                name = $_.BaseName
                lines = (Get-Content -LiteralPath $_.FullName).Count
            }
        }
)

$catalog = [ordered]@{
    generatedAt = Get-CatalogGeneratedAt
    summary = [ordered]@{
        skillCount = $skills.Count
        referenceCount = $references.Count
        workflowCount = @($references | Where-Object { $_.group -eq "workflows" }).Count
        checklistCount = @($references | Where-Object { $_.group -eq "checklists" }).Count
        templateCount = @($references | Where-Object { $_.group -eq "templates" }).Count
    }
    skills = $skills
    references = $references
}

$json = ($catalog | ConvertTo-Json -Depth 20).Replace("`r`n", "`n")
$content = "window.ANNIFITY_CATALOG = " + $json + ";`n"
[System.IO.File]::WriteAllText($CatalogPath, $content, $Utf8NoBom)

Write-Host "Built docs catalog: docs/data/catalog.js ($($skills.Count) skills, $($references.Count) refs)."
