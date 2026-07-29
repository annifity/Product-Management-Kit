[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FixtureRoot = Join-Path $Root "tests/fixtures/drawio-validation"
$Validator = Join-Path $Root "tools/validate-drawio.ps1"
$PowerShell = (Get-Process -Id $PID).Path

foreach ($requiredPath in @(
    $FixtureRoot,
    $Validator,
    (Join-Path $FixtureRoot "valid.json"),
    (Join-Path $FixtureRoot "compressed-valid.json")
)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Draw.io validation test is missing required path: $requiredPath"
    }
}

function Invoke-Validator {
    param([Parameter(Mandatory = $true)][string]$Manifest)

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = @(
            & $PowerShell -NoProfile -ExecutionPolicy Bypass `
                -File $Validator `
                -RootPath $FixtureRoot `
                -ManifestPath $Manifest 2>&1
        )
        $exitCode = $LASTEXITCODE
        $global:LASTEXITCODE = 0
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    return [pscustomobject]@{
        exitCode = $exitCode
        text = ($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
    }
}

function Convert-ValidationResult {
    param(
        [Parameter(Mandatory = $true)]$Invocation,
        [Parameter(Mandatory = $true)][string]$Manifest
    )

    try {
        return $Invocation.text | ConvertFrom-Json
    }
    catch {
        throw "Draw.io fixture '$Manifest' did not return JSON: $($Invocation.text)"
    }
}

function Assert-Code {
    param(
        [Parameter(Mandatory = $true)]$Result,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Manifest
    )

    if (@($Result.findings | Where-Object { $_.code -ceq $Code }).Count -lt 1) {
        $actual = @($Result.findings | ForEach-Object { [string]$_.code }) -join ", "
        throw "Draw.io fixture '$Manifest' expected finding '$Code', found [$actual]."
    }
}

$fixtureHashesBefore = @{}
foreach ($fixtureFile in (Get-ChildItem -LiteralPath $FixtureRoot -File -Recurse | Sort-Object FullName)) {
    $fixtureHashesBefore[$fixtureFile.FullName] = (
        Get-FileHash -LiteralPath $fixtureFile.FullName -Algorithm SHA256
    ).Hash
}

try {
    foreach ($validManifest in @("valid.json", "compressed-valid.json")) {
        $first = Invoke-Validator -Manifest $validManifest
        $second = Invoke-Validator -Manifest $validManifest
        if ($first.exitCode -ne 0) {
            throw "Valid Draw.io fixture '$validManifest' failed: $($first.text)"
        }
        if ($first.text -cne $second.text) {
            throw "Draw.io fixture '$validManifest' did not produce deterministic JSON."
        }
        $result = Convert-ValidationResult -Invocation $first -Manifest $validManifest
        if ($result.verdict -cne "pass" -or @($result.findings).Count -ne 0) {
            throw "Valid Draw.io fixture '$validManifest' did not pass cleanly."
        }
        if ([int]$result.summary.renderablePageCount -lt 1) {
            throw "Valid Draw.io fixture '$validManifest' did not prove a renderable page."
        }
    }

    $failureCases = [ordered]@{
        "invalid-geometry.json" = "GEOMETRY_DIMENSION_INVALID"
        "invalid-structure.json" = "CELL_PARENT_CYCLE"
        "stale-label.json" = "STALE_LABEL"
        "forbidden-label.json" = "FORBIDDEN_LABEL"
        "missing-source.json" = "LINKED_SOURCE_MISSING"
        "no-renderable-page.json" = "RENDERABLE_PAGE_MINIMUM_NOT_MET"
        "malformed.json" = "DRAWIO_XML_INVALID"
    }
    foreach ($case in $failureCases.GetEnumerator()) {
        $invocation = Invoke-Validator -Manifest ([string]$case.Key)
        if ($invocation.exitCode -ne 2) {
            throw (
                "Draw.io fixture '$($case.Key)' expected validation exit 2, " +
                "got $($invocation.exitCode): $($invocation.text)"
            )
        }
        $result = Convert-ValidationResult -Invocation $invocation -Manifest ([string]$case.Key)
        if ($result.verdict -cne "fail") {
            throw "Draw.io fixture '$($case.Key)' did not return a failed verdict."
        }
        Assert-Code -Result $result -Code ([string]$case.Value) -Manifest ([string]$case.Key)
    }

    foreach ($invalidManifest in @(
        "path-escape.json",
        "backslash-path.json",
        "scalar-artifacts.json",
        "empty-artifacts.json"
    )) {
        $invocation = Invoke-Validator -Manifest $invalidManifest
        if ($invocation.exitCode -eq 0 -or $invocation.exitCode -eq 2) {
            throw "Invalid Draw.io manifest '$invalidManifest' was not rejected as a contract error."
        }
    }
}
finally {
    foreach ($fixturePath in @($fixtureHashesBefore.Keys)) {
        if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
            throw "Draw.io validation test removed fixture '$fixturePath'."
        }
        $after = (Get-FileHash -LiteralPath $fixturePath -Algorithm SHA256).Hash
        if ($after -cne $fixtureHashesBefore[$fixturePath]) {
            throw "Draw.io validation test modified fixture '$fixturePath'."
        }
    }
}

Write-Host "OK Draw.io validation passed structural, source, label, boundary, and determinism cases."
