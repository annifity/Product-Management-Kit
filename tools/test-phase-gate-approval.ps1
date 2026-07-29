[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FixtureRoot = Join-Path $Root "tests/fixtures/phase-gate-approval"
$Resolver = Join-Path $Root "tools/resolve-phase-gate-approval.ps1"
$Signer = Join-Path $Root "tools/sign-phase-gate-approval.ps1"
$AttestationModule = Join-Path $Root "tools/phase-gate-approval-attestation.psm1"
$KeyIdEnvironmentVariable = "ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY_ID"
$SecretEnvironmentVariable = "ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY"
$TestKeyId = "phase-gate-test-key-v1"
$TestSecret = [Convert]::ToBase64String(
    [byte[]](1..32)
)
$WrongSecret = [Convert]::ToBase64String(
    [byte[]](33..64)
)

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Invoke-Request {
    param([Parameter(Mandatory = $true)][string]$Name)

    $path = Join-Path $FixtureRoot $Name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing phase-gate fixture: $Name"
    }
    return ((& $Resolver -RequestPath $path) -join "`n") | ConvertFrom-Json
}

function Read-Request {
    param([Parameter(Mandatory = $true)][string]$Name)

    return Get-Content -Raw -LiteralPath (Join-Path $FixtureRoot $Name) |
        ConvertFrom-Json
}

function Invoke-Object {
    param([Parameter(Mandatory = $true)]$Request)

    $json = $Request | ConvertTo-Json -Depth 100
    return ((& $Resolver -RequestJson $json) -join "`n") | ConvertFrom-Json
}

function Invoke-SignerText {
    param([Parameter(Mandatory = $true)]$Approval)

    $json = $Approval | ConvertTo-Json -Depth 100
    return (& $Signer -ApprovalJson $json) -join "`n"
}

foreach ($requiredPath in @(
    $Resolver,
    $Signer,
    $AttestationModule,
    (Join-Path $FixtureRoot "approval-context.request.json"),
    (Join-Path $FixtureRoot "approval-context-reordered.request.json"),
    (Join-Path $FixtureRoot "question-default.request.json"),
    (Join-Path $FixtureRoot "question-batch.request.json"),
    (Join-Path $FixtureRoot "invalid-batch.request.json")
)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Phase-gate approval test is missing required path: $requiredPath"
    }
}

$fixtureHashesBefore = [ordered]@{}
foreach ($file in Get-ChildItem -LiteralPath $FixtureRoot -File | Sort-Object Name) {
    $fixtureHashesBefore[$file.Name] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
}

$originalKeyId = [Environment]::GetEnvironmentVariable(
    $KeyIdEnvironmentVariable,
    [EnvironmentVariableTarget]::Process
)
$originalSecret = [Environment]::GetEnvironmentVariable(
    $SecretEnvironmentVariable,
    [EnvironmentVariableTarget]::Process
)

try {
    [Environment]::SetEnvironmentVariable(
        $KeyIdEnvironmentVariable,
        $TestKeyId,
        [EnvironmentVariableTarget]::Process
    )
    [Environment]::SetEnvironmentVariable(
        $SecretEnvironmentVariable,
        $TestSecret,
        [EnvironmentVariableTarget]::Process
    )
    $signerParameters = @((Get-Command -Name $Signer).Parameters.Keys)
    Assert-True `
        -Condition (
            $signerParameters -cnotcontains "Secret" -and
            $signerParameters -cnotcontains "Key" -and
            $signerParameters -cnotcontains "KeyId"
        ) `
        -Message "Signer must not accept key material through command parameters."

    $base = Invoke-Request -Name "approval-context.request.json"
    $repeatTextOne = (& $Resolver `
        -RequestPath (Join-Path $FixtureRoot "approval-context.request.json")) -join "`n"
    $repeatTextTwo = (& $Resolver `
        -RequestPath (Join-Path $FixtureRoot "approval-context.request.json")) -join "`n"
    Assert-True `
        -Condition ($repeatTextOne -ceq $repeatTextTwo) `
        -Message "Identical phase-gate requests must produce byte-identical output."
    Assert-True `
        -Condition ([string]$base.gate.fingerprints.gate -match "^sha256:[0-9a-f]{64}$") `
        -Message "Gate fingerprint must be lowercase SHA-256."
    Assert-True `
        -Condition ([string]$base.approval.reuseStatus -eq "fresh-approval-required") `
        -Message "A gate with no prior approval must require a fresh approval."
    Assert-True `
        -Condition ($base.gate.evidence[0].id -eq "EV-A") `
        -Message "Evidence must be canonicalized by stable ID."

    $reordered = Invoke-Request -Name "approval-context-reordered.request.json"
    Assert-True `
        -Condition ([string]$base.gate.fingerprints.gate -ceq [string]$reordered.gate.fingerprints.gate) `
        -Message "Evidence order and equivalent timestamp spelling must not change the gate fingerprint."

    $baseRequestText = Get-Content -Raw -LiteralPath (
        Join-Path $FixtureRoot "approval-context.request.json"
    )
    $fromJson = ((& $Resolver -RequestJson $baseRequestText) -join "`n") |
        ConvertFrom-Json
    Assert-True `
        -Condition ([string]$fromJson.gate.fingerprints.gate -ceq [string]$base.gate.fingerprints.gate) `
        -Message "-RequestPath and -RequestJson must resolve the same gate fingerprint."

    $approvedRequest = Read-Request -Name "approval-context.request.json"
    $unsignedApproval = [ordered]@{
        approvalId = "APP-SPEC-001"
        gateId = [string]$approvedRequest.gateId
        gateFingerprint = [string]$base.gate.fingerprints.gate
        sourceFingerprint = [string]$approvedRequest.sourceFingerprint
        profileFingerprint = [string]$approvedRequest.profileFingerprint
        evidence = @($approvedRequest.evidence)
        materialQuestions = @()
        decision = "approved"
        status = "active"
        decidedBy = "user:product-owner"
        decidedAt = "2026-07-27T00:00:00Z"
        expiresAt = "2026-08-11T00:00:00Z"
        invalidatedAt = $null
        invalidationReasons = @()
    }
    $signedTextOne = Invoke-SignerText -Approval $unsignedApproval
    $signedTextTwo = Invoke-SignerText -Approval $unsignedApproval
    $signedApproval = $signedTextOne | ConvertFrom-Json
    Assert-True `
        -Condition (
            [string]$signedApproval.attestation.signature -match
            "^hmac-sha256:[0-9a-f]{64}$"
        ) `
        -Message "Signer must emit a lowercase HMAC-SHA256 signature."
    Assert-True `
        -Condition (
            [string]$signedApproval.attestation.signature -ceq
            [string](($signedTextTwo | ConvertFrom-Json).attestation.signature)
        ) `
        -Message "Identical unsigned approvals must produce deterministic signatures."
    Assert-True `
        -Condition (
            [string]$signedApproval.attestation.signature -ceq
            "hmac-sha256:1edac66583abff56de2608f5febf800dafcba36cdbacfc702ae82b2938480858"
        ) `
        -Message "Signer must match the independent canonical HMAC golden vector."

    $reorderedUnsignedApproval = [ordered]@{}
    foreach ($propertyName in @(
        $unsignedApproval.Keys | Sort-Object -Descending
    )) {
        $reorderedUnsignedApproval[$propertyName] = $unsignedApproval[$propertyName]
    }
    $reorderedSignature = [string]((
        Invoke-SignerText -Approval $reorderedUnsignedApproval |
            ConvertFrom-Json
    ).attestation.signature)
    Assert-True `
        -Condition (
            [string]$signedApproval.attestation.signature -ceq
            $reorderedSignature
        ) `
        -Message "Approval property order must not change the canonical signature."
    Assert-True `
        -Condition ($signedTextOne -notmatch [regex]::Escape($TestSecret)) `
        -Message "Signer output must never leak HMAC key material."

    $approvedRequest.priorApproval = $signedApproval
    $approved = Invoke-Object -Request $approvedRequest
    Assert-True `
        -Condition ([bool]$approved.approval.reusable) `
        -Message "A matching active approved record must be reusable."
    Assert-True `
        -Condition ([string]$approved.approval.reuseStatus -eq "reused") `
        -Message "Matching approval must report reused status."
    Assert-True `
        -Condition (
            [string]$approved.approval.attestationStatus -eq "valid" -and
            [string]$approved.approval.attestationKeyId -eq $TestKeyId
        ) `
        -Message "Matching approval must report verified attestation provenance."
    $approvedOutput = $approved | ConvertTo-Json -Depth 100 -Compress
    Assert-True `
        -Condition ($approvedOutput -notmatch [regex]::Escape($TestSecret)) `
        -Message "Resolver output must never leak HMAC key material."

    $forgedRequest = Read-Request -Name "approval-context.request.json"
    $forgedRequest.priorApproval = $unsignedApproval
    $forged = Invoke-Object -Request $forgedRequest
    Assert-True `
        -Condition (
            -not [bool]$forged.approval.reusable -and
            [string]$forged.approval.reuseStatus -eq "invalid-attestation" -and
            @($forged.approval.reasons) -contains "approval-attestation-missing"
        ) `
        -Message "A copied gate fingerprint without an attestation must not be reusable."

    $tamperedRequest = Read-Request -Name "approval-context.request.json"
    $tamperedApproval = (
        $signedApproval | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    )
    $tamperedApproval.decidedBy = "user:forged-approver"
    $tamperedRequest.priorApproval = $tamperedApproval
    $tampered = Invoke-Object -Request $tamperedRequest
    Assert-True `
        -Condition (
            -not [bool]$tampered.approval.reusable -and
            [string]$tampered.approval.reuseStatus -eq "invalid-attestation" -and
            @($tampered.approval.reasons) -contains "approval-attestation-invalid"
        ) `
        -Message "Changing any signed approval field must invalidate the attestation."

    $nestedTamperRequest = Read-Request -Name "approval-context.request.json"
    $nestedTamperApproval = (
        $signedApproval | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    )
    $nestedTamperApproval.evidence[0].fingerprint = (
        "sha256:" + ("9" * 64)
    )
    $nestedTamperRequest.priorApproval = $nestedTamperApproval
    $nestedTamper = Invoke-Object -Request $nestedTamperRequest
    Assert-True `
        -Condition (
            -not [bool]$nestedTamper.approval.reusable -and
            @($nestedTamper.approval.reasons) -contains
                "approval-attestation-invalid"
        ) `
        -Message "Changing a nested signed field must invalidate the attestation."

    $corruptSignatureRequest = Read-Request -Name "approval-context.request.json"
    $corruptSignatureApproval = (
        $signedApproval | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    )
    $corruptSignatureApproval.attestation.signature = (
        "hmac-sha256:" + ("0" * 64)
    )
    $corruptSignatureRequest.priorApproval = $corruptSignatureApproval
    $corruptSignature = Invoke-Object -Request $corruptSignatureRequest
    Assert-True `
        -Condition (
            -not [bool]$corruptSignature.approval.reusable -and
            @($corruptSignature.approval.reasons) -contains
                "approval-attestation-invalid"
        ) `
        -Message "A corrupted signature must fail closed."

    $malformedAttestationRequest = Read-Request -Name "approval-context.request.json"
    $malformedAttestationApproval = (
        $signedApproval | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    )
    $malformedAttestationApproval.attestation |
        Add-Member -NotePropertyName "unexpected" -NotePropertyValue "field"
    $malformedAttestationRequest.priorApproval = $malformedAttestationApproval
    $malformedAttestation = Invoke-Object -Request $malformedAttestationRequest
    Assert-True `
        -Condition (
            -not [bool]$malformedAttestation.approval.reusable -and
            @($malformedAttestation.approval.reasons) -contains
                "approval-attestation-invalid"
        ) `
        -Message "Unexpected attestation members must fail closed."

    [Environment]::SetEnvironmentVariable(
        $SecretEnvironmentVariable,
        $null,
        [EnvironmentVariableTarget]::Process
    )
    $missingKey = Invoke-Object -Request $approvedRequest
    Assert-True `
        -Condition (
            -not [bool]$missingKey.approval.reusable -and
            @($missingKey.approval.reasons) -contains
                "approval-attestation-key-missing"
        ) `
        -Message "A missing environment key must fail closed with a stable reason."

    [Environment]::SetEnvironmentVariable(
        $SecretEnvironmentVariable,
        "not-base64",
        [EnvironmentVariableTarget]::Process
    )
    $invalidKey = Invoke-Object -Request $approvedRequest
    Assert-True `
        -Condition (
            -not [bool]$invalidKey.approval.reusable -and
            @($invalidKey.approval.reasons) -contains
                "approval-attestation-key-invalid"
        ) `
        -Message "Malformed environment key material must use a stable reason."

    [Environment]::SetEnvironmentVariable(
        $SecretEnvironmentVariable,
        $WrongSecret,
        [EnvironmentVariableTarget]::Process
    )
    $wrongKey = Invoke-Object -Request $approvedRequest
    Assert-True `
        -Condition (
            -not [bool]$wrongKey.approval.reusable -and
            @($wrongKey.approval.reasons) -contains
                "approval-attestation-invalid"
        ) `
        -Message "A wrong HMAC key must not validate an approval."

    [Environment]::SetEnvironmentVariable(
        $SecretEnvironmentVariable,
        $TestSecret,
        [EnvironmentVariableTarget]::Process
    )
    [Environment]::SetEnvironmentVariable(
        $KeyIdEnvironmentVariable,
        "phase-gate-unknown-key",
        [EnvironmentVariableTarget]::Process
    )
    $unknownKey = Invoke-Object -Request $approvedRequest
    Assert-True `
        -Condition (
            -not [bool]$unknownKey.approval.reusable -and
            @($unknownKey.approval.reasons) -contains
                "approval-attestation-key-unknown"
        ) `
        -Message "An unconfigured attestation key ID must use a stable reason."
    [Environment]::SetEnvironmentVariable(
        $KeyIdEnvironmentVariable,
        $TestKeyId,
        [EnvironmentVariableTarget]::Process
    )
    [Environment]::SetEnvironmentVariable(
        $KeyIdEnvironmentVariable,
        " $TestKeyId",
        [EnvironmentVariableTarget]::Process
    )
    $invalidKeyId = Invoke-Object -Request $approvedRequest
    Assert-True `
        -Condition (
            -not [bool]$invalidKeyId.approval.reusable -and
            @($invalidKeyId.approval.reasons) -contains
                "approval-attestation-key-invalid"
        ) `
        -Message "Environment key ID whitespace must fail closed."
    [Environment]::SetEnvironmentVariable(
        $KeyIdEnvironmentVariable,
        $TestKeyId,
        [EnvironmentVariableTarget]::Process
    )

    $staleRequest = Read-Request -Name "approval-context.request.json"
    $staleRequest.profileFingerprint = "sha256:5555555555555555555555555555555555555555555555555555555555555555"
    $staleRequest.priorApproval = $approvedRequest.priorApproval
    $stale = Invoke-Object -Request $staleRequest
    Assert-True `
        -Condition (-not [bool]$stale.approval.reusable) `
        -Message "Changed profile fingerprint must prevent approval reuse."
    Assert-True `
        -Condition ([string]$stale.approval.reuseStatus -eq "stale") `
        -Message "Changed profile fingerprint must report stale status."
    Assert-True `
        -Condition (@($stale.approval.reasons) -contains "profile-fingerprint-changed") `
        -Message "Stale result must explain the changed profile fingerprint."

    $sourceStaleRequest = Read-Request -Name "approval-context.request.json"
    $sourceStaleRequest.sourceFingerprint = "sha256:6666666666666666666666666666666666666666666666666666666666666666"
    $sourceStaleRequest.priorApproval = $approvedRequest.priorApproval
    $sourceStale = Invoke-Object -Request $sourceStaleRequest
    Assert-True `
        -Condition (
            [string]$sourceStale.approval.reuseStatus -eq "stale" -and
            @($sourceStale.approval.reasons) -contains "source-fingerprint-changed"
        ) `
        -Message "Changed source fingerprint must prevent and explain approval reuse."

    $expiredRequest = Read-Request -Name "approval-context.request.json"
    $expiredRequest.asOf = "2026-08-11T00:00:00Z"
    $expiredRequest.priorApproval = $approvedRequest.priorApproval
    $expired = Invoke-Object -Request $expiredRequest
    Assert-True `
        -Condition ([string]$expired.approval.reuseStatus -eq "expired") `
        -Message "Approval must expire at its exact expiresAt instant."

    $invalidatedRequest = Read-Request -Name "approval-context.request.json"
    $invalidatedRequest.priorApproval = $approvedRequest.priorApproval
    $invalidatedRequest.invalidationEvents = @(
        [ordered]@{
            id = "INV-001"
            reason = "The accepted source was superseded."
            recordedAt = "2026-07-28T00:00:00Z"
        }
    )
    $invalidated = Invoke-Object -Request $invalidatedRequest
    Assert-True `
        -Condition ([string]$invalidated.approval.reuseStatus -eq "invalidated") `
        -Message "A current invalidation event must prevent approval reuse."

    $defaultQuestions = Invoke-Request -Name "question-default.request.json"
    Assert-True `
        -Condition (@($defaultQuestions.questionPlan.askNow).Count -eq 1) `
        -Message "Default question policy must ask exactly one material question."
    Assert-True `
        -Condition ([string]$defaultQuestions.questionPlan.askNow[0].id -eq "Q-PROBLEM") `
        -Message "Default question selection must use rank then stable ID."
    $dependencyDeferred = @(
        $defaultQuestions.questionPlan.deferred |
            Where-Object { $_.id -eq "Q-DEPENDENT" }
    )
    Assert-True `
        -Condition (
            $dependencyDeferred.Count -eq 1 -and
            $dependencyDeferred[0].deferReason -eq "unresolved-dependency"
        ) `
        -Message "Dependent questions must stay deferred."

    $batchQuestions = Invoke-Request -Name "question-batch.request.json"
    Assert-True `
        -Condition ([string]$batchQuestions.questionPlan.mode -eq "explicit-independent-batch") `
        -Message "Explicit batch request must be visible in the question plan."
    Assert-True `
        -Condition (@($batchQuestions.questionPlan.askNow).Count -eq 3) `
        -Message "Explicit independent batch may select up to three questions."
    Assert-True `
        -Condition (
            (@($batchQuestions.questionPlan.askNow | ForEach-Object { $_.id }) -join ",") -eq
            "Q-01,Q-02,Q-03"
        ) `
        -Message "Batch selection must exclude a question with unresolved dependencies."

    $invalidBatchFailed = $false
    try {
        [void](Invoke-Request -Name "invalid-batch.request.json")
    }
    catch {
        $invalidBatchFailed = $_.Exception.Message -match "must be 1 unless"
    }
    Assert-True `
        -Condition $invalidBatchFailed `
        -Message "Multiple questions without an explicit batch request must fail closed."

    $invalidGateRequest = Read-Request -Name "approval-context.request.json"
    $invalidGateRequest.gateId = "phase.unknown.ready"
    $invalidGateFailed = $false
    try {
        [void](Invoke-Object -Request $invalidGateRequest)
    }
    catch {
        $invalidGateFailed = $_.Exception.Message -match "Unsupported stable phase-gate ID"
    }
    Assert-True `
        -Condition $invalidGateFailed `
        -Message "Resolver must reject an unknown phase-gate ID."
}
finally {
    [Environment]::SetEnvironmentVariable(
        $KeyIdEnvironmentVariable,
        $originalKeyId,
        [EnvironmentVariableTarget]::Process
    )
    [Environment]::SetEnvironmentVariable(
        $SecretEnvironmentVariable,
        $originalSecret,
        [EnvironmentVariableTarget]::Process
    )
    foreach ($file in Get-ChildItem -LiteralPath $FixtureRoot -File | Sort-Object Name) {
        $after = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        if (-not $fixtureHashesBefore.Contains($file.Name) -or
            $fixtureHashesBefore[$file.Name] -ne $after) {
            throw "Phase-gate tests modified fixture '$($file.Name)'."
        }
    }
}

Write-Host "OK phase-gate approval resolver tests passed."
