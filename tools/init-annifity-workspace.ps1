[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$TargetRoot = (Resolve-Path -LiteralPath $Path).Path
$AnnifityRoot = Join-Path $TargetRoot ".annifity"
$DocsRoot = Join-Path $AnnifityRoot "docs"
$MemoriesRoot = Join-Path $AnnifityRoot "memories"
$ArtifactProfilesRoot = Join-Path $MemoriesRoot "artifact-profiles"

$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Ensure-Directory {
    param([Parameter(Mandatory = $true)][string]$Directory)

    if (-not (Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }
}

function Write-FromTemplate {
    param(
        [Parameter(Mandatory = $true)][string]$Template,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if ((Test-Path -LiteralPath $Destination) -and -not $Force) {
        return
    }

    $content = [System.IO.File]::ReadAllText((Join-Path $Root $Template), $Utf8NoBom)
    [System.IO.File]::WriteAllText($Destination, $content, $Utf8NoBom)
}

foreach ($directory in @(
    $DocsRoot,
    (Join-Path $DocsRoot "prd"),
    (Join-Path $DocsRoot "specs"),
    (Join-Path $DocsRoot "designs"),
    (Join-Path $DocsRoot "brd"),
    (Join-Path $DocsRoot "user-stories"),
    (Join-Path $DocsRoot "uat"),
    (Join-Path $DocsRoot "decisions"),
    (Join-Path $DocsRoot "evidence"),
    (Join-Path $DocsRoot "traceability"),
    (Join-Path $DocsRoot "templates"),
    (Join-Path $DocsRoot "changelog"),
    (Join-Path $DocsRoot "exports"),
    $MemoriesRoot,
    $ArtifactProfilesRoot
)) {
    Ensure-Directory -Directory $directory
}

Write-FromTemplate -Template "_refs/templates/docs/docs-index.md" -Destination (Join-Path $DocsRoot "index.md")
Write-FromTemplate -Template "_refs/templates/memories/product-context.md" -Destination (Join-Path $MemoriesRoot "product-context.md")
Write-FromTemplate -Template "_refs/templates/memories/team-preferences.md" -Destination (Join-Path $MemoriesRoot "team-preferences.md")
Write-FromTemplate -Template "_refs/templates/memories/terminology.md" -Destination (Join-Path $MemoriesRoot "terminology.md")
Write-FromTemplate -Template "_refs/templates/memories/stakeholder-context.md" -Destination (Join-Path $MemoriesRoot "stakeholder-context.md")
Write-FromTemplate -Template "_refs/templates/memories/decisions.md" -Destination (Join-Path $MemoriesRoot "decisions.md")
Write-FromTemplate -Template "_refs/templates/memories/decision-outcomes.md" -Destination (Join-Path $MemoriesRoot "decision-outcomes.md")
Write-FromTemplate -Template "_refs/templates/memories/open-questions.md" -Destination (Join-Path $MemoriesRoot "open-questions.md")

$artifactStateRegistry = Join-Path $DocsRoot "artifact-state-registry.json"
if ((-not (Test-Path -LiteralPath $artifactStateRegistry)) -or $Force) {
    $registry = [ordered]@{
        schemaVersion = "1.0"
        updated = (Get-Date).ToString("yyyy-MM-dd")
        source = "workspace-init"
        records = @()
        pointers = @()
    }
    $registryJson = (($registry | ConvertTo-Json -Depth 10) -replace "`r`n", "`n") + "`n"
    [System.IO.File]::WriteAllText($artifactStateRegistry, $registryJson, $Utf8NoBom)
}

$initiativeState = Join-Path $MemoriesRoot "initiative-state.md"
if ((-not (Test-Path -LiteralPath $initiativeState)) -or $Force) {
    [System.IO.File]::WriteAllText($initiativeState, "# Initiative State`n`nUse `_refs/schemas/initiative-state.md` for durable phase state.`n", $Utf8NoBom)
}

Write-Host "OK initialized Annifity workspace at $AnnifityRoot"
