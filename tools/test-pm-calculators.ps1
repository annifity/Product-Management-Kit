[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$finance = & (Join-Path $PSScriptRoot "calculate-finance-metrics.ps1") -InputPath (Join-Path $Root "tests/fixtures/calculators/finance-valid.json") | ConvertFrom-Json
if ($finance.metrics.endingMrr -ne 110000) { throw "Finance calculator endingMrr regression." }
if ($finance.metrics.endingArr -ne 1320000) { throw "Finance calculator endingArr regression." }
if ($finance.metrics.netRevenueRetention -ne 1) { throw "Finance calculator NRR regression." }
if ($finance.metrics.grossRevenueRetention -ne 0.95) { throw "Finance calculator GRR regression." }
if ($finance.metrics.customerAcquisitionCost -ne 2000) { throw "Finance calculator CAC regression." }
if ($finance.metrics.estimatedLifetimeValue -ne 40000) { throw "Finance calculator LTV regression." }
if ($finance.metrics.cacPaybackMonths -ne 2.5) { throw "Finance calculator payback regression." }

$experiment = & (Join-Path $PSScriptRoot "estimate-experiment-sample.ps1") -InputPath (Join-Path $Root "tests/fixtures/calculators/experiment-valid.json") | ConvertFrom-Json
if ($experiment.result.samplePerVariant -ne 6511) { throw "Experiment sample-per-variant regression: $($experiment.result.samplePerVariant)." }
if ($experiment.result.totalSample -ne 13022) { throw "Experiment total-sample regression." }
if ($experiment.result.estimatedCalendarDays -ne 14) { throw "Experiment duration regression." }

if ($null -eq $finance.formulas -or $null -eq $finance.formulas.endingMrr) { throw "Finance calculator is missing a formulas field." }

function Assert-CalculatorFails {
    param([string]$ScriptPath, [string]$FixturePath, [string]$Description)
    $failed = $false
    try {
        & $ScriptPath -InputPath $FixturePath | Out-Null
    } catch {
        $failed = $true
    }
    if (-not $failed) { throw "Expected calculator failure did not occur: $Description" }
}

$financeScript = Join-Path $PSScriptRoot "calculate-finance-metrics.ps1"
$experimentScript = Join-Path $PSScriptRoot "estimate-experiment-sample.ps1"

Assert-CalculatorFails -ScriptPath $financeScript -FixturePath (Join-Path $Root "tests/fixtures/calculators/finance-invalid-negative.json") -Description "finance calculator must reject a negative input value"
Assert-CalculatorFails -ScriptPath $financeScript -FixturePath (Join-Path $Root "tests/fixtures/calculators/finance-invalid-rate.json") -Description "finance calculator must reject an out-of-range rate"
Assert-CalculatorFails -ScriptPath $financeScript -FixturePath (Join-Path $Root "tests/fixtures/calculators/finance-invalid-currency.json") -Description "finance calculator must require currency"
Assert-CalculatorFails -ScriptPath $experimentScript -FixturePath (Join-Path $Root "tests/fixtures/calculators/experiment-invalid.json") -Description "experiment calculator must reject an out-of-range baseline rate"

Write-Host "OK deterministic PM calculators passed (finance and experiment sample planning, including invalid-input rejection)."
