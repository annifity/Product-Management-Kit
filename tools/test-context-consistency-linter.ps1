[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FixtureRoot = Join-Path $Root "tests/fixtures/context-consistency"
$Linter = Join-Path $Root "tools/lint-context-consistency.ps1"
$PowerShell = (Get-Process -Id $PID).Path

foreach ($requiredPath in @(
    $FixtureRoot,
    $Linter,
    (Join-Path $FixtureRoot "valid.json")
)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Context consistency test is missing required path: $requiredPath"
    }
}

function Invoke-Linter {
    param([Parameter(Mandatory = $true)][string]$Manifest)

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = @(
            & $PowerShell -NoProfile -ExecutionPolicy Bypass `
                -File $Linter `
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

function Convert-LintResult {
    param(
        [Parameter(Mandatory = $true)]$Invocation,
        [Parameter(Mandatory = $true)][string]$Manifest
    )

    try {
        return $Invocation.text | ConvertFrom-Json
    }
    catch {
        throw "Context fixture '$Manifest' did not return JSON: $($Invocation.text)"
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
        throw "Context fixture '$Manifest' expected finding '$Code', found [$actual]."
    }
}

$fixtureHashesBefore = @{}
foreach ($fixtureFile in (Get-ChildItem -LiteralPath $FixtureRoot -File -Recurse | Sort-Object FullName)) {
    $fixtureHashesBefore[$fixtureFile.FullName] = (
        Get-FileHash -LiteralPath $fixtureFile.FullName -Algorithm SHA256
    ).Hash
}

try {
    $first = Invoke-Linter -Manifest "valid.json"
    $second = Invoke-Linter -Manifest "valid.json"
    if ($first.exitCode -ne 0) {
        throw "Valid context fixture failed: $($first.text)"
    }
    if ($first.text -cne $second.text) {
        throw "Context linter did not produce deterministic JSON for identical input."
    }
    $validResult = Convert-LintResult -Invocation $first -Manifest "valid.json"
    if ($validResult.verdict -cne "pass" -or @($validResult.findings).Count -ne 0) {
        throw "Valid context fixture did not pass cleanly."
    }
    if ([int]$validResult.summary.questionRecordCount -ne 1 -or
        [int]$validResult.summary.decisionRecordCount -ne 2 -or
        [int]$validResult.summary.changelogStreamCount -ne 1) {
        throw "Valid context fixture did not exercise all structured record families."
    }

    $failureCases = [ordered]@{
        "question-conflict.json" = "QUESTION_STATE_CONFLICT"
        "frontmatter-profile.json" = "FRONTMATTER_FORBIDDEN"
        "frontmatter-manifest.json" = "FRONTMATTER_FORBIDDEN"
        "stale-terminology.json" = "STALE_TERMINOLOGY"
        "decision-conflict.json" = "DECISION_CONFLICT_UNSUPERSEDED"
        "changelog-gap.json" = "CHANGELOG_CONTINUITY_GAP"
        "mojibake.json" = "MOJIBAKE_DETECTED"
    }
    foreach ($case in $failureCases.GetEnumerator()) {
        $invocation = Invoke-Linter -Manifest ([string]$case.Key)
        if ($invocation.exitCode -ne 2) {
            throw (
                "Context fixture '$($case.Key)' expected validation exit 2, " +
                "got $($invocation.exitCode): $($invocation.text)"
            )
        }
        $result = Convert-LintResult -Invocation $invocation -Manifest ([string]$case.Key)
        if ($result.verdict -cne "fail") {
            throw "Context fixture '$($case.Key)' did not return a failed verdict."
        }
        Assert-Code -Result $result -Code ([string]$case.Value) -Manifest ([string]$case.Key)
    }

    foreach ($invalidManifest in @(
        "undeclared-rule-path.json",
        "path-escape.json",
        "backslash-path.json",
        "scalar-scan-path.json",
        "empty-scan.json"
    )) {
        $invocation = Invoke-Linter -Manifest $invalidManifest
        if ($invocation.exitCode -eq 0 -or $invocation.exitCode -eq 2) {
            throw "Invalid context manifest '$invalidManifest' was not rejected as a contract error."
        }
    }
}
finally {
    foreach ($fixturePath in @($fixtureHashesBefore.Keys)) {
        if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
            throw "Context consistency test removed fixture '$fixturePath'."
        }
        $after = (Get-FileHash -LiteralPath $fixturePath -Algorithm SHA256).Hash
        if ($after -cne $fixtureHashesBefore[$fixturePath]) {
            throw "Context consistency test modified fixture '$fixturePath'."
        }
    }
}

Write-Host (
    "OK context consistency lint passed question, frontmatter, terminology, " +
    "decision, changelog, mojibake, boundary, and determinism cases."
)
