[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$contractPath = Join-Path $Root "tests/fixtures/contracts/pm-decision-quality-contract.json"
$contract = [System.IO.File]::ReadAllText($contractPath) | ConvertFrom-Json
if ($contract.schemaVersion -ne "1.0") { throw "Unsupported PM decision quality contract version." }

foreach ($surface in @($contract.surfaces)) {
    $path = Join-Path $Root ([string]$surface.path)
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing PM quality surface: $($surface.path)" }
    $content = [System.IO.File]::ReadAllText($path)
    foreach ($term in @($surface.requiredTerms)) {
        if ($content.IndexOf([string]$term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "$($surface.path) is missing PM quality term '$term'."
        }
    }
}

foreach ($property in $contract.skillRoutes.PSObject.Properties) {
    $skillPath = Join-Path $Root "skills/$($property.Name)/SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) { throw "Missing routed skill '$($property.Name)'." }
    $content = [System.IO.File]::ReadAllText($skillPath)
    foreach ($route in @($property.Value)) {
        if ($content.IndexOf([string]$route, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "Skill '$($property.Name)' is missing PM quality route '$route'."
        }
    }
}

foreach ($calculator in @($contract.calculators)) {
    $path = Join-Path $Root ([string]$calculator)
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing deterministic calculator: $calculator" }
    $content = [System.IO.File]::ReadAllText($path)
    foreach ($required in @("Set-StrictMode", "ErrorActionPreference", "ConvertFrom-Json", "ConvertTo-Json")) {
        if ($content.IndexOf($required, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "Calculator '$calculator' is missing deterministic guard '$required'."
        }
    }
}

Write-Host "OK PM decision and artifact quality contract passed."
