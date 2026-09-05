[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Rate {
    param($Object, [string]$Name)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { throw "Missing required input '$Name'." }
    $value = [double]$property.Value
    if ($value -le 0 -or $value -ge 1) { throw "Input '$Name' must be greater than 0 and less than 1." }
    return $value
}

function Resolve-ZAlpha {
    param([double]$Alpha)
    if ([math]::Abs($Alpha - 0.10) -lt 0.000001) { return 1.644854 }
    if ([math]::Abs($Alpha - 0.05) -lt 0.000001) { return 1.959964 }
    if ([math]::Abs($Alpha - 0.01) -lt 0.000001) { return 2.575829 }
    throw "alpha must be one of 0.10, 0.05, or 0.01 for the deterministic lookup."
}

function Resolve-ZPower {
    param([double]$Power)
    if ([math]::Abs($Power - 0.80) -lt 0.000001) { return 0.841621 }
    if ([math]::Abs($Power - 0.90) -lt 0.000001) { return 1.281552 }
    if ([math]::Abs($Power - 0.95) -lt 0.000001) { return 1.644854 }
    throw "power must be one of 0.80, 0.90, or 0.95 for the deterministic lookup."
}

$resolved = (Resolve-Path -LiteralPath $InputPath).Path
$inputData = [System.IO.File]::ReadAllText($resolved) | ConvertFrom-Json
$baseline = Require-Rate $inputData "baselineRate"
$absoluteMde = Require-Rate $inputData "absoluteMde"
$alpha = Require-Rate $inputData "alpha"
$power = Require-Rate $inputData "power"
$variantCount = if ($inputData.PSObject.Properties["variantCount"]) { [int]$inputData.variantCount } else { 2 }
if ($variantCount -lt 2) { throw "variantCount must be at least 2." }
$candidate = $baseline + $absoluteMde
if ($candidate -ge 1) { throw "baselineRate + absoluteMde must be less than 1." }

$zAlpha = Resolve-ZAlpha $alpha
$zPower = Resolve-ZPower $power
$pooled = ($baseline + $candidate) / 2
$perVariant = [math]::Ceiling((2 * [math]::Pow($zAlpha + $zPower, 2) * $pooled * (1 - $pooled)) / [math]::Pow($absoluteMde, 2))
$total = $perVariant * $variantCount

$dailyEligible = if ($inputData.PSObject.Properties["dailyEligibleTraffic"]) { [double]$inputData.dailyEligibleTraffic } else { 0 }
if ($dailyEligible -lt 0) { throw "dailyEligibleTraffic cannot be negative." }
$estimatedDays = if ($dailyEligible -eq 0) { $null } else { [math]::Ceiling($total / $dailyEligible) }

$result = [ordered]@{
    schemaVersion = "1.0"
    method = "normal approximation for equal-size two-sided proportion comparison"
    inputs = $inputData
    result = [ordered]@{
        candidateRate = [math]::Round($candidate, 6)
        relativeLift = [math]::Round($absoluteMde / $baseline, 6)
        samplePerVariant = [int]$perVariant
        totalSample = [int]$total
        estimatedCalendarDays = if ($null -eq $estimatedDays) { $null } else { [int]$estimatedDays }
    }
    limitations = @(
        "This is a planning approximation, not a sequential-testing or variance-reduction design.",
        "Adjust for exclusions, noncompliance, seasonality, multiple comparisons, and runtime cycles.",
        "Do not run an A/B test when traffic, reversibility, interference, or ethics make the design unsuitable."
    )
}

$result | ConvertTo-Json -Depth 8
