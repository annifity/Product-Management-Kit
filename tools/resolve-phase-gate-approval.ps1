[CmdletBinding(DefaultParameterSetName = "Path")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "Path")]
    [string]$RequestPath,

    [Parameter(Mandatory = $true, ParameterSetName = "Json")]
    [string]$RequestJson
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
$StableGateIds = @(
    "phase.discovery.ready",
    "phase.brief.ready",
    "phase.prototype.ready",
    "phase.experiment.ready",
    "phase.validate.ready",
    "phase.learn.ready",
    "phase.strategy.ready",
    "phase.spec.ready",
    "phase.design.ready",
    "phase.plan.ready",
    "phase.execution.ready",
    "phase.ship.ready"
)
$FingerprintPattern = "^sha256:[0-9a-f]{64}$"

function Test-ObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object.PSObject.Properties[$Name]
}

function Assert-KnownProperties {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Names,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($property in @($Object.PSObject.Properties)) {
        if ($Names -notcontains [string]$property.Name) {
            throw "$Context contains unsupported property '$($property.Name)'."
        }
    }
}

function Get-RequiredString {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required property '$Name'."
    }
    $value = [string]$Object.$Name
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "$Context property '$Name' must be a non-empty string."
    }
    return $value.Trim()
}

function Get-OptionalArray {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        return @()
    }
    if ($null -eq $Object.$Name) {
        return @()
    }
    if ($Object.$Name -is [string]) {
        throw "'$Name' must be a JSON array."
    }
    return @($Object.$Name)
}

function Get-StrictBoolean {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [bool]$Default
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        return $Default
    }
    if ($Object.$Name -isnot [bool]) {
        throw "'$Name' must be a JSON boolean."
    }
    return [bool]$Object.$Name
}

function Assert-Fingerprint {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -cnotmatch $FingerprintPattern) {
        throw "$Context must use sha256 followed by 64 lowercase hexadecimal characters."
    }
}

function ConvertTo-CanonicalJson {
    param($Value)

    if ($null -eq $Value) {
        return "null"
    }
    if ($Value -is [string] -or $Value -is [char]) {
        return ([string]$Value | ConvertTo-Json -Compress)
    }
    if ($Value -is [bool]) {
        if ($Value) { return "true" }
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
        $parts = foreach ($key in @(
            $Value.Keys | ForEach-Object { [string]$_ } | Sort-Object
        )) {
            $encodedKey = ([string]$key | ConvertTo-Json -Compress)
            "$encodedKey`:$((ConvertTo-CanonicalJson -Value $Value[$key]))"
        }
        return "{$($parts -join ',')}"
    }

    $properties = @($Value.PSObject.Properties)
    $isObject = $Value -is [pscustomobject] -or (
        $properties.Count -gt 0 -and
        -not ($Value -is [System.Collections.IEnumerable])
    )
    if ($isObject) {
        $parts = foreach ($property in @($properties | Sort-Object Name)) {
            $encodedName = ([string]$property.Name | ConvertTo-Json -Compress)
            "$encodedName`:$((ConvertTo-CanonicalJson -Value $property.Value))"
        }
        return "{$($parts -join ',')}"
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $parts = foreach ($item in $Value) {
            ConvertTo-CanonicalJson -Value $item
        }
        return "[$($parts -join ',')]"
    }

    return ([string]$Value | ConvertTo-Json -Compress)
}

function Get-CanonicalFingerprint {
    param([Parameter(Mandatory = $true)]$Value)

    $bytes = $Utf8NoBom.GetBytes((ConvertTo-CanonicalJson -Value $Value))
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }
    return "sha256:" + (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
}

function ConvertTo-UtcInstant {
    param(
        [Parameter(Mandatory = $true)][string]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $parsed = [datetimeoffset]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AllowWhiteSpaces -bor
        [System.Globalization.DateTimeStyles]::AssumeUniversal -bor
        [System.Globalization.DateTimeStyles]::AdjustToUniversal
    if (-not [datetimeoffset]::TryParse(
        $Value,
        [System.Globalization.CultureInfo]::InvariantCulture,
        $styles,
        [ref]$parsed
    )) {
        throw "$Context must be an ISO-8601 timestamp."
    }
    return $parsed
}

function Format-UtcInstant {
    param([Parameter(Mandatory = $true)][datetimeoffset]$Value)

    return $Value.UtcDateTime.ToString(
        "o",
        [System.Globalization.CultureInfo]::InvariantCulture
    )
}

function ConvertTo-NormalizedEvidence {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Items,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$AllowEmpty
    )

    if (-not $AllowEmpty -and $Items.Count -eq 0) {
        throw "$Context must contain at least one evidence item."
    }

    $seen = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    $normalized = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Items) {
        if ($null -eq $item -or $item -is [string]) {
            throw "$Context entries must be JSON objects."
        }
        Assert-KnownProperties `
            -Object $item `
            -Names @("id", "kind", "source", "fingerprint") `
            -Context "$Context item"
        $id = Get-RequiredString -Object $item -Name "id" -Context "$Context item"
        if (-not $seen.Add($id)) {
            throw "$Context contains duplicate evidence ID '$id'."
        }
        $kind = Get-RequiredString -Object $item -Name "kind" -Context "$Context '$id'"
        $source = Get-RequiredString -Object $item -Name "source" -Context "$Context '$id'"
        $fingerprint = Get-RequiredString `
            -Object $item `
            -Name "fingerprint" `
            -Context "$Context '$id'"
        Assert-Fingerprint -Value $fingerprint -Context "$Context '$id' fingerprint"

        $normalized.Add([ordered]@{
            id = $id
            kind = $kind
            source = $source
            fingerprint = $fingerprint
        })
    }

    return [object[]]@($normalized | Sort-Object @{ Expression = { [string]$_.id } })
}

function ConvertTo-NormalizedQuestions {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Items,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $seen = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    $normalized = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $Items) {
        if ($null -eq $item -or $item -is [string]) {
            throw "$Context entries must be JSON objects."
        }
        Assert-KnownProperties `
            -Object $item `
            -Names @("id", "rank", "text", "dependsOnQuestionIds") `
            -Context "$Context item"
        $id = Get-RequiredString -Object $item -Name "id" -Context "$Context item"
        if (-not $seen.Add($id)) {
            throw "$Context contains duplicate question ID '$id'."
        }
        $text = Get-RequiredString -Object $item -Name "text" -Context "$Context '$id'"
        if (-not (Test-ObjectProperty -Object $item -Name "rank")) {
            throw "$Context '$id' is missing required property 'rank'."
        }
        $rank = 0
        if (-not [int]::TryParse(
            [string]$item.rank,
            [System.Globalization.NumberStyles]::Integer,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [ref]$rank
        ) -or $rank -lt 1) {
            throw "$Context '$id' rank must be a positive integer."
        }

        $dependencySeen = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::Ordinal
        )
        $dependencies = [System.Collections.Generic.List[string]]::new()
        foreach ($dependency in @(Get-OptionalArray -Object $item -Name "dependsOnQuestionIds")) {
            $dependencyId = [string]$dependency
            if ([string]::IsNullOrWhiteSpace($dependencyId)) {
                throw "$Context '$id' contains an empty dependency ID."
            }
            $dependencyId = $dependencyId.Trim()
            if ($dependencyId -ceq $id) {
                throw "$Context '$id' cannot depend on itself."
            }
            if (-not $dependencySeen.Add($dependencyId)) {
                throw "$Context '$id' contains duplicate dependency '$dependencyId'."
            }
            $dependencies.Add($dependencyId)
        }

        $normalized.Add([ordered]@{
            id = $id
            rank = $rank
            text = $text
            dependsOnQuestionIds = [string[]]@($dependencies | Sort-Object)
        })
    }

    return [object[]]@(
        $normalized |
            Sort-Object `
                @{ Expression = { [int]$_.rank } },
                @{ Expression = { [string]$_.id } }
    )
}

function Get-GateFingerprint {
    param(
        [Parameter(Mandatory = $true)][string]$GateId,
        [Parameter(Mandatory = $true)][string]$SourceFingerprint,
        [Parameter(Mandatory = $true)][string]$ProfileFingerprint,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Evidence,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$MaterialQuestions
    )

    return Get-CanonicalFingerprint -Value ([ordered]@{
        schemaVersion = "1.0"
        gateId = $GateId
        sourceFingerprint = $SourceFingerprint
        profileFingerprint = $ProfileFingerprint
        evidence = $Evidence
        materialQuestions = $MaterialQuestions
    })
}

if ($PSCmdlet.ParameterSetName -eq "Path") {
    $fullRequestPath = if ([System.IO.Path]::IsPathRooted($RequestPath)) {
        [System.IO.Path]::GetFullPath($RequestPath)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $RequestPath))
    }
    if (-not (Test-Path -LiteralPath $fullRequestPath -PathType Leaf)) {
        throw "Phase-gate request does not exist: $RequestPath"
    }
    $requestText = [System.IO.File]::ReadAllText($fullRequestPath, $Utf8NoBom)
}
else {
    $requestText = $RequestJson
}

try {
    $request = $requestText | ConvertFrom-Json
}
catch {
    throw "Phase-gate request is not valid JSON: $($_.Exception.Message)"
}
if ($null -eq $request -or $request -is [string]) {
    throw "Phase-gate request must be a JSON object."
}

Assert-KnownProperties `
    -Object $request `
    -Names @(
        "schemaVersion",
        "gateId",
        "sourceFingerprint",
        "profileFingerprint",
        "evidence",
        "materialQuestions",
        "questionPolicy",
        "asOf",
        "invalidationEvents",
        "priorApproval"
    ) `
    -Context "Phase-gate request"

$schemaVersion = Get-RequiredString `
    -Object $request `
    -Name "schemaVersion" `
    -Context "Phase-gate request"
if ($schemaVersion -cne "1.0") {
    throw "Phase-gate request schemaVersion must be '1.0'."
}

$gateId = Get-RequiredString -Object $request -Name "gateId" -Context "Phase-gate request"
if ($StableGateIds -cnotcontains $gateId) {
    throw "Unsupported stable phase-gate ID '$gateId'."
}

$sourceFingerprint = Get-RequiredString `
    -Object $request `
    -Name "sourceFingerprint" `
    -Context "Phase-gate request"
$profileFingerprint = Get-RequiredString `
    -Object $request `
    -Name "profileFingerprint" `
    -Context "Phase-gate request"
Assert-Fingerprint -Value $sourceFingerprint -Context "sourceFingerprint"
Assert-Fingerprint -Value $profileFingerprint -Context "profileFingerprint"

$evidence = @(
    ConvertTo-NormalizedEvidence `
        -Items @(Get-OptionalArray -Object $request -Name "evidence") `
        -Context "Phase-gate evidence"
)
$questions = @(
    ConvertTo-NormalizedQuestions `
        -Items @(Get-OptionalArray -Object $request -Name "materialQuestions") `
        -Context "Material questions"
)

$questionPolicy = if (Test-ObjectProperty -Object $request -Name "questionPolicy") {
    $request.questionPolicy
}
else {
    [pscustomobject]@{}
}
if ($null -eq $questionPolicy -or $questionPolicy -is [string]) {
    throw "questionPolicy must be a JSON object."
}
Assert-KnownProperties `
    -Object $questionPolicy `
    -Names @("explicitBatchRequested", "maxQuestions", "resolvedQuestionIds") `
    -Context "questionPolicy"

$explicitBatchRequested = Get-StrictBoolean `
    -Object $questionPolicy `
    -Name "explicitBatchRequested" `
    -Default $false
$maxQuestions = 1
if (Test-ObjectProperty -Object $questionPolicy -Name "maxQuestions") {
    if (-not [int]::TryParse(
        [string]$questionPolicy.maxQuestions,
        [System.Globalization.NumberStyles]::Integer,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [ref]$maxQuestions
    )) {
        throw "questionPolicy.maxQuestions must be an integer."
    }
}
if (-not $explicitBatchRequested -and $maxQuestions -ne 1) {
    throw "questionPolicy.maxQuestions must be 1 unless an explicit batch was requested."
}
if ($explicitBatchRequested -and ($maxQuestions -lt 1 -or $maxQuestions -gt 3)) {
    throw "An explicit question batch must contain between 1 and 3 questions."
}

$resolvedQuestionIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($resolvedQuestion in @(
    Get-OptionalArray -Object $questionPolicy -Name "resolvedQuestionIds"
)) {
    $resolvedId = [string]$resolvedQuestion
    if ([string]::IsNullOrWhiteSpace($resolvedId)) {
        throw "questionPolicy.resolvedQuestionIds contains an empty ID."
    }
    $resolvedId = $resolvedId.Trim()
    if (-not $resolvedQuestionIds.Add($resolvedId)) {
        throw "questionPolicy.resolvedQuestionIds contains duplicate ID '$resolvedId'."
    }
}

$openQuestionIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($question in $questions) {
    [void]$openQuestionIds.Add([string]$question.id)
    if ($resolvedQuestionIds.Contains([string]$question.id)) {
        throw "Question '$($question.id)' cannot be both open and resolved."
    }
}
foreach ($question in $questions) {
    foreach ($dependency in @($question.dependsOnQuestionIds)) {
        if (-not $openQuestionIds.Contains([string]$dependency) -and
            -not $resolvedQuestionIds.Contains([string]$dependency)) {
            throw "Question '$($question.id)' depends on unknown question '$dependency'."
        }
    }
}

$asOfText = Get-RequiredString -Object $request -Name "asOf" -Context "Phase-gate request"
$asOf = ConvertTo-UtcInstant -Value $asOfText -Context "asOf"

$invalidationEvents = [System.Collections.Generic.List[object]]::new()
$invalidationIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($event in @(
    Get-OptionalArray -Object $request -Name "invalidationEvents"
)) {
    if ($null -eq $event -or $event -is [string]) {
        throw "invalidationEvents entries must be JSON objects."
    }
    Assert-KnownProperties `
        -Object $event `
        -Names @("id", "reason", "recordedAt") `
        -Context "Invalidation event"
    $eventId = Get-RequiredString -Object $event -Name "id" -Context "Invalidation event"
    if (-not $invalidationIds.Add($eventId)) {
        throw "invalidationEvents contains duplicate ID '$eventId'."
    }
    $reason = Get-RequiredString `
        -Object $event `
        -Name "reason" `
        -Context "Invalidation event '$eventId'"
    $recordedAtText = Get-RequiredString `
        -Object $event `
        -Name "recordedAt" `
        -Context "Invalidation event '$eventId'"
    $recordedAt = ConvertTo-UtcInstant `
        -Value $recordedAtText `
        -Context "Invalidation event '$eventId' recordedAt"
    $invalidationEvents.Add([ordered]@{
        id = $eventId
        reason = $reason
        recordedAt = Format-UtcInstant -Value $recordedAt
    })
}
$normalizedInvalidations = [object[]]@(
    $invalidationEvents | Sort-Object @{ Expression = { [string]$_.id } }
)

$eligibleQuestions = [System.Collections.Generic.List[object]]::new()
$dependencyBlockedQuestions = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($question in $questions) {
    $unresolvedDependencies = @(
        $question.dependsOnQuestionIds |
            Where-Object { -not $resolvedQuestionIds.Contains([string]$_) }
    )
    if ($unresolvedDependencies.Count -eq 0) {
        $eligibleQuestions.Add($question)
    }
    else {
        [void]$dependencyBlockedQuestions.Add([string]$question.id)
    }
}

$askNow = [System.Collections.Generic.List[object]]::new()
foreach ($question in @($eligibleQuestions | Select-Object -First $maxQuestions)) {
    $askNow.Add($question)
}
$askNowIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
foreach ($question in $askNow) {
    [void]$askNowIds.Add([string]$question.id)
}

$deferred = [System.Collections.Generic.List[object]]::new()
foreach ($question in $questions) {
    if ($askNowIds.Contains([string]$question.id)) {
        continue
    }
    $reason = if ($dependencyBlockedQuestions.Contains([string]$question.id)) {
        "unresolved-dependency"
    }
    elseif (-not $explicitBatchRequested) {
        "single-question-default"
    }
    else {
        "batch-limit"
    }
    $deferred.Add([ordered]@{
        id = [string]$question.id
        rank = [int]$question.rank
        text = [string]$question.text
        dependsOnQuestionIds = [string[]]@($question.dependsOnQuestionIds)
        deferReason = $reason
    })
}

$evidenceFingerprint = Get-CanonicalFingerprint -Value $evidence
$questionsFingerprint = Get-CanonicalFingerprint -Value $questions
$gateFingerprint = Get-GateFingerprint `
    -GateId $gateId `
    -SourceFingerprint $sourceFingerprint `
    -ProfileFingerprint $profileFingerprint `
    -Evidence $evidence `
    -MaterialQuestions $questions

$priorApproval = if (
    (Test-ObjectProperty -Object $request -Name "priorApproval") -and
    $null -ne $request.priorApproval
) {
    $request.priorApproval
}
else {
    $null
}

$decision = "pending"
$recordedStatus = "none"
$approvalId = $null
$expiresAtOutput = $null
$attestationStatus = "not-applicable"
$attestationKeyId = $null
$reasons = [System.Collections.Generic.List[string]]::new()
$reuseStatus = "fresh-approval-required"
$reusable = $false

if ($null -eq $priorApproval) {
    $reasons.Add("no-prior-approval")
    if ($questions.Count -gt 0) {
        $reuseStatus = "questions-required"
        $reasons.Add("unresolved-material-questions")
    }
}
else {
    if ($priorApproval -is [string]) {
        throw "priorApproval must be a JSON object or null."
    }
    Assert-KnownProperties `
        -Object $priorApproval `
        -Names @(
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
            "invalidationReasons",
            "attestation"
        ) `
        -Context "priorApproval"

    $approvalId = Get-RequiredString `
        -Object $priorApproval `
        -Name "approvalId" `
        -Context "priorApproval"
    $priorGateId = Get-RequiredString `
        -Object $priorApproval `
        -Name "gateId" `
        -Context "priorApproval"
    $priorGateFingerprint = Get-RequiredString `
        -Object $priorApproval `
        -Name "gateFingerprint" `
        -Context "priorApproval"
    $priorSourceFingerprint = Get-RequiredString `
        -Object $priorApproval `
        -Name "sourceFingerprint" `
        -Context "priorApproval"
    $priorProfileFingerprint = Get-RequiredString `
        -Object $priorApproval `
        -Name "profileFingerprint" `
        -Context "priorApproval"
    Assert-Fingerprint -Value $priorGateFingerprint -Context "priorApproval.gateFingerprint"
    Assert-Fingerprint -Value $priorSourceFingerprint -Context "priorApproval.sourceFingerprint"
    Assert-Fingerprint -Value $priorProfileFingerprint -Context "priorApproval.profileFingerprint"

    $priorEvidence = @(
        ConvertTo-NormalizedEvidence `
            -Items @(Get-OptionalArray -Object $priorApproval -Name "evidence") `
            -Context "priorApproval evidence"
    )
    $priorQuestions = @(
        ConvertTo-NormalizedQuestions `
            -Items @(Get-OptionalArray -Object $priorApproval -Name "materialQuestions") `
            -Context "priorApproval materialQuestions"
    )
    $computedPriorGateFingerprint = Get-GateFingerprint `
        -GateId $priorGateId `
        -SourceFingerprint $priorSourceFingerprint `
        -ProfileFingerprint $priorProfileFingerprint `
        -Evidence $priorEvidence `
        -MaterialQuestions $priorQuestions

    $decision = Get-RequiredString `
        -Object $priorApproval `
        -Name "decision" `
        -Context "priorApproval"
    if ($decision -cnotin @("approved", "rejected", "deferred")) {
        throw "priorApproval.decision must be approved, rejected, or deferred."
    }
    $recordedStatus = Get-RequiredString `
        -Object $priorApproval `
        -Name "status" `
        -Context "priorApproval"
    if ($recordedStatus -cnotin @("active", "revoked", "superseded", "invalidated")) {
        throw "priorApproval.status must be active, revoked, superseded, or invalidated."
    }
    [void](Get-RequiredString `
        -Object $priorApproval `
        -Name "decidedBy" `
        -Context "priorApproval")
    $decidedAtText = Get-RequiredString `
        -Object $priorApproval `
        -Name "decidedAt" `
        -Context "priorApproval"
    $decidedAt = ConvertTo-UtcInstant `
        -Value $decidedAtText `
        -Context "priorApproval.decidedAt"

    $expiresAt = $null
    if ((Test-ObjectProperty -Object $priorApproval -Name "expiresAt") -and
        $null -ne $priorApproval.expiresAt) {
        $expiresAtText = [string]$priorApproval.expiresAt
        if ([string]::IsNullOrWhiteSpace($expiresAtText)) {
            throw "priorApproval.expiresAt must be null or an ISO-8601 timestamp."
        }
        $expiresAt = ConvertTo-UtcInstant `
            -Value $expiresAtText `
            -Context "priorApproval.expiresAt"
        if ($expiresAt -le $decidedAt) {
            throw "priorApproval.expiresAt must be later than decidedAt."
        }
        $expiresAtOutput = Format-UtcInstant -Value $expiresAt
    }

    $invalidatedAt = $null
    if ((Test-ObjectProperty -Object $priorApproval -Name "invalidatedAt") -and
        $null -ne $priorApproval.invalidatedAt) {
        $invalidatedAtText = [string]$priorApproval.invalidatedAt
        if ([string]::IsNullOrWhiteSpace($invalidatedAtText)) {
            throw "priorApproval.invalidatedAt must be null or an ISO-8601 timestamp."
        }
        $invalidatedAt = ConvertTo-UtcInstant `
            -Value $invalidatedAtText `
            -Context "priorApproval.invalidatedAt"
    }

    $invalidationReasons = [System.Collections.Generic.List[string]]::new()
    foreach ($reasonValue in @(
        Get-OptionalArray -Object $priorApproval -Name "invalidationReasons"
    )) {
        $reasonText = [string]$reasonValue
        if ([string]::IsNullOrWhiteSpace($reasonText)) {
            throw "priorApproval.invalidationReasons contains an empty value."
        }
        $invalidationReasons.Add($reasonText.Trim())
    }

    $attestationResult = Test-PhaseGateApprovalAttestation `
        -Approval $priorApproval
    $attestationStatus = [string]$attestationResult.status
    $attestationKeyId = $attestationResult.keyId
    if (-not [bool]$attestationResult.valid) {
        $reasons.Add([string]$attestationResult.reason)
    }

    if ($decision -ceq "approved" -and $priorQuestions.Count -gt 0) {
        throw "An approved priorApproval cannot contain unresolved material questions."
    }
    if ($decidedAt -gt $asOf) {
        $reasons.Add("decision-after-as-of")
    }
    if ($recordedStatus -cne "active") {
        $reasons.Add("prior-status-$recordedStatus")
    }
    if ($null -ne $invalidatedAt -or $invalidationReasons.Count -gt 0) {
        $reasons.Add("prior-approval-invalidated")
    }
    if ($normalizedInvalidations.Count -gt 0) {
        $reasons.Add("current-invalidation-event")
    }
    if ($priorGateFingerprint -cne $computedPriorGateFingerprint) {
        $reasons.Add("prior-gate-fingerprint-invalid")
    }
    if ($priorGateId -cne $gateId) {
        $reasons.Add("gate-id-changed")
    }
    if ($priorSourceFingerprint -cne $sourceFingerprint) {
        $reasons.Add("source-fingerprint-changed")
    }
    if ($priorProfileFingerprint -cne $profileFingerprint) {
        $reasons.Add("profile-fingerprint-changed")
    }
    if ((Get-CanonicalFingerprint -Value $priorEvidence) -cne $evidenceFingerprint) {
        $reasons.Add("evidence-fingerprint-changed")
    }
    if ($priorGateFingerprint -cne $gateFingerprint) {
        $reasons.Add("gate-fingerprint-changed")
    }
    if ($null -ne $expiresAt -and $asOf -ge $expiresAt) {
        $reasons.Add("approval-expired")
    }
    if ($decision -cne "approved") {
        $reasons.Add("decision-not-approved")
    }
    if ($questions.Count -gt 0) {
        $reasons.Add("unresolved-material-questions")
    }

    $reasonValues = @($reasons)
    if ($reasonValues -contains "approval-attestation-missing" -or
        $reasonValues -contains "approval-attestation-invalid" -or
        $reasonValues -contains "approval-attestation-key-missing" -or
        $reasonValues -contains "approval-attestation-key-invalid" -or
        $reasonValues -contains "approval-attestation-key-unknown") {
        $reuseStatus = "invalid-attestation"
    }
    elseif ($reasonValues -contains "prior-approval-invalidated" -or
        $reasonValues -contains "current-invalidation-event" -or
        $recordedStatus -cin @("revoked", "superseded", "invalidated")) {
        $reuseStatus = "invalidated"
    }
    elseif ($reasonValues -contains "prior-gate-fingerprint-invalid" -or
        $reasonValues -contains "gate-id-changed" -or
        $reasonValues -contains "source-fingerprint-changed" -or
        $reasonValues -contains "profile-fingerprint-changed" -or
        $reasonValues -contains "evidence-fingerprint-changed" -or
        $reasonValues -contains "gate-fingerprint-changed") {
        $reuseStatus = "stale"
    }
    elseif ($reasonValues -contains "decision-after-as-of") {
        $reuseStatus = "invalid-record"
    }
    elseif ($reasonValues -contains "approval-expired") {
        $reuseStatus = "expired"
    }
    elseif ($reasonValues -contains "decision-not-approved") {
        $reuseStatus = "not-approved"
    }
    elseif ($reasonValues -contains "unresolved-material-questions") {
        $reuseStatus = "questions-required"
    }
    else {
        $reuseStatus = "reused"
        $reusable = $true
    }
}

$questionMode = if ($explicitBatchRequested) {
    "explicit-independent-batch"
}
else {
    "single"
}

$result = [ordered]@{
    schemaVersion = "1.0"
    gate = [ordered]@{
        gateId = $gateId
        sourceFingerprint = $sourceFingerprint
        profileFingerprint = $profileFingerprint
        evidence = $evidence
        materialQuestions = $questions
        fingerprints = [ordered]@{
            algorithm = "SHA-256"
            evidence = $evidenceFingerprint
            materialQuestions = $questionsFingerprint
            gate = $gateFingerprint
        }
    }
    approval = [ordered]@{
        approvalId = $approvalId
        decision = $decision
        recordedStatus = $recordedStatus
        attestationStatus = $attestationStatus
        attestationKeyId = $attestationKeyId
        reuseStatus = $reuseStatus
        reusable = $reusable
        asOf = Format-UtcInstant -Value $asOf
        expiresAt = $expiresAtOutput
        invalidationEvents = $normalizedInvalidations
        reasons = [string[]]@($reasons)
    }
    questionPlan = [ordered]@{
        mode = $questionMode
        maxQuestions = $maxQuestions
        askNow = [object[]]@($askNow)
        deferred = [object[]]@($deferred)
    }
}

Write-Output (($result | ConvertTo-Json -Depth 100) -replace "`r`n", "`n")
