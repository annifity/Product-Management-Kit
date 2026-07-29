[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "file-hash-compat.ps1")
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Tool = Join-Path $Root "tools/new-artifact-registry-migration.ps1"
$Resolver = Join-Path $Root "tools/resolve-authoritative-baseline.ps1"
$Fixture = Join-Path $Root "tests/fixtures/artifact-registry-migration/workspace"
$PowerShell = (Get-Process -Id $PID).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-registry-migration-{0}" -f [guid]::NewGuid().ToString("N")
)

function Write-Json {
    param([string]$Path, $Value)
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $parent)
    }
    [System.IO.File]::WriteAllText(
        $Path,
        ((($Value | ConvertTo-Json -Depth 100) -replace "`r`n", "`n") + "`n"),
        $Utf8NoBom
    )
}

function Invoke-Migration {
    param([string]$Workspace, [string]$Evidence, [string]$Output)
    $arguments = @(
        "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $Tool,
        "-WorkspaceRoot", $Workspace,
        "-DocsRoot", ".annifity/docs",
        "-EvidencePath", ".annifity/migration-evidence.json",
        "-AsJson"
    )
    if (-not [string]::IsNullOrWhiteSpace($Output)) {
        $arguments += @("-OutputPath", $Output)
    }
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $text = @(& $PowerShell @arguments 2>&1) -join [Environment]::NewLine
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
        $global:LASTEXITCODE = 0
    }
    return [pscustomobject]@{ exitCode = $exitCode; text = $text }
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

try {
    [void](New-Item -ItemType Directory -Path $TempRoot)
    $workspace = Join-Path $TempRoot "workspace"
    Copy-Item -LiteralPath $Fixture -Destination $workspace -Recurse
    $selectedPath = Join-Path $workspace ".annifity/docs/selected.md"
    $selectedSha = (Get-FileHash -LiteralPath $selectedPath -Algorithm SHA256).
        Hash.
        ToLowerInvariant()
    $selectedRepoPath = ".annifity/docs/selected.md"
    $record = [pscustomobject][ordered]@{
        artifactId = "TEST-US-001"
        version = "1.0"
        path = $selectedRepoPath
        lifecycle = "baselined"
        metadataMode = "legacy-registry"
        artifactType = "user-story"
        documentUpdated = "2026-07-29"
        documentSource = "TEST-DEC-001"
        sha256 = $selectedSha
        supersedes = @()
    }
    $pointer = [pscustomobject][ordered]@{
        artifactId = "TEST-US-001"
        baselineVersion = "1.0"
        baselinePath = $selectedRepoPath
        baselineSha256 = $selectedSha
        latestVersion = "1.0"
        latestPath = $selectedRepoPath
        latestSha256 = $selectedSha
        source = "TEST-DEC-001"
    }
    $evidence = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        status = "accepted"
        updated = "2026-07-29"
        source = "TEST-DEC-001"
        records = @($record)
        pointers = @($pointer)
    }
    $evidencePath = Join-Path $workspace ".annifity/migration-evidence.json"
    Write-Json -Path $evidencePath -Value $evidence

    $valid = Invoke-Migration `
        -Workspace $workspace `
        -Evidence $evidencePath `
        -Output ".annifity/tmp/candidate.json"
    Assert-True ($valid.exitCode -eq 0) "Valid partial migration failed: $($valid.text)"
    $validResult = $valid.text | ConvertFrom-Json
    Assert-True `
        ($validResult.status -eq "candidate" -and
         $validResult.summary.resolvableArtifacts -eq 1 -and
         $validResult.summary.blockedInventoryFiles -eq 1) `
        "Valid partial migration returned incorrect summary."
    Assert-True `
        (@($validResult.blockedInventory) -contains ".annifity/docs/unselected.md") `
        "Unselected file disappeared from blocked inventory."
    Assert-True `
        (@($validResult.proposedRegistry.records | Where-Object {
            $_.path -eq ".annifity/docs/unselected.md"
        }).Count -eq 0) `
        "Unselected file was silently registered."

    $candidatePath = Join-Path $workspace ".annifity/tmp/candidate.json"
    $resolvedText = @(
        & $PowerShell -NoProfile -ExecutionPolicy Bypass `
            -File $Resolver `
            -ArtifactId "TEST-US-001" `
            -WorkspaceRoot $workspace `
            -RegistryPath ".annifity/tmp/candidate.json" `
            -AsJson
    ) -join [Environment]::NewLine
    Assert-True ($LASTEXITCODE -eq 0) "Resolver rejected migration candidate: $resolvedText"
    $global:LASTEXITCODE = 0
    $resolved = $resolvedText | ConvertFrom-Json
    Assert-True ($resolved.verdict -eq "resolved") "Candidate did not resolve."

    $deterministicOne = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    $deterministicTwo = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    Assert-True `
        ($deterministicOne.exitCode -eq 0 -and
         $deterministicOne.text -ceq $deterministicTwo.text) `
        "Identical migration inputs must produce byte-identical reports."

    $unselectedRepoPath = ".annifity/docs/unselected.md"
    $unselectedSha = (
        Get-FileHash `
            -LiteralPath (Join-Path $workspace $unselectedRepoPath) `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()
    $evidence.records[0].path = $unselectedRepoPath
    $evidence.records[0].sha256 = $unselectedSha
    $evidence.pointers[0].baselinePath = $unselectedRepoPath
    $evidence.pointers[0].baselineSha256 = $unselectedSha
    $evidence.pointers[0].latestPath = $unselectedRepoPath
    $evidence.pointers[0].latestSha256 = $unselectedSha
    Write-Json -Path $evidencePath -Value $evidence
    $missingLegacyFrontmatter = Invoke-Migration `
        -Workspace $workspace `
        -Evidence $evidencePath `
        -Output ""
    Assert-True `
        ($missingLegacyFrontmatter.exitCode -eq 2) `
        "legacy-registry without legacy frontmatter must be blocked."
    $missingLegacyResult = $missingLegacyFrontmatter.text | ConvertFrom-Json
    Assert-True `
        (@($missingLegacyResult.diagnostics.code) -contains "LEGACY_FRONTMATTER_MISSING") `
        "Missing legacy frontmatter did not return LEGACY_FRONTMATTER_MISSING."

    $graphPaths = @(
        ".annifity/docs/graph-v1.md",
        ".annifity/docs/graph-v2.md",
        ".annifity/docs/graph-v3.md"
    )
    foreach ($graphPath in $graphPaths) {
        [System.IO.File]::WriteAllText(
            (Join-Path $workspace $graphPath),
            "# Registry-mode graph fixture`n",
            $Utf8NoBom
        )
    }
    $graphSha = (
        Get-FileHash `
            -LiteralPath (Join-Path $workspace $graphPaths[0]) `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()
    $graphRecordOne = [pscustomobject][ordered]@{
        artifactId = "TEST-GRAPH-001"
        version = "1.0"
        path = $graphPaths[0]
        lifecycle = "superseded"
        metadataMode = "registry"
        artifactType = "user-story"
        documentUpdated = "2026-07-29"
        documentSource = "TEST-DEC-002"
        sha256 = $graphSha
        supersedes = @("TEST-GRAPH-001@2.0")
    }
    $graphRecordTwo = [pscustomobject][ordered]@{
        artifactId = "TEST-GRAPH-001"
        version = "2.0"
        path = $graphPaths[1]
        lifecycle = "baselined"
        metadataMode = "registry"
        artifactType = "user-story"
        documentUpdated = "2026-07-29"
        documentSource = "TEST-DEC-002"
        sha256 = $graphSha
        supersedes = @("TEST-GRAPH-001@1.0")
    }
    $graphPointer = [pscustomobject][ordered]@{
        artifactId = "TEST-GRAPH-001"
        baselineVersion = "2.0"
        baselinePath = $graphPaths[1]
        baselineSha256 = $graphSha
        latestVersion = "2.0"
        latestPath = $graphPaths[1]
        latestSha256 = $graphSha
        source = "TEST-DEC-002"
    }
    $evidence.records = @($graphRecordOne, $graphRecordTwo)
    $evidence.pointers = @($graphPointer)
    Write-Json -Path $evidencePath -Value $evidence
    $cycle = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    Assert-True ($cycle.exitCode -eq 2) "Supersession cycle must block migration."
    $cycleResult = $cycle.text | ConvertFrom-Json
    Assert-True `
        (@($cycleResult.diagnostics.code) -contains "SUPERSESSION_CYCLE") `
        "Supersession cycle did not return SUPERSESSION_CYCLE."

    $graphRecordOne.supersedes = @()
    $graphRecordTwo.lifecycle = "superseded"
    $graphRecordTwo.supersedes = @("TEST-GRAPH-001@1.0")
    $graphRecordThree = [pscustomobject][ordered]@{
        artifactId = "TEST-GRAPH-001"
        version = "3.0"
        path = $graphPaths[2]
        lifecycle = "baselined"
        metadataMode = "registry"
        artifactType = "user-story"
        documentUpdated = "2026-07-29"
        documentSource = "TEST-DEC-002"
        sha256 = $graphSha
        supersedes = @("TEST-GRAPH-001@1.0", "TEST-GRAPH-001@2.0")
    }
    $graphPointer.baselineVersion = "3.0"
    $graphPointer.baselinePath = $graphPaths[2]
    $graphPointer.latestVersion = "3.0"
    $graphPointer.latestPath = $graphPaths[2]
    $evidence.records = @($graphRecordOne, $graphRecordTwo, $graphRecordThree)
    Write-Json -Path $evidencePath -Value $evidence
    $ambiguous = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    Assert-True `
        ($ambiguous.exitCode -eq 2) `
        "Competing supersession successors must block migration."
    $ambiguousResult = $ambiguous.text | ConvertFrom-Json
    Assert-True `
        (@($ambiguousResult.diagnostics.code) -contains "SUPERSESSION_AMBIGUOUS") `
        "Competing successors did not return SUPERSESSION_AMBIGUOUS."

    $evidence.records = @($record)
    $evidence.pointers = @($pointer)
    $evidence.records[0].path = $selectedRepoPath
    $evidence.records[0].sha256 = $selectedSha
    $evidence.pointers[0].baselinePath = $selectedRepoPath
    $evidence.pointers[0].baselineSha256 = $selectedSha
    $evidence.pointers[0].latestPath = $selectedRepoPath
    $evidence.pointers[0].latestSha256 = $selectedSha
    $evidence.records[0].sha256 = ("0" * 64)
    Write-Json -Path $evidencePath -Value $evidence
    $hashDrift = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    Assert-True `
        ($hashDrift.exitCode -eq 2) `
        "Hash drift must block candidate emission. Exit=$($hashDrift.exitCode) Output=$($hashDrift.text)"
    $hashResult = $hashDrift.text | ConvertFrom-Json
    Assert-True `
        (@($hashResult.diagnostics.code) -contains "HASH_MISMATCH") `
        "Hash drift did not return HASH_MISMATCH."

    $evidence.records[0].sha256 = $selectedSha
    $evidence.pointers = @()
    Write-Json -Path $evidencePath -Value $evidence
    $missingPointer = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    Assert-True ($missingPointer.exitCode -eq 2) "Missing pointer must block migration."
    $missingPointerResult = $missingPointer.text | ConvertFrom-Json
    Assert-True `
        (@($missingPointerResult.diagnostics.code) -contains "POINTER_COUNT_INVALID") `
        "Missing pointer did not return POINTER_COUNT_INVALID."

    $evidence.pointers = @($pointer)
    $evidence.records[0].path = "../escape.md"
    Write-Json -Path $evidencePath -Value $evidence
    $traversal = Invoke-Migration -Workspace $workspace -Evidence $evidencePath -Output ""
    Assert-True ($traversal.exitCode -eq 2) "Traversal path must block migration."
    $traversalResult = $traversal.text | ConvertFrom-Json
    Assert-True `
        (@($traversalResult.diagnostics.code) -contains "RECORD_INVALID") `
        "Traversal path did not fail closed as RECORD_INVALID."

    $evidence.records[0].path = $selectedRepoPath
    Write-Json -Path $evidencePath -Value $evidence
    $insideDocs = Invoke-Migration `
        -Workspace $workspace `
        -Evidence $evidencePath `
        -Output ".annifity/docs/artifact-state-registry.json"
    Assert-True ($insideDocs.exitCode -ne 0) "Tool wrote into the live docs root."

    Write-Host "OK artifact registry migration tests passed."
}
finally {
    if (Test-Path -LiteralPath $TempRoot -PathType Container) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($TempRoot)
        $tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).
            TrimEnd([char[]]"\/")
        if (-not $resolvedTemp.StartsWith(
            $tempBase + [System.IO.Path]::DirectorySeparatorChar,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            throw "Refusing to remove registry-migration data outside temp."
        }
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}
