[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module Microsoft.PowerShell.Utility -Force -ErrorAction Stop

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Resolver = Join-Path $PSScriptRoot "resolve-authoritative-baseline.ps1"
$FixturesRoot = Join-Path $Root "tests/fixtures/artifact-baselines"
$PowerShell = (Get-Process -Id $PID).Path
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$TemporaryFixtureRoots = New-Object System.Collections.Generic.List[string]

function Invoke-ResolverAtRoot {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)][string]$ArtifactId
    )

    $output = @(
        & $PowerShell -NoProfile -ExecutionPolicy Bypass `
            -File $Resolver `
            -ArtifactId $ArtifactId `
            -WorkspaceRoot $FixtureRoot `
            -RegistryPath "registry.json" `
            -AsJson 2>&1
    )
    $exitCode = $LASTEXITCODE
    $jsonText = $output -join [Environment]::NewLine
    try {
        $result = $jsonText | ConvertFrom-Json
    }
    catch {
        throw "Fixture root '$FixtureRoot' returned invalid JSON. Output: $jsonText"
    }
    return [pscustomobject]@{
        exitCode = $exitCode
        result = $result
    }
}

function Invoke-ResolverCase {
    param(
        [Parameter(Mandatory = $true)][string]$Fixture,
        [Parameter(Mandatory = $true)][string]$ArtifactId
    )

    return Invoke-ResolverAtRoot `
        -FixtureRoot (Join-Path $FixturesRoot $Fixture) `
        -ArtifactId $ArtifactId
}

function New-TemporaryFixture {
    param(
        [Parameter(Mandatory = $true)][string]$BaseFixture,
        [Parameter(Mandatory = $true)][scriptblock]$Mutation
    )

    $temporaryRoot = Join-Path `
        ([System.IO.Path]::GetTempPath()) `
        ("annifity-authoritative-baseline-" + [guid]::NewGuid().ToString("N"))
    Copy-Item `
        -LiteralPath (Join-Path $FixturesRoot $BaseFixture) `
        -Destination $temporaryRoot `
        -Recurse `
        -Force
    $TemporaryFixtureRoots.Add($temporaryRoot) | Out-Null

    $registryFile = Join-Path $temporaryRoot "registry.json"
    $registry = [System.IO.File]::ReadAllText($registryFile) | ConvertFrom-Json
    & $Mutation $temporaryRoot $registry
    [System.IO.File]::WriteAllText(
        $registryFile,
        ($registry | ConvertTo-Json -Depth 20),
        $Utf8NoBom
    )
    return $temporaryRoot
}

function Set-DocumentTextAndRefreshHash {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)]$Registry,
        [Parameter(Mandatory = $true)][string]$ArtifactId,
        [Parameter(Mandatory = $true)][string]$Version,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $record = @(
        $Registry.records |
            Where-Object {
                $_.artifactId -ceq $ArtifactId -and
                $_.version -ceq $Version
            }
    )[0]
    $documentPath = Join-Path $FixtureRoot ([string]$record.path)
    [System.IO.File]::WriteAllText($documentPath, $Content, $Utf8NoBom)
    $sha256 = (
        Microsoft.PowerShell.Utility\Get-FileHash `
            -LiteralPath $documentPath `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()
    $record.sha256 = $sha256

    foreach ($pointer in @($Registry.pointers | Where-Object { $_.artifactId -ceq $ArtifactId })) {
        if ($pointer.baselineVersion -ceq $Version) {
            $pointer.baselineSha256 = $sha256
        }
        if ($pointer.latestVersion -ceq $Version) {
            $pointer.latestSha256 = $sha256
        }
    }
}

function Set-RegisteredPath {
    param(
        [Parameter(Mandatory = $true)]$Registry,
        [Parameter(Mandatory = $true)][string]$ArtifactId,
        [Parameter(Mandatory = $true)][string]$Version,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Path
    )

    $record = @(
        $Registry.records |
            Where-Object {
                $_.artifactId -ceq $ArtifactId -and
                $_.version -ceq $Version
            }
    )[0]
    $record.path = $Path
    foreach ($pointer in @($Registry.pointers | Where-Object { $_.artifactId -ceq $ArtifactId })) {
        if ($pointer.baselineVersion -ceq $Version) {
            $pointer.baselinePath = $Path
        }
        if ($pointer.latestVersion -ceq $Version) {
            $pointer.latestPath = $Path
        }
    }
}

function Assert-BlockedWithCode {
    param(
        [Parameter(Mandatory = $true)][string]$Fixture,
        [Parameter(Mandatory = $true)][string]$ArtifactId,
        [Parameter(Mandatory = $true)][string]$Code
    )

    $case = Invoke-ResolverCase -Fixture $Fixture -ArtifactId $ArtifactId
    if ($case.exitCode -ne 2) {
        throw "Fixture '$Fixture' expected exit code 2 but got $($case.exitCode)."
    }
    if ($case.result.verdict -cne "blocked") {
        throw "Fixture '$Fixture' expected blocked verdict but got '$($case.result.verdict)'."
    }
    $codes = @($case.result.diagnostics | ForEach-Object { [string]$_.code })
    if ($codes -notcontains $Code) {
        throw "Fixture '$Fixture' expected diagnostic '$Code' but got: $($codes -join ', ')."
    }
}

function Assert-RootBlockedWithCode {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureRoot,
        [Parameter(Mandatory = $true)][string]$ArtifactId,
        [Parameter(Mandatory = $true)][string]$Code
    )

    $case = Invoke-ResolverAtRoot -FixtureRoot $FixtureRoot -ArtifactId $ArtifactId
    if ($case.exitCode -ne 2) {
        throw "Fixture root '$FixtureRoot' expected exit code 2 but got $($case.exitCode)."
    }
    if ($case.result.verdict -cne "blocked") {
        throw "Fixture root '$FixtureRoot' expected blocked verdict but got '$($case.result.verdict)'."
    }
    $codes = @($case.result.diagnostics | ForEach-Object { [string]$_.code })
    if ($codes -notcontains $Code) {
        throw "Fixture root '$FixtureRoot' expected diagnostic '$Code' but got: $($codes -join ', ')."
    }
}

try {
$valid = Invoke-ResolverCase -Fixture "valid" -ArtifactId "DEMO-SPEC-001"
if ($valid.exitCode -ne 0 -or $valid.result.verdict -cne "resolved") {
    $codes = @($valid.result.diagnostics | ForEach-Object { [string]$_.code })
    throw "Valid fixture did not resolve. Diagnostics: $($codes -join ', ')."
}
if ($valid.result.baseline.path -cne "artifacts/DEMO-SPEC-001_v1.1.md" -or
    $valid.result.baseline.version -cne "1.1" -or
    [string]::IsNullOrWhiteSpace([string]$valid.result.baseline.sha256)) {
    throw "Valid fixture returned the wrong baseline path, version, or hash."
}
if ($valid.result.latest.path -cne "artifacts/DEMO-SPEC-001_v1.2-draft.1.md" -or
    $valid.result.latest.version -cne "1.2-draft.1") {
    throw "Valid fixture returned the wrong latest pointer."
}
$provenanceKinds = @($valid.result.provenance | ForEach-Object { [string]$_.kind })
foreach ($kind in @("registry", "baseline-pointer", "document")) {
    if ($provenanceKinds -notcontains $kind) {
        throw "Valid fixture is missing '$kind' provenance."
    }
}

$registryMetadata = Invoke-ResolverCase -Fixture "valid-registry-metadata" -ArtifactId "DEMO-US-001"
if ($registryMetadata.exitCode -ne 0 -or $registryMetadata.result.verdict -cne "resolved") {
    $codes = @($registryMetadata.result.diagnostics | ForEach-Object { [string]$_.code })
    throw "Registry-metadata fixture did not resolve. Diagnostics: $($codes -join ', ')."
}
if ($registryMetadata.result.baseline.path -cne "artifacts/DEMO-US-001_v1.0.md" -or
    $registryMetadata.result.baseline.version -cne "1.0") {
    throw "Registry-metadata fixture returned the wrong baseline path or version."
}
$documentProvenance = @($registryMetadata.result.provenance | Where-Object { $_.kind -ceq "document" })
if ($documentProvenance.Count -ne 1 -or $documentProvenance[0].source -cne "DEMO-SPEC-001") {
    throw "Registry-metadata fixture did not preserve documentSource provenance."
}

$chain = Invoke-ResolverCase -Fixture "valid-supersession-chain" -ArtifactId "DEMO-CHAIN-001"
if ($chain.exitCode -ne 0 -or $chain.result.verdict -cne "resolved") {
    $codes = @($chain.result.diagnostics | ForEach-Object { [string]$_.code })
    throw "Three-version supersession chain did not resolve. Diagnostics: $($codes -join ', ')."
}
if ($chain.result.baseline.version -cne "1.2" -or
    $chain.result.baseline.path -cne "artifacts/DEMO-CHAIN-001_v1.2.md") {
    throw "Three-version supersession chain returned the wrong active baseline."
}

Assert-BlockedWithCode -Fixture "duplicate-active" -ArtifactId "DEMO-DUP-001" -Code "AMBIGUOUS_ACTIVE_BASELINE"
Assert-BlockedWithCode -Fixture "missing-metadata" -ArtifactId "DEMO-MISSING-001" -Code "DOCUMENT_METADATA_MISSING"
Assert-BlockedWithCode -Fixture "invalid-supersession" -ArtifactId "DEMO-SUP-001" -Code "INVALID_SUPERSESSION_TARGET"
Assert-BlockedWithCode -Fixture "stale-pointer" -ArtifactId "DEMO-STALE-001" -Code "STALE_BASELINE_POINTER"
Assert-BlockedWithCode -Fixture "registry-metadata-missing-document" -ArtifactId "DEMO-US-MISSING" -Code "DOCUMENT_NOT_FOUND"

$upperCaseIdentity = Invoke-ResolverCase -Fixture "case-collision" -ArtifactId "DEMO-CASE-001"
if ($upperCaseIdentity.exitCode -ne 0 -or
    $upperCaseIdentity.result.verdict -cne "resolved" -or
    $upperCaseIdentity.result.baseline.path -cne "artifacts/upper.md") {
    throw "Upper-case identity in the case-collision fixture did not resolve exactly."
}
$lowerCaseIdentity = Invoke-ResolverCase -Fixture "case-collision" -ArtifactId "demo-case-001"
if ($lowerCaseIdentity.exitCode -ne 0 -or
    $lowerCaseIdentity.result.verdict -cne "resolved" -or
    $lowerCaseIdentity.result.baseline.path -cne "artifacts/lower.md") {
    throw "Lower-case identity in the case-collision fixture did not resolve exactly."
}
Assert-BlockedWithCode `
    -Fixture "case-collision" `
    -ArtifactId "Demo-Case-001" `
    -Code "ARTIFACT_NOT_FOUND"
Assert-BlockedWithCode `
    -Fixture "orphan-pointer" `
    -ArtifactId "DEMO-ORPHAN-001" `
    -Code "ORPHAN_POINTER"

$scalarRecordsRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    $registry.records = $registry.records[0]
}
Assert-RootBlockedWithCode `
    -FixtureRoot $scalarRecordsRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "REGISTRY_RECORDS_TYPE_INVALID"

$scalarPointersRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    $registry.pointers = $registry.pointers[0]
}
Assert-RootBlockedWithCode `
    -FixtureRoot $scalarPointersRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "REGISTRY_POINTERS_TYPE_INVALID"

$scalarSupersedesRoot = New-TemporaryFixture -BaseFixture "valid" -Mutation {
    param($fixtureRoot, $registry)
    $record = @($registry.records | Where-Object { $_.version -ceq "1.1" })[0]
    $record.supersedes = "DEMO-SPEC-001@1.0"
}
Assert-RootBlockedWithCode `
    -FixtureRoot $scalarSupersedesRoot `
    -ArtifactId "DEMO-SPEC-001" `
    -Code "RECORD_SUPERSEDES_TYPE_INVALID"

$rootedPathRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    Set-RegisteredPath `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Path "/artifacts/DEMO-US-001_v1.0.md"
}
Assert-RootBlockedWithCode `
    -FixtureRoot $rootedPathRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "INVALID_REGISTERED_PATH"

$dotSegmentRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    Set-RegisteredPath `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Path "artifacts/./DEMO-US-001_v1.0.md"
}
Assert-RootBlockedWithCode `
    -FixtureRoot $dotSegmentRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "INVALID_REGISTERED_PATH"

$separatorAliasRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    Set-RegisteredPath `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Path "artifacts\DEMO-US-001_v1.0.md"
}
Assert-RootBlockedWithCode `
    -FixtureRoot $separatorAliasRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "INVALID_REGISTERED_PATH"

$caseAliasRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    Set-RegisteredPath `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Path "Artifacts/DEMO-US-001_v1.0.md"
}
Assert-RootBlockedWithCode `
    -FixtureRoot $caseAliasRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "INVALID_REGISTERED_PATH"

$reparseAncestorRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    New-Item `
        -ItemType Junction `
        -Path (Join-Path $fixtureRoot "artifact-link") `
        -Target (Join-Path $fixtureRoot "artifacts") | Out-Null
    Set-RegisteredPath `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Path "artifact-link/DEMO-US-001_v1.0.md"
}
Assert-RootBlockedWithCode `
    -FixtureRoot $reparseAncestorRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "REPARSE_PATH_REJECTED"

$registryFrontmatterRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    $content = @"
---
artifact_id: DEMO-US-001
title: Registry metadata conflict
type: user-story
status: baselined
updated: 2026-07-28
source: DEMO-SPEC-001
version: 1.0
---

# Registry metadata conflict
"@
    Set-DocumentTextAndRefreshHash `
        -FixtureRoot $fixtureRoot `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Content $content
}
Assert-RootBlockedWithCode `
    -FixtureRoot $registryFrontmatterRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "DOCUMENT_METADATA_MODE_CONFLICT"

$nullSourceRoot = New-TemporaryFixture -BaseFixture "valid" -Mutation {
    param($fixtureRoot, $registry)
    $record = @($registry.records | Where-Object { $_.version -ceq "1.1" })[0]
    $documentPath = Join-Path $fixtureRoot ([string]$record.path)
    $content = [System.IO.File]::ReadAllText($documentPath).Replace(
        "source: DEC-DEMO-002",
        "source: null # authority is absent"
    )
    Set-DocumentTextAndRefreshHash `
        -FixtureRoot $fixtureRoot `
        -Registry $registry `
        -ArtifactId "DEMO-SPEC-001" `
        -Version "1.1" `
        -Content $content
}
Assert-RootBlockedWithCode `
    -FixtureRoot $nullSourceRoot `
    -ArtifactId "DEMO-SPEC-001" `
    -Code "DOCUMENT_METADATA_MISSING"

$commentOnlySourceRoot = New-TemporaryFixture -BaseFixture "valid" -Mutation {
    param($fixtureRoot, $registry)
    $record = @($registry.records | Where-Object { $_.version -ceq "1.1" })[0]
    $documentPath = Join-Path $fixtureRoot ([string]$record.path)
    $content = [System.IO.File]::ReadAllText($documentPath).Replace(
        "source: DEC-DEMO-002",
        "source: # authority is absent"
    )
    Set-DocumentTextAndRefreshHash `
        -FixtureRoot $fixtureRoot `
        -Registry $registry `
        -ArtifactId "DEMO-SPEC-001" `
        -Version "1.1" `
        -Content $content
}
Assert-RootBlockedWithCode `
    -FixtureRoot $commentOnlySourceRoot `
    -ArtifactId "DEMO-SPEC-001" `
    -Code "DOCUMENT_METADATA_MISSING"

$inlineCommentSourceRoot = New-TemporaryFixture -BaseFixture "valid" -Mutation {
    param($fixtureRoot, $registry)
    $record = @($registry.records | Where-Object { $_.version -ceq "1.1" })[0]
    $documentPath = Join-Path $fixtureRoot ([string]$record.path)
    $content = [System.IO.File]::ReadAllText($documentPath).Replace(
        "source: DEC-DEMO-002",
        "source: DEC-DEMO-002 # accepted authority"
    )
    Set-DocumentTextAndRefreshHash `
        -FixtureRoot $fixtureRoot `
        -Registry $registry `
        -ArtifactId "DEMO-SPEC-001" `
        -Version "1.1" `
        -Content $content
}
$inlineCommentSource = Invoke-ResolverAtRoot `
    -FixtureRoot $inlineCommentSourceRoot `
    -ArtifactId "DEMO-SPEC-001"
if ($inlineCommentSource.exitCode -ne 0 -or
    $inlineCommentSource.result.verdict -cne "resolved" -or
    $inlineCommentSource.result.baseline.source -cne "DEC-DEMO-002") {
    throw "Inline source comments were not removed from the resolved provenance value."
}

$unexpectedPathErrorRoot = New-TemporaryFixture -BaseFixture "valid-registry-metadata" -Mutation {
    param($fixtureRoot, $registry)
    $invalidPath = "artifacts/" + [char]0 + "invalid.md"
    Set-RegisteredPath `
        -Registry $registry `
        -ArtifactId "DEMO-US-001" `
        -Version "1.0" `
        -Path $invalidPath
}
Assert-RootBlockedWithCode `
    -FixtureRoot $unexpectedPathErrorRoot `
    -ArtifactId "DEMO-US-001" `
    -Code "INVALID_REGISTERED_PATH"

Write-Host "OK authoritative baseline resolver (valid, invariant, and fail-closed regression cases)."
}
finally {
    foreach ($temporaryRoot in $TemporaryFixtureRoots) {
        if (Test-Path -LiteralPath $temporaryRoot) {
            Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
        }
    }
}
