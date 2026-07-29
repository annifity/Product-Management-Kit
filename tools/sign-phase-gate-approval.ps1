[CmdletBinding(DefaultParameterSetName = "Path")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "Path")]
    [string]$ApprovalPath,

    [Parameter(Mandatory = $true, ParameterSetName = "Json")]
    [string]$ApprovalJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$AttestationModule = Join-Path $PSScriptRoot "phase-gate-approval-attestation.psm1"
Import-Module `
    -Name $AttestationModule `
    -Force `
    -DisableNameChecking `
    -ErrorAction Stop

if ($PSCmdlet.ParameterSetName -eq "Path") {
    $fullApprovalPath = if ([System.IO.Path]::IsPathRooted($ApprovalPath)) {
        [System.IO.Path]::GetFullPath($ApprovalPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $ApprovalPath))
    }
    if (-not (Test-Path -LiteralPath $fullApprovalPath -PathType Leaf)) {
        throw "Unsigned phase-gate approval does not exist: $ApprovalPath"
    }
    $approvalText = [System.IO.File]::ReadAllText(
        $fullApprovalPath,
        $Utf8NoBom
    )
}
else {
    $approvalText = $ApprovalJson
}

try {
    $approval = $approvalText | ConvertFrom-Json
}
catch {
    throw "Unsigned phase-gate approval is not valid JSON: $($_.Exception.Message)"
}
if ($null -eq $approval -or
    $approval -is [string] -or
    $approval -is [System.Collections.IEnumerable]) {
    throw "Unsigned phase-gate approval must be a JSON object."
}

$allowedProperties = @(
    "approvalId",
    "gateId",
    "gateFingerprint",
    "sourceFingerprint",
    "profileFingerprint",
    "evidence",
    "materialQuestions",
    "decision",
    "status",
    "decidedBy",
    "decidedAt",
    "expiresAt",
    "invalidatedAt",
    "invalidationReasons"
)
foreach ($property in @($approval.PSObject.Properties)) {
    if ([string]$property.Name -ieq "attestation") {
        throw "Approval is already attested; the signer accepts only an unsigned record."
    }
    if ($allowedProperties -cnotcontains [string]$property.Name) {
        throw "Unsigned phase-gate approval contains unsupported property '$($property.Name)'."
    }
}
foreach ($name in $allowedProperties) {
    if ($null -eq $approval.PSObject.Properties[$name]) {
        throw "Unsigned phase-gate approval is missing required property '$name'."
    }
}

$signedApproval = [ordered]@{}
foreach ($property in @($approval.PSObject.Properties)) {
    $signedApproval[[string]$property.Name] = $property.Value
}
$signedApproval["attestation"] = New-PhaseGateApprovalAttestation `
    -Approval $approval

Write-Output (
    (($signedApproval | ConvertTo-Json -Depth 100) -replace "`r`n", "`n")
)
