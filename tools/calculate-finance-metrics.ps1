[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Number {
    param($Object, [string]$Name, [switch]$AllowZero)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        throw "Missing required numeric input '$Name'."
    }
    $value = [double]$property.Value
    if ($value -lt 0 -or (-not $AllowZero -and $value -eq 0)) {
        throw "Input '$Name' must be $(if ($AllowZero) { 'zero or greater' } else { 'greater than zero' })."
    }
    return $value
}

function Require-Rate {
    param($Object, [string]$Name, [switch]$AllowZero)
    $value = Require-Number -Object $Object -Name $Name -AllowZero:$AllowZero
    if ($value -gt 1) { throw "Input '$Name' must be between 0 and 1." }
    return $value
}

function Require-String {
    param($Object, [string]$Name)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        throw "Missing required input '$Name'. Every metric here is currency-denominated; currency is material and cannot be inferred."
    }
    return [string]$property.Value
}

$resolved = (Resolve-Path -LiteralPath $InputPath).Path
$inputData = [System.IO.File]::ReadAllText($resolved) | ConvertFrom-Json

$currency = Require-String $inputData "currency"
$startingMrr = Require-Number $inputData "startingMrr"
$newMrr = Require-Number $inputData "newMrr" -AllowZero
$expansionMrr = Require-Number $inputData "expansionMrr" -AllowZero
$contractionMrr = Require-Number $inputData "contractionMrr" -AllowZero
$churnedMrr = Require-Number $inputData "churnedMrr" -AllowZero
$salesMarketingSpend = Require-Number $inputData "salesMarketingSpend" -AllowZero
$newCustomers = Require-Number $inputData "newCustomers" -AllowZero
$monthlyArpa = Require-Number $inputData "monthlyArpa"
$grossMarginRate = Require-Rate $inputData "grossMarginRate"
$monthlyLogoChurnRate = Require-Rate $inputData "monthlyLogoChurnRate"

$endingMrr = $startingMrr + $newMrr + $expansionMrr - $contractionMrr - $churnedMrr
if ($endingMrr -lt 0) { throw "Computed ending MRR is negative; verify contraction and churn inputs." }

$cac = if ($newCustomers -eq 0) { $null } else { $salesMarketingSpend / $newCustomers }
$ltv = if ($monthlyLogoChurnRate -eq 0) { $null } else { ($monthlyArpa * $grossMarginRate) / $monthlyLogoChurnRate }
$payback = if ($null -eq $cac -or ($monthlyArpa * $grossMarginRate) -eq 0) { $null } else { $cac / ($monthlyArpa * $grossMarginRate) }

$result = [ordered]@{
    schemaVersion = "1.0"
    units = [ordered]@{ currency = $currency; period = "month" }
    inputs = $inputData
    metrics = [ordered]@{
        endingMrr = [math]::Round($endingMrr, 2)
        endingArr = [math]::Round($endingMrr * 12, 2)
        netRevenueRetention = [math]::Round(($startingMrr + $expansionMrr - $contractionMrr - $churnedMrr) / $startingMrr, 6)
        grossRevenueRetention = [math]::Round(($startingMrr - $contractionMrr - $churnedMrr) / $startingMrr, 6)
        customerAcquisitionCost = if ($null -eq $cac) { $null } else { [math]::Round($cac, 2) }
        estimatedLifetimeValue = if ($null -eq $ltv) { $null } else { [math]::Round($ltv, 2) }
        cacPaybackMonths = if ($null -eq $payback) { $null } else { [math]::Round($payback, 2) }
    }
    formulas = [ordered]@{
        endingMrr = "startingMrr + newMrr + expansionMrr - contractionMrr - churnedMrr"
        endingArr = "endingMrr * 12"
        netRevenueRetention = "(startingMrr + expansionMrr - contractionMrr - churnedMrr) / startingMrr"
        grossRevenueRetention = "(startingMrr - contractionMrr - churnedMrr) / startingMrr"
        customerAcquisitionCost = "salesMarketingSpend / newCustomers"
        estimatedLifetimeValue = "(monthlyArpa * grossMarginRate) / monthlyLogoChurnRate"
        cacPaybackMonths = "customerAcquisitionCost / (monthlyArpa * grossMarginRate)"
    }
    limitations = @(
        "LTV uses the steady-state ARPA x gross-margin / logo-churn approximation.",
        "A null CAC or LTV means the required denominator was zero; no substitute benchmark was invented.",
        "Use cohort contribution margin and observed retention for an investment decision when available."
    )
}

$result | ConvertTo-Json -Depth 8
