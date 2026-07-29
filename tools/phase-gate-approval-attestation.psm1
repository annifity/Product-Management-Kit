Set-StrictMode -Version Latest

$script:ApprovalAttestationDomain = "annifity.phase-gate-approval"
$script:ApprovalAttestationSchemaVersion = "1.0"
$script:ApprovalAttestationAlgorithm = "HMAC-SHA256"
$script:ApprovalAttestationSignaturePattern = "^hmac-sha256:[0-9a-f]{64}$"
$script:ApprovalAttestationKeyIdPattern = "^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$"
$script:ApprovalAttestationKeyIdEnvironmentVariable =
    "ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY_ID"
$script:ApprovalAttestationSecretEnvironmentVariable =
    "ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY"
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Test-AttestationObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object.PSObject.Properties[$Name]
}

function ConvertTo-AttestationCanonicalJson {
    param($Value)

    if ($null -eq $Value) {
        return "null"
    }
    if ($Value -is [string] -or $Value -is [char]) {
        return ([string]$Value | ConvertTo-Json -Compress)
    }
    if ($Value -is [bool]) {
        if ($Value) {
            return "true"
        }
        return "false"
    }
    if (
        $Value -is [byte] -or $Value -is [sbyte] -or
        $Value -is [int16] -or $Value -is [uint16] -or
        $Value -is [int32] -or $Value -is [uint32] -or
        $Value -is [int64] -or $Value -is [uint64] -or
        $Value -is [single] -or $Value -is [double] -or
        $Value -is [decimal]
    ) {
        return [System.Convert]::ToString(
            $Value,
            [System.Globalization.CultureInfo]::InvariantCulture
        )
    }
    if ($Value -is [System.Collections.IDictionary]) {
        [string[]]$keys = @(
            $Value.Keys | ForEach-Object { [string]$_ }
        )
        [System.Array]::Sort(
            $keys,
            [System.StringComparer]::Ordinal
        )
        $parts = foreach ($key in $keys) {
            $encodedKey = ([string]$key | ConvertTo-Json -Compress)
            "$encodedKey`:$((ConvertTo-AttestationCanonicalJson -Value $Value[$key]))"
        }
        return "{$($parts -join ',')}"
    }

    $properties = @($Value.PSObject.Properties)
    $isObject = $Value -is [pscustomobject] -or (
        $properties.Count -gt 0 -and
        -not ($Value -is [System.Collections.IEnumerable])
    )
    if ($isObject) {
        [string[]]$names = @(
            $properties | ForEach-Object { [string]$_.Name }
        )
        [System.Array]::Sort(
            $names,
            [System.StringComparer]::Ordinal
        )
        $parts = foreach ($name in $names) {
            $encodedName = ([string]$name | ConvertTo-Json -Compress)
            "$encodedName`:$((ConvertTo-AttestationCanonicalJson -Value $Value.PSObject.Properties[$name].Value))"
        }
        return "{$($parts -join ',')}"
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $parts = foreach ($item in $Value) {
            ConvertTo-AttestationCanonicalJson -Value $item
        }
        return "[$($parts -join ',')]"
    }

    return ([string]$Value | ConvertTo-Json -Compress)
}

function Get-ApprovalWithoutAttestation {
    param([Parameter(Mandatory = $true)]$Approval)

    $unsigned = [ordered]@{}
    foreach ($property in @($Approval.PSObject.Properties)) {
        if ([string]$property.Name -ieq "attestation") {
            continue
        }
        $unsigned[[string]$property.Name] = $property.Value
    }
    return $unsigned
}

function Get-AttestationPayloadBytes {
    param(
        [Parameter(Mandatory = $true)]$Approval,
        [Parameter(Mandatory = $true)][string]$KeyId
    )

    $payload = [ordered]@{
        domain = $script:ApprovalAttestationDomain
        schemaVersion = $script:ApprovalAttestationSchemaVersion
        algorithm = $script:ApprovalAttestationAlgorithm
        keyId = $KeyId
        approval = Get-ApprovalWithoutAttestation -Approval $Approval
    }
    $canonical = ConvertTo-AttestationCanonicalJson -Value $payload
    return $script:Utf8NoBom.GetBytes($canonical)
}

function Get-AttestationKeyConfiguration {
    $keyId = [Environment]::GetEnvironmentVariable(
        $script:ApprovalAttestationKeyIdEnvironmentVariable,
        [EnvironmentVariableTarget]::Process
    )
    if ([string]::IsNullOrWhiteSpace($keyId)) {
        return [pscustomobject][ordered]@{
            valid = $false
            reason = "approval-attestation-key-missing"
            keyId = $null
            keyBytes = $null
        }
    }
    if ($keyId -cne $keyId.Trim() -or
        $keyId -cnotmatch $script:ApprovalAttestationKeyIdPattern) {
        return [pscustomobject][ordered]@{
            valid = $false
            reason = "approval-attestation-key-invalid"
            keyId = $null
            keyBytes = $null
        }
    }

    $secret = [Environment]::GetEnvironmentVariable(
        $script:ApprovalAttestationSecretEnvironmentVariable,
        [EnvironmentVariableTarget]::Process
    )
    if ([string]::IsNullOrWhiteSpace($secret)) {
        return [pscustomobject][ordered]@{
            valid = $false
            reason = "approval-attestation-key-missing"
            keyId = $keyId
            keyBytes = $null
        }
    }

    try {
        [byte[]]$keyBytes = [Convert]::FromBase64String($secret.Trim())
    }
    catch {
        return [pscustomobject][ordered]@{
            valid = $false
            reason = "approval-attestation-key-invalid"
            keyId = $keyId
            keyBytes = $null
        }
    }
    if ($keyBytes.Length -lt 32) {
        [System.Array]::Clear($keyBytes, 0, $keyBytes.Length)
        return [pscustomobject][ordered]@{
            valid = $false
            reason = "approval-attestation-key-invalid"
            keyId = $keyId
            keyBytes = $null
        }
    }

    return [pscustomobject][ordered]@{
        valid = $true
        reason = $null
        keyId = $keyId
        keyBytes = $keyBytes
    }
}

function Get-HmacSha256Bytes {
    param(
        [Parameter(Mandatory = $true)][byte[]]$KeyBytes,
        [Parameter(Mandatory = $true)][byte[]]$PayloadBytes
    )

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    try {
        $hmac.Key = $KeyBytes
        return [byte[]]$hmac.ComputeHash($PayloadBytes)
    }
    finally {
        $hmac.Dispose()
    }
}

function ConvertFrom-LowerHex {
    param([Parameter(Mandatory = $true)][string]$Value)

    $bytes = New-Object byte[] ($Value.Length / 2)
    for ($index = 0; $index -lt $bytes.Length; $index++) {
        $bytes[$index] = [Convert]::ToByte(
            $Value.Substring($index * 2, 2),
            16
        )
    }
    return [byte[]]$bytes
}

function Test-FixedTimeEqual {
    param(
        [Parameter(Mandatory = $true)][byte[]]$Expected,
        [Parameter(Mandatory = $true)][byte[]]$Actual
    )

    if ($Expected.Length -ne $Actual.Length) {
        return $false
    }
    $difference = 0
    for ($index = 0; $index -lt $Expected.Length; $index++) {
        $difference = $difference -bor (
            [int]$Expected[$index] -bxor [int]$Actual[$index]
        )
    }
    return $difference -eq 0
}

function New-PhaseGateApprovalAttestation {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Approval)

    $configuration = Get-AttestationKeyConfiguration
    if (-not [bool]$configuration.valid) {
        throw "$($configuration.reason): configure the phase-gate approval HMAC key in the process environment."
    }

    [byte[]]$payloadBytes = $null
    [byte[]]$signatureBytes = $null
    try {
        $payloadBytes = Get-AttestationPayloadBytes `
            -Approval $Approval `
            -KeyId ([string]$configuration.keyId)
        $signatureBytes = Get-HmacSha256Bytes `
            -KeyBytes ([byte[]]$configuration.keyBytes) `
            -PayloadBytes $payloadBytes
        $signature = "hmac-sha256:" + (
            ($signatureBytes | ForEach-Object { $_.ToString("x2") }) -join ""
        )
        return [pscustomobject][ordered]@{
            schemaVersion = $script:ApprovalAttestationSchemaVersion
            algorithm = $script:ApprovalAttestationAlgorithm
            keyId = [string]$configuration.keyId
            signature = $signature
        }
    }
    finally {
        if ($null -ne $configuration.keyBytes) {
            [System.Array]::Clear(
                [byte[]]$configuration.keyBytes,
                0,
                ([byte[]]$configuration.keyBytes).Length
            )
        }
        if ($null -ne $payloadBytes) {
            [System.Array]::Clear($payloadBytes, 0, $payloadBytes.Length)
        }
        if ($null -ne $signatureBytes) {
            [System.Array]::Clear($signatureBytes, 0, $signatureBytes.Length)
        }
    }
}

function Test-PhaseGateApprovalAttestation {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Approval)

    if (-not (Test-AttestationObjectProperty -Object $Approval -Name "attestation") -or
        $null -eq $Approval.attestation) {
        return [pscustomobject][ordered]@{
            valid = $false
            status = "missing"
            reason = "approval-attestation-missing"
            keyId = $null
        }
    }

    $attestation = $Approval.attestation
    if ($attestation -is [string] -or
        $attestation -is [System.Collections.IEnumerable] -or
        $null -eq $attestation.PSObject) {
        return [pscustomobject][ordered]@{
            valid = $false
            status = "invalid"
            reason = "approval-attestation-invalid"
            keyId = $null
        }
    }

    $allowedProperties = @(
        "schemaVersion",
        "algorithm",
        "keyId",
        "signature"
    )
    foreach ($property in @($attestation.PSObject.Properties)) {
        if ($allowedProperties -cnotcontains [string]$property.Name) {
            return [pscustomobject][ordered]@{
                valid = $false
                status = "invalid"
                reason = "approval-attestation-invalid"
                keyId = $null
            }
        }
    }
    foreach ($name in $allowedProperties) {
        if (-not (Test-AttestationObjectProperty -Object $attestation -Name $name)) {
            return [pscustomobject][ordered]@{
                valid = $false
                status = "invalid"
                reason = "approval-attestation-invalid"
                keyId = $null
            }
        }
        $value = [string]$attestation.$name
        if ([string]::IsNullOrWhiteSpace($value) -or $value -cne $value.Trim()) {
            return [pscustomobject][ordered]@{
                valid = $false
                status = "invalid"
                reason = "approval-attestation-invalid"
                keyId = $null
            }
        }
    }

    $keyId = [string]$attestation.keyId
    if (
        [string]$attestation.schemaVersion -cne $script:ApprovalAttestationSchemaVersion -or
        [string]$attestation.algorithm -cne $script:ApprovalAttestationAlgorithm -or
        $keyId -cnotmatch $script:ApprovalAttestationKeyIdPattern -or
        [string]$attestation.signature -cnotmatch $script:ApprovalAttestationSignaturePattern
    ) {
        return [pscustomobject][ordered]@{
            valid = $false
            status = "invalid"
            reason = "approval-attestation-invalid"
            keyId = $keyId
        }
    }

    $configuration = Get-AttestationKeyConfiguration
    if (-not [bool]$configuration.valid) {
        $status = if ([string]$configuration.reason -ceq
            "approval-attestation-key-invalid") {
            "key-invalid"
        }
        else {
            "key-missing"
        }
        return [pscustomobject][ordered]@{
            valid = $false
            status = $status
            reason = [string]$configuration.reason
            keyId = $keyId
        }
    }
    if ([string]$configuration.keyId -cne $keyId) {
        [System.Array]::Clear(
            [byte[]]$configuration.keyBytes,
            0,
            ([byte[]]$configuration.keyBytes).Length
        )
        return [pscustomobject][ordered]@{
            valid = $false
            status = "key-unknown"
            reason = "approval-attestation-key-unknown"
            keyId = $keyId
        }
    }

    [byte[]]$payloadBytes = $null
    [byte[]]$expectedBytes = $null
    [byte[]]$actualBytes = $null
    try {
        $payloadBytes = Get-AttestationPayloadBytes `
            -Approval $Approval `
            -KeyId $keyId
        $expectedBytes = Get-HmacSha256Bytes `
            -KeyBytes ([byte[]]$configuration.keyBytes) `
            -PayloadBytes $payloadBytes
        $actualHex = ([string]$attestation.signature).Substring(
            "hmac-sha256:".Length
        )
        $actualBytes = ConvertFrom-LowerHex -Value $actualHex
        $valid = Test-FixedTimeEqual `
            -Expected $expectedBytes `
            -Actual $actualBytes
        if (-not $valid) {
            return [pscustomobject][ordered]@{
                valid = $false
                status = "invalid"
                reason = "approval-attestation-invalid"
                keyId = $keyId
            }
        }
        return [pscustomobject][ordered]@{
            valid = $true
            status = "valid"
            reason = $null
            keyId = $keyId
        }
    }
    finally {
        [System.Array]::Clear(
            [byte[]]$configuration.keyBytes,
            0,
            ([byte[]]$configuration.keyBytes).Length
        )
        if ($null -ne $payloadBytes) {
            [System.Array]::Clear($payloadBytes, 0, $payloadBytes.Length)
        }
        if ($null -ne $expectedBytes) {
            [System.Array]::Clear($expectedBytes, 0, $expectedBytes.Length)
        }
        if ($null -ne $actualBytes) {
            [System.Array]::Clear($actualBytes, 0, $actualBytes.Length)
        }
    }
}

Export-ModuleMember -Function @(
    "New-PhaseGateApprovalAttestation",
    "Test-PhaseGateApprovalAttestation"
)
