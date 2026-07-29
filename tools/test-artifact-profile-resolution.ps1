[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FixtureRoot = Join-Path $Root "tests/fixtures/artifact-profiles"
$Resolver = Join-Path $Root "tools/resolve-artifact-profile.ps1"

if (-not (Test-Path -LiteralPath $FixtureRoot)) {
    throw "Missing artifact profile fixture directory: tests/fixtures/artifact-profiles"
}
if (-not (Test-Path -LiteralPath $Resolver)) {
    throw "Missing artifact profile resolver: tools/resolve-artifact-profile.ps1"
}

function Invoke-Resolver {
    param([Parameter(Mandatory = $true)][string]$RequestFile)

    $requestPath = Join-Path $FixtureRoot $RequestFile
    if (-not (Test-Path -LiteralPath $requestPath)) {
        throw "Fixture references missing request: $RequestFile"
    }
    $output = & $Resolver -RequestPath $requestPath
    return (($output -join [Environment]::NewLine) | ConvertFrom-Json)
}

function Get-ResultProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$PropertyName
    )

    $property = $Object.PSObject.Properties[$PropertyName]
    if ($null -eq $property) {
        throw "Resolved profile is missing expected property '$PropertyName'."
    }
    return $property.Value
}

function Assert-EquivalentValue {
    param(
        [Parameter(Mandatory = $true)]$Actual,
        [Parameter(Mandatory = $true)]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $actualJson = $Actual | ConvertTo-Json -Depth 50 -Compress
    $expectedJson = $Expected | ConvertTo-Json -Depth 50 -Compress
    if ($actualJson -cne $expectedJson) {
        throw "$Context expected $expectedJson but got $actualJson."
    }
}

$fixtures = @(
    Get-ChildItem -LiteralPath $FixtureRoot -Filter "*.expected.json" -File |
        Sort-Object Name
)
if ($fixtures.Count -eq 0) {
    throw "No artifact profile expected fixtures found."
}

foreach ($fixture in $fixtures) {
    $expected = Get-Content -Raw -LiteralPath $fixture.FullName | ConvertFrom-Json

    if ($expected.PSObject.Properties.Name -contains "expectedErrorContains") {
        $caughtMessage = $null
        try {
            [void](Invoke-Resolver -RequestFile $expected.request)
        }
        catch {
            $caughtMessage = $_.Exception.Message
        }
        if ([string]::IsNullOrWhiteSpace($caughtMessage)) {
            throw "Fixture '$($expected.name)' expected an error but resolver succeeded."
        }
        if (
            $caughtMessage.IndexOf(
                [string]$expected.expectedErrorContains,
                [System.StringComparison]::OrdinalIgnoreCase
            ) -lt 0
        ) {
            throw "Fixture '$($expected.name)' expected error containing '$($expected.expectedErrorContains)' but got '$caughtMessage'."
        }
        continue
    }

    $result = Invoke-Resolver -RequestFile $expected.request
    $repeat = Invoke-Resolver -RequestFile $expected.request

    if ($result.writeDisposition.state -ne $expected.expectedState) {
        throw "Fixture '$($expected.name)' expected disposition '$($expected.expectedState)' but got '$($result.writeDisposition.state)'."
    }
    if ($result.fingerprint.algorithm -ne "SHA-256") {
        throw "Fixture '$($expected.name)' returned an unsupported fingerprint algorithm."
    }
    if ([string]$result.fingerprint.value -notmatch "^sha256:[0-9a-f]{64}$") {
        throw "Fixture '$($expected.name)' returned a malformed fingerprint."
    }
    if ($result.fingerprint.value -cne $repeat.fingerprint.value) {
        throw "Fixture '$($expected.name)' produced a non-deterministic fingerprint."
    }

    foreach ($property in $expected.expectedValues.PSObject.Properties) {
        $actualValue = Get-ResultProperty `
            -Object $result.resolvedProfile `
            -PropertyName $property.Name
        Assert-EquivalentValue `
            -Actual $actualValue `
            -Expected $property.Value `
            -Context "Fixture '$($expected.name)' property '$($property.Name)'"
    }

    foreach ($property in $expected.expectedProvenance.PSObject.Properties) {
        $provenance = @(
            $result.provenance |
                Where-Object { $_.key -eq $property.Name }
        )
        if ($provenance.Count -ne 1) {
            throw "Fixture '$($expected.name)' expected one provenance entry for '$($property.Name)'."
        }
        if ($provenance[0].sourceId -ne $property.Value) {
            throw "Fixture '$($expected.name)' expected '$($property.Name)' from '$($property.Value)' but got '$($provenance[0].sourceId)'."
        }
    }

    if ($expected.PSObject.Properties.Name -contains "expectedGenerationContext") {
        foreach ($property in $expected.expectedGenerationContext.PSObject.Properties) {
            $actualValue = Get-ResultProperty `
                -Object $result.generationContext `
                -PropertyName $property.Name
            Assert-EquivalentValue `
                -Actual $actualValue `
                -Expected $property.Value `
                -Context "Fixture '$($expected.name)' generation context '$($property.Name)'"
        }
    }

    if ($expected.PSObject.Properties.Name -contains "requiredConflictKinds") {
        $actualKinds = @($result.conflicts | ForEach-Object { $_.kind })
        foreach ($kind in @($expected.requiredConflictKinds)) {
            if ($actualKinds -notcontains $kind) {
                throw "Fixture '$($expected.name)' is missing conflict kind '$kind'."
            }
        }
    }

    if ($expected.PSObject.Properties.Name -contains "requiredConflictSeverities") {
        $actualSeverities = @($result.conflicts | ForEach-Object { $_.severity })
        foreach ($severity in @($expected.requiredConflictSeverities)) {
            if ($actualSeverities -notcontains $severity) {
                throw "Fixture '$($expected.name)' is missing conflict severity '$severity'."
            }
        }
    }

    if ($expected.PSObject.Properties.Name -contains "prohibitedConflictSeverities") {
        $actualSeverities = @($result.conflicts | ForEach-Object { $_.severity })
        foreach ($severity in @($expected.prohibitedConflictSeverities)) {
            if ($actualSeverities -contains $severity) {
                throw "Fixture '$($expected.name)' unexpectedly contains conflict severity '$severity'."
            }
        }
    }

    if ($expected.PSObject.Properties.Name -contains "requiredBlockerKinds") {
        $actualBlockerKinds = @($result.blockers | ForEach-Object { $_.kind })
        foreach ($kind in @($expected.requiredBlockerKinds)) {
            if ($actualBlockerKinds -notcontains $kind) {
                throw "Fixture '$($expected.name)' is missing blocker kind '$kind'."
            }
        }
    }

    if ($expected.PSObject.Properties.Name -contains "expectedBlockingQuestion") {
        $question = @(
            $result.openQuestions |
                Where-Object {
                    $_.id -eq $expected.expectedBlockingQuestion -and $_.blocksWrite
                }
        )
        if ($question.Count -ne 1) {
            throw "Fixture '$($expected.name)' is missing blocking question '$($expected.expectedBlockingQuestion)'."
        }
    }

    if ($expected.PSObject.Properties.Name -contains "equivalentFingerprintRequest") {
        $equivalent = Invoke-Resolver -RequestFile $expected.equivalentFingerprintRequest
        if ($result.fingerprint.value -cne $equivalent.fingerprint.value) {
            throw "Fixture '$($expected.name)' changed fingerprint when source order changed."
        }
    }
}

$precedenceRequestPath = Join-Path $FixtureRoot "precedence.request.json"
$precedenceRequestJson = Get-Content -Raw -LiteralPath $precedenceRequestPath
$fromPath = & $Resolver -RequestPath $precedenceRequestPath | ConvertFrom-Json
$fromJson = & $Resolver -RequestJson $precedenceRequestJson | ConvertFrom-Json
if ($fromPath.fingerprint.value -cne $fromJson.fingerprint.value) {
    throw "-RequestJson and -RequestPath must produce the same fingerprint."
}

$existingOutputPath = Join-Path $FixtureRoot "resolver-output-existing.json"
$existingOutputBefore = [System.IO.File]::ReadAllText($existingOutputPath)
$overwriteRejected = $false
try {
    & $Resolver `
        -RequestPath $precedenceRequestPath `
        -OutputPath $existingOutputPath | Out-Null
}
catch {
    $overwriteRejected = $_.Exception.Message -match "Refusing to overwrite"
}
if (-not $overwriteRejected) {
    throw "Resolver must refuse to overwrite an existing OutputPath."
}
if ([System.IO.File]::ReadAllText($existingOutputPath) -cne $existingOutputBefore) {
    throw "Resolver modified an existing OutputPath while rejecting overwrite."
}

Write-Host "OK artifact profile resolution passed ($($fixtures.Count) fixture(s))."
