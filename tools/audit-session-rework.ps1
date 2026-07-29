[CmdletBinding(DefaultParameterSetName = "Paths")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "Paths", Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string[]]$SessionPath,

    [Parameter(Mandatory = $true, ParameterSetName = "Manifest")]
    [ValidateNotNullOrEmpty()]
    [string]$ManifestPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Utf8NoBomStrict = [System.Text.UTF8Encoding]::new($false, $true)
$AllowedSessionKinds = @("root", "fork", "subagent")
$AllowedStages = @(
    "request",
    "first_output",
    "correction",
    "revised_output",
    "accepted_output",
    "acceptance",
    "manual_edit"
)
$AllowedClassifications = @("first_pass_defect", "user_scope_change")
$AllowedCauses = @(
    "format_or_structure",
    "incomplete_coverage",
    "incorrect_assumption",
    "incorrect_behavior",
    "invalid_diagram",
    "missed_context",
    "missed_explicit_requirement",
    "other",
    "privacy_or_security",
    "repeat_after_fix",
    "tool_or_execution_error",
    "traceability_gap",
    "unsupported_content"
)
$AllowedMissedContextKinds = @(
    "linked_source",
    "memory",
    "policy",
    "request",
    "workspace"
)
$script:RedactionRules = New-Object System.Collections.Generic.List[object]
$script:FailureSourceId = ""
$script:FailureLine = 0

function Stop-Audit {
    param(
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$SourceId = $script:FailureSourceId,
        [int]$Line = $script:FailureLine
    )

    $exception = [System.IO.InvalidDataException]::new($Message)
    $exception.Data["AuditCode"] = $Code
    $exception.Data["SourceId"] = $SourceId
    $exception.Data["Line"] = $Line
    throw $exception
}

function Test-ObjectProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name]
}

function Get-ObjectProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        return $null
    }
    $value = $Object.PSObject.Properties[$Name].Value
    if ($value -is [System.Array]) {
        Write-Output -NoEnumerate $value
        return
    }
    return $value
}

function Test-JsonObject {
    param([AllowNull()]$Value)
    return $null -ne $Value -and $Value -is [pscustomobject]
}

function Test-JsonArray {
    param([AllowNull()]$Value)
    return $null -ne $Value -and $Value -is [System.Array]
}

function Assert-AllowedProperties {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Allowed,
        [Parameter(Mandatory = $true)][string]$Code
    )

    if (-not (Test-JsonObject -Value $Object)) {
        Stop-Audit -Code $Code -Message "A declared evidence record must be a JSON object."
    }
    foreach ($property in $Object.PSObject.Properties) {
        if ($Allowed -cnotcontains [string]$property.Name) {
            Stop-Audit -Code $Code -Message "A declared evidence record contains an unsupported field."
        }
    }
}

function Get-RequiredText {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Code
    )

    $value = Get-ObjectProperty -Object $Object -Name $Name
    if ($value -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$value) -or
        [string]$value -cne ([string]$value).Trim()) {
        Stop-Audit -Code $Code -Message "A required text declaration is missing or non-canonical."
    }
    return [string]$value
}

function Get-OptionalText {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Code
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        return $null
    }
    $value = Get-ObjectProperty -Object $Object -Name $Name
    if ($value -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$value) -or
        [string]$value -cne ([string]$value).Trim()) {
        Stop-Audit -Code $Code -Message "An optional text declaration is empty or non-canonical."
    }
    return [string]$value
}

function Test-SafeId {
    param([AllowNull()]$Value)

    return $Value -is [string] -and
        [string]$Value -cmatch "^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$"
}

function Test-SafeVersionToken {
    param([AllowNull()]$Value)

    return $Value -is [string] -and
        [string]$Value -cmatch "^[A-Za-z0-9][A-Za-z0-9._:+@-]{0,127}$"
}

function Test-SafeSourceLink {
    param([AllowNull()]$Value)

    if ($Value -isnot [string] -or
        [string]$Value -cnotmatch "^[A-Za-z0-9][A-Za-z0-9._/-]{0,255}(?:#L[1-9][0-9]*)?$") {
        return $false
    }
    $pathPart = ([string]$Value -split "#", 2)[0]
    return -not $pathPart.Contains("..") -and
        -not $pathPart.Contains("//") -and
        -not $pathPart.EndsWith("/")
}

function Sort-SourceLinks {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$Links
    )

    return @(
        $Links |
            Sort-Object `
                @{ Expression = { ([string]$_ -split "#L", 2)[0] } },
                @{ Expression = {
                    if ([string]$_ -cmatch "#L([1-9][0-9]*)$") {
                        [long]$Matches[1]
                    }
                    else {
                        [long]0
                    }
                } },
                @{ Expression = { [string]$_ } } `
                -Unique
    )
}

function Test-JsonNumber {
    param([AllowNull()]$Value)

    return $Value -is [byte] -or
        $Value -is [sbyte] -or
        $Value -is [int16] -or
        $Value -is [uint16] -or
        $Value -is [int32] -or
        $Value -is [uint32] -or
        $Value -is [int64] -or
        $Value -is [uint64] -or
        $Value -is [single] -or
        $Value -is [double] -or
        $Value -is [decimal]
}

function ConvertTo-CanonicalJson {
    param([AllowNull()]$Value)

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
    if (Test-JsonNumber -Value $Value) {
        return [System.Convert]::ToString(
            $Value,
            [System.Globalization.CultureInfo]::InvariantCulture
        )
    }
    if ($Value -is [System.Collections.IDictionary]) {
        $parts = foreach ($key in @($Value.Keys | ForEach-Object { [string]$_ } | Sort-Object -CaseSensitive)) {
            $encodedKey = ([string]$key | ConvertTo-Json -Compress)
            "$encodedKey`:$((ConvertTo-CanonicalJson -Value $Value[$key]))"
        }
        return "{$($parts -join ',')}"
    }
    if (Test-JsonObject -Value $Value) {
        $parts = foreach ($property in @($Value.PSObject.Properties | Sort-Object Name -CaseSensitive)) {
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

function Read-Utf8Text {
    param(
        [Parameter(Mandatory = $true)][string]$FullPath,
        [Parameter(Mandatory = $true)][string]$Code
    )

    try {
        $bytes = [System.IO.File]::ReadAllBytes($FullPath)
        $text = $Utf8NoBomStrict.GetString($bytes)
        if ($text.Length -gt 0 -and [int][char]$text[0] -eq 0xFEFF) {
            return $text.Substring(1)
        }
        return $text
    }
    catch [System.Text.DecoderFallbackException] {
        Stop-Audit -Code $Code -Message "Evidence must be valid UTF-8."
    }
}

function Resolve-ExplicitFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$ExpectedExtension,
        [Parameter(Mandatory = $true)][string]$Code
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or
        $Path -cne $Path.Trim() -or
        [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Path)) {
        Stop-Audit -Code $Code -Message "Evidence paths must be explicit, non-empty file paths without wildcards."
    }
    if (-not [System.IO.Path]::GetExtension($Path).Equals(
        $ExpectedExtension,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        Stop-Audit -Code $Code -Message "An evidence path has an unsupported file extension."
    }
    try {
        $candidate = if ([System.IO.Path]::IsPathRooted($Path)) {
            [System.IO.Path]::GetFullPath($Path)
        }
        else {
            [System.IO.Path]::GetFullPath((Join-Path $BasePath $Path))
        }
    }
    catch {
        Stop-Audit -Code $Code -Message "An evidence path is not a valid explicit file path."
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        Stop-Audit -Code $Code -Message "An explicitly declared evidence file does not exist."
    }
    $item = Get-Item -Force -LiteralPath $candidate
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        Stop-Audit -Code $Code -Message "Reparse-point and symbolic-link evidence files are not accepted."
    }
    return $candidate
}

function ConvertTo-NormalizedMessageText {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    return $Text.Replace("`r`n", "`n").Replace("`r", "`n").Normalize(
        [System.Text.NormalizationForm]::FormC
    ).Trim()
}

function Get-TextFromMessageContent {
    param([AllowNull()]$Content)

    if ($Content -is [string]) {
        return ConvertTo-NormalizedMessageText -Text ([string]$Content)
    }
    if (-not (Test-JsonArray -Value $Content)) {
        return $null
    }
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($part in $Content) {
        if ($part -is [string]) {
            $parts.Add([string]$part)
            continue
        }
        if (-not (Test-JsonObject -Value $part)) {
            continue
        }
        foreach ($field in @("text", "content", "message")) {
            $value = Get-ObjectProperty -Object $part -Name $field
            if ($value -is [string]) {
                $parts.Add([string]$value)
                break
            }
        }
    }
    if ($parts.Count -eq 0) {
        return $null
    }
    return ConvertTo-NormalizedMessageText -Text ($parts -join "`n")
}

function Get-InlineObservation {
    param(
        [Parameter(Mandatory = $true)]$Event,
        [AllowNull()]$Payload
    )

    $declarations = New-Object System.Collections.Generic.List[object]
    foreach ($container in @($Event, $Payload)) {
        if ($null -eq $container -or -not (Test-JsonObject -Value $container)) {
            continue
        }
        foreach ($name in @("observation", "annifityObservation")) {
            if (Test-ObjectProperty -Object $container -Name $name) {
                $value = Get-ObjectProperty -Object $container -Name $name
                if (-not (Test-JsonObject -Value $value)) {
                    Stop-Audit -Code "OBSERVATION_TYPE_INVALID" -Message "An inline observation must be a JSON object."
                }
                $declarations.Add($value)
            }
        }
    }
    if ($declarations.Count -eq 0) {
        return $null
    }
    $canonical = ConvertTo-CanonicalJson -Value $declarations[0]
    foreach ($declaration in $declarations) {
        if ((ConvertTo-CanonicalJson -Value $declaration) -cne $canonical) {
            Stop-Audit -Code "OBSERVATION_CONFLICT" -Message "A message contains conflicting inline observation declarations."
        }
    }
    return $declarations[0]
}

function Get-MessageCandidate {
    param(
        [Parameter(Mandatory = $true)]$Event,
        [Parameter(Mandatory = $true)][int]$Line
    )

    $eventType = Get-ObjectProperty -Object $Event -Name "type"
    if ($eventType -isnot [string]) {
        return $null
    }
    $eventType = ([string]$eventType).ToLowerInvariant()
    $payloadValue = Get-ObjectProperty -Object $Event -Name "payload"
    $payload = if (Test-JsonObject -Value $payloadValue) { $payloadValue } else { $Event }
    $message = $null
    $inferredRole = $null

    if ($eventType -eq "message") {
        $message = $payload
    }
    elseif ($eventType -eq "response_item") {
        $payloadType = Get-ObjectProperty -Object $payload -Name "type"
        if ($payloadType -is [string] -and
            ([string]$payloadType).ToLowerInvariant() -eq "message") {
            $message = $payload
        }
    }
    elseif ($eventType -eq "event_msg") {
        $payloadType = Get-ObjectProperty -Object $payload -Name "type"
        if ($payloadType -is [string]) {
            switch (([string]$payloadType).ToLowerInvariant()) {
                "agent_message" {
                    $message = $payload
                    $inferredRole = "assistant"
                }
                "user_message" {
                    $message = $payload
                    $inferredRole = "user"
                }
                "message" {
                    $message = $payload
                }
            }
        }
    }
    if ($null -eq $message) {
        return $null
    }

    $roleValue = Get-ObjectProperty -Object $message -Name "role"
    $role = if ($roleValue -is [string]) {
        ([string]$roleValue).ToLowerInvariant()
    }
    else {
        $inferredRole
    }

    $contentValue = $null
    foreach ($field in @("content", "message", "text")) {
        if (Test-ObjectProperty -Object $message -Name $field) {
            $contentValue = Get-ObjectProperty -Object $message -Name $field
            break
        }
    }
    $content = Get-TextFromMessageContent -Content $contentValue
    $messageId = $null
    foreach ($field in @("messageId", "message_id", "id")) {
        $value = Get-ObjectProperty -Object $message -Name $field
        if ($value -is [string] -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
            $messageId = [string]$value
            break
        }
    }
    if ($null -ne $messageId -and
        ($messageId.Length -gt 256 -or $messageId -match "\s")) {
        Stop-Audit -Code "MESSAGE_ID_INVALID" -Message "A message ID is not a safe stable token."
    }

    $observation = Get-InlineObservation -Event $Event -Payload $message
    return [pscustomobject]@{
        line = $Line
        role = $role
        content = $content
        messageId = $messageId
        observation = $observation
    }
}

function Get-SessionMetadata {
    param([Parameter(Mandatory = $true)][object[]]$Records)

    $metadataRecords = @(
        $Records |
            Where-Object {
                $type = Get-ObjectProperty -Object $_.event -Name "type"
                $type -is [string] -and
                    ([string]$type).ToLowerInvariant() -eq "session_meta"
            }
    )
    if ($metadataRecords.Count -gt 1) {
        Stop-Audit -Code "DUPLICATE_SESSION_METADATA" -Message "A JSONL session contains more than one session metadata record."
    }
    if ($metadataRecords.Count -eq 0) {
        return [pscustomobject]@{
            line = 0
            sessionId = $null
            sessionKind = $null
            skill = $null
            privacy = $null
        }
    }

    $record = $metadataRecords[0]
    $event = $record.event
    $payloadValue = Get-ObjectProperty -Object $event -Name "payload"
    $metadata = if (Test-JsonObject -Value $payloadValue) { $payloadValue } else { $event }
    $schemaVersion = Get-ObjectProperty -Object $metadata -Name "schemaVersion"
    if ($null -ne $schemaVersion -and [string]$schemaVersion -cne "1.0") {
        Stop-Audit -Code "SESSION_SCHEMA_UNSUPPORTED" -Message "Session metadata declares an unsupported schema version." -Line $record.line
    }

    $sessionId = $null
    foreach ($field in @("sessionId", "session_id", "id")) {
        $value = Get-ObjectProperty -Object $metadata -Name $field
        if ($value -is [string] -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
            $sessionId = [string]$value
            break
        }
    }
    $sessionKind = $null
    foreach ($field in @("sessionKind", "session_kind")) {
        $value = Get-ObjectProperty -Object $metadata -Name $field
        if ($value -is [string] -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
            $sessionKind = ([string]$value).ToLowerInvariant()
            break
        }
    }

    return [pscustomobject]@{
        line = [int]$record.line
        sessionId = $sessionId
        sessionKind = $sessionKind
        skill = Get-ObjectProperty -Object $metadata -Name "skill"
        privacy = Get-ObjectProperty -Object $metadata -Name "privacy"
    }
}

function Read-JsonLines {
    param([Parameter(Mandatory = $true)][string]$FullPath)

    $text = Read-Utf8Text -FullPath $FullPath -Code "SESSION_INVALID_UTF8"
    if ($text.Length -eq 0) {
        Stop-Audit -Code "SESSION_EMPTY" -Message "An explicitly selected JSONL session is empty."
    }
    $normalized = $text.Replace("`r`n", "`n").Replace("`r", "`n")
    $lines = $normalized -split "`n", -1
    if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq "") {
        $lines = @($lines[0..($lines.Count - 2)])
    }
    if ($lines.Count -eq 0) {
        Stop-Audit -Code "SESSION_EMPTY" -Message "An explicitly selected JSONL session is empty."
    }

    $records = New-Object System.Collections.Generic.List[object]
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $lineNumber = $index + 1
        $script:FailureLine = $lineNumber
        if ([string]::IsNullOrWhiteSpace([string]$lines[$index])) {
            Stop-Audit -Code "JSONL_BLANK_LINE" -Message "JSONL evidence must not contain blank lines."
        }
        try {
            $event = [string]$lines[$index] | ConvertFrom-Json
        }
        catch {
            Stop-Audit -Code "JSONL_INVALID_JSON" -Message "A JSONL evidence line is not valid JSON."
        }
        if (-not (Test-JsonObject -Value $event)) {
            Stop-Audit -Code "JSONL_EVENT_TYPE_INVALID" -Message "Every JSONL evidence line must contain one JSON object."
        }
        $eventType = Get-ObjectProperty -Object $event -Name "type"
        if ($eventType -isnot [string] -or
            [string]::IsNullOrWhiteSpace([string]$eventType)) {
            Stop-Audit -Code "JSONL_EVENT_TYPE_INVALID" -Message "Every JSONL evidence object must declare a non-empty event type."
        }
        $records.Add([pscustomobject]@{
            line = $lineNumber
            event = $event
        })
    }
    return $records.ToArray()
}

function Validate-Skill {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Code
    )

    if (-not (Test-JsonObject -Value $Value)) {
        Stop-Audit -Code $Code -Message "Included evidence must declare a skill object."
    }
    Assert-AllowedProperties -Object $Value -Allowed @("name", "version") -Code $Code
    $name = Get-RequiredText -Object $Value -Name "name" -Code $Code
    $version = Get-RequiredText -Object $Value -Name "version" -Code $Code
    if (-not (Test-SafeId -Value $name) -or
        -not (Test-SafeVersionToken -Value $version)) {
        Stop-Audit -Code $Code -Message "Skill name or version is not a safe stable identifier."
    }
    return [pscustomobject][ordered]@{
        name = $name
        version = $version
    }
}

function Validate-Privacy {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Code
    )

    if (-not (Test-JsonObject -Value $Value)) {
        Stop-Audit -Code $Code -Message "Included evidence must declare a privacy object."
    }
    Assert-AllowedProperties -Object $Value -Allowed @("classification", "redaction") -Code $Code
    $classification = (Get-RequiredText -Object $Value -Name "classification" -Code $Code).ToLowerInvariant()
    $redaction = (Get-RequiredText -Object $Value -Name "redaction" -Code $Code).ToLowerInvariant()
    if ($classification -notin @("synthetic", "anonymized", "private") -or
        $redaction -cne "required") {
        Stop-Audit -Code $Code -Message "Privacy must use a supported classification and required redaction."
    }
    return [pscustomobject][ordered]@{
        classification = $classification
        redaction = "required"
    }
}

function Resolve-TextDeclaration {
    param(
        [AllowNull()]$MetadataValue,
        [AllowNull()]$ManifestValue,
        [Parameter(Mandatory = $true)][string]$Code,
        [switch]$Lowercase
    )

    $metadataText = if ($MetadataValue -is [string] -and
        -not [string]::IsNullOrWhiteSpace([string]$MetadataValue)) {
        ([string]$MetadataValue).Trim()
    }
    else {
        $null
    }
    $manifestText = if ($ManifestValue -is [string] -and
        -not [string]::IsNullOrWhiteSpace([string]$ManifestValue)) {
        ([string]$ManifestValue).Trim()
    }
    else {
        $null
    }
    if ($Lowercase) {
        if ($null -ne $metadataText) { $metadataText = $metadataText.ToLowerInvariant() }
        if ($null -ne $manifestText) { $manifestText = $manifestText.ToLowerInvariant() }
    }
    if ($null -ne $metadataText -and
        $null -ne $manifestText -and
        $metadataText -cne $manifestText) {
        Stop-Audit -Code $Code -Message "Manifest and JSONL metadata declarations conflict."
    }
    if ($null -ne $metadataText) { return $metadataText }
    return $manifestText
}

function Resolve-ObjectDeclaration {
    param(
        [AllowNull()]$MetadataValue,
        [AllowNull()]$ManifestValue,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][ValidateSet("skill", "privacy")][string]$Kind
    )

    $metadataObject = if ($null -ne $MetadataValue) {
        if ($Kind -eq "skill") {
            Validate-Skill -Value $MetadataValue -Code $Code
        }
        else {
            Validate-Privacy -Value $MetadataValue -Code $Code
        }
    }
    else {
        $null
    }
    $manifestObject = if ($null -ne $ManifestValue) {
        if ($Kind -eq "skill") {
            Validate-Skill -Value $ManifestValue -Code $Code
        }
        else {
            Validate-Privacy -Value $ManifestValue -Code $Code
        }
    }
    else {
        $null
    }
    if ($null -ne $metadataObject -and
        $null -ne $manifestObject -and
        (ConvertTo-CanonicalJson -Value $metadataObject) -cne
            (ConvertTo-CanonicalJson -Value $manifestObject)) {
        Stop-Audit -Code $Code -Message "Manifest and JSONL metadata declarations conflict."
    }
    if ($null -ne $metadataObject) { return $metadataObject }
    return $manifestObject
}

function Copy-ManifestObservation {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Code
    )

    Assert-AllowedProperties `
        -Object $Value `
        -Allowed @(
            "line",
            "chainId",
            "stage",
            "classification",
            "causes",
            "missedContext",
            "confidence",
            "sourceLinks",
            "skill"
        ) `
        -Code $Code
    $lineValue = Get-ObjectProperty -Object $Value -Name "line"
    if (-not (Test-JsonNumber -Value $lineValue) -or
        [double]$lineValue -ne [math]::Floor([double]$lineValue) -or
        [double]$lineValue -lt 1 -or
        [double]$lineValue -gt [int]::MaxValue) {
        Stop-Audit -Code $Code -Message "A manifest observation must declare a positive integer line."
    }
    $copy = [ordered]@{}
    foreach ($name in @(
        "chainId",
        "stage",
        "classification",
        "causes",
        "missedContext",
        "confidence",
        "sourceLinks",
        "skill"
    )) {
        if (Test-ObjectProperty -Object $Value -Name $name) {
            $copy[$name] = Get-ObjectProperty -Object $Value -Name $name
        }
    }
    return [pscustomobject]@{
        line = [int]$lineValue
        observation = [pscustomobject]$copy
    }
}

function ConvertTo-StringArrayStrict {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Code,
        [switch]$Optional
    )

    if ($null -eq $Value -and $Optional) {
        return @()
    }
    if (-not (Test-JsonArray -Value $Value)) {
        Stop-Audit -Code $Code -Message "An observation list must be a JSON array."
    }
    $result = New-Object System.Collections.Generic.List[string]
    foreach ($item in $Value) {
        if ($item -isnot [string] -or
            [string]::IsNullOrWhiteSpace([string]$item) -or
            [string]$item -cne ([string]$item).Trim()) {
            Stop-Audit -Code $Code -Message "An observation list contains an invalid text value."
        }
        $result.Add([string]$item)
    }
    return $result.ToArray()
}

function Validate-Observation {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [AllowNull()][string]$Role
    )

    Assert-AllowedProperties `
        -Object $Value `
        -Allowed @(
            "chainId",
            "stage",
            "classification",
            "causes",
            "missedContext",
            "confidence",
            "sourceLinks",
            "skill"
        ) `
        -Code "OBSERVATION_FIELD_INVALID"

    $chainId = Get-RequiredText -Object $Value -Name "chainId" -Code "OBSERVATION_CHAIN_ID_MISSING"
    if (-not (Test-SafeId -Value $chainId)) {
        Stop-Audit -Code "OBSERVATION_CHAIN_ID_INVALID" -Message "An observation chain ID is not a safe stable identifier."
    }
    $stage = (Get-RequiredText -Object $Value -Name "stage" -Code "OBSERVATION_STAGE_MISSING").ToLowerInvariant()
    if ($AllowedStages -cnotcontains $stage) {
        Stop-Audit -Code "OBSERVATION_STAGE_INVALID" -Message "An observation declares an unsupported stage."
    }
    $expectedRole = if ($stage -in @("first_output", "revised_output", "accepted_output")) {
        "assistant"
    }
    else {
        "user"
    }
    if ($Role -cne $expectedRole) {
        Stop-Audit -Code "OBSERVATION_ROLE_INVALID" -Message "An observed message role does not match its stage."
    }

    $isClassified = $stage -in @("correction", "manual_edit")
    $classificationValue = Get-ObjectProperty -Object $Value -Name "classification"
    $classification = $null
    if ($isClassified) {
        if ($classificationValue -isnot [string]) {
            Stop-Audit -Code "REWORK_CLASSIFICATION_MISSING" -Message "A correction or manual edit is missing its classification."
        }
        $classification = ([string]$classificationValue).ToLowerInvariant()
        if ($AllowedClassifications -cnotcontains $classification) {
            Stop-Audit -Code "REWORK_CLASSIFICATION_INVALID" -Message "A correction or manual edit has an unsupported classification."
        }
    }
    elseif ($null -ne $classificationValue) {
        Stop-Audit -Code "REWORK_CLASSIFICATION_UNEXPECTED" -Message "Only corrections and manual edits may declare a rework classification."
    }

    $causes = ConvertTo-StringArrayStrict `
        -Value (Get-ObjectProperty -Object $Value -Name "causes") `
        -Code "REWORK_CAUSES_INVALID" `
        -Optional
    $causeSet = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::Ordinal
    )
    foreach ($cause in $causes) {
        $normalizedCause = $cause.ToLowerInvariant()
        if ($AllowedCauses -cnotcontains $normalizedCause -or
            -not $causeSet.Add($normalizedCause)) {
            Stop-Audit -Code "REWORK_CAUSES_INVALID" -Message "Rework causes must be unique supported taxonomy codes."
        }
    }
    $causes = @($causeSet | Sort-Object -CaseSensitive)
    if ($classification -eq "first_pass_defect" -and $causes.Count -eq 0) {
        Stop-Audit -Code "DEFECT_CAUSE_MISSING" -Message "A first-pass defect must declare at least one cause."
    }
    if ($classification -eq "user_scope_change" -and $causes.Count -gt 0) {
        Stop-Audit -Code "SCOPE_CHANGE_CAUSE_CONFLICT" -Message "A user scope change must not be assigned a first-pass defect cause."
    }
    if (-not $isClassified -and $causes.Count -gt 0) {
        Stop-Audit -Code "REWORK_CAUSES_UNEXPECTED" -Message "Only corrections and manual edits may declare rework causes."
    }

    $missedContextValue = Get-ObjectProperty -Object $Value -Name "missedContext"
    $missedContext = New-Object System.Collections.Generic.List[object]
    if ($null -ne $missedContextValue) {
        if (-not (Test-JsonArray -Value $missedContextValue)) {
            Stop-Audit -Code "MISSED_CONTEXT_INVALID" -Message "Missed context must be a JSON array."
        }
        foreach ($item in $missedContextValue) {
            Assert-AllowedProperties `
                -Object $item `
                -Allowed @("kind", "description", "sourceLink") `
                -Code "MISSED_CONTEXT_INVALID"
            $kind = (Get-RequiredText -Object $item -Name "kind" -Code "MISSED_CONTEXT_INVALID").ToLowerInvariant()
            $description = Get-RequiredText -Object $item -Name "description" -Code "MISSED_CONTEXT_INVALID"
            if ($AllowedMissedContextKinds -cnotcontains $kind) {
                Stop-Audit -Code "MISSED_CONTEXT_INVALID" -Message "Missed context declares an unsupported kind."
            }
            $sourceLink = Get-OptionalText -Object $item -Name "sourceLink" -Code "MISSED_CONTEXT_INVALID"
            if ($null -ne $sourceLink -and -not (Test-SafeSourceLink -Value $sourceLink)) {
                Stop-Audit -Code "SOURCE_LINK_INVALID" -Message "A missed-context source link is not a safe bounded locator."
            }
            $missedContext.Add([pscustomobject][ordered]@{
                kind = $kind
                description = $description
                sourceLink = $sourceLink
            })
        }
    }
    if ($missedContext.Count -gt 0 -and $causes -cnotcontains "missed_context") {
        Stop-Audit -Code "MISSED_CONTEXT_CAUSE_CONFLICT" -Message "Missed-context evidence requires the missed_context cause."
    }
    if ($causes -ccontains "missed_context" -and $missedContext.Count -eq 0) {
        Stop-Audit -Code "MISSED_CONTEXT_EVIDENCE_MISSING" -Message "The missed_context cause requires at least one evidence record."
    }
    if (-not $isClassified -and $missedContext.Count -gt 0) {
        Stop-Audit -Code "MISSED_CONTEXT_UNEXPECTED" -Message "Only corrections and manual edits may declare missed context."
    }

    $confidenceValue = Get-ObjectProperty -Object $Value -Name "confidence"
    $confidence = $null
    if ($isClassified) {
        if (-not (Test-JsonNumber -Value $confidenceValue)) {
            Stop-Audit -Code "CLASSIFICATION_CONFIDENCE_MISSING" -Message "A classified event must declare numeric confidence."
        }
        $confidence = [double]$confidenceValue
        if ([double]::IsNaN($confidence) -or
            [double]::IsInfinity($confidence) -or
            $confidence -lt 0 -or
            $confidence -gt 1) {
            Stop-Audit -Code "CLASSIFICATION_CONFIDENCE_INVALID" -Message "Classification confidence must be between zero and one."
        }
    }
    elseif ($null -ne $confidenceValue) {
        Stop-Audit -Code "CLASSIFICATION_CONFIDENCE_UNEXPECTED" -Message "Only classified events may declare classification confidence."
    }

    $sourceLinks = ConvertTo-StringArrayStrict `
        -Value (Get-ObjectProperty -Object $Value -Name "sourceLinks") `
        -Code "SOURCE_LINK_INVALID" `
        -Optional
    $sourceLinkSet = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::Ordinal
    )
    foreach ($sourceLink in $sourceLinks) {
        if (-not (Test-SafeSourceLink -Value $sourceLink) -or
            -not $sourceLinkSet.Add($sourceLink)) {
            Stop-Audit -Code "SOURCE_LINK_INVALID" -Message "Source links must be unique safe bounded locators."
        }
    }
    $sourceLinks = Sort-SourceLinks -Links @($sourceLinkSet)

    $skill = $null
    if (Test-ObjectProperty -Object $Value -Name "skill") {
        $skill = Validate-Skill `
            -Value (Get-ObjectProperty -Object $Value -Name "skill") `
            -Code "OBSERVATION_SKILL_INVALID"
    }

    return [pscustomobject][ordered]@{
        chainId = $chainId
        stage = $stage
        classification = $classification
        causes = @($causes)
        missedContext = $missedContext.ToArray()
        confidence = $confidence
        sourceLinks = @($sourceLinks)
        skill = $skill
    }
}

function Add-RedactionRule {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Replacement
    )

    try {
        $regex = [System.Text.RegularExpressions.Regex]::new(
            $Pattern,
            [System.Text.RegularExpressions.RegexOptions]::CultureInvariant,
            [TimeSpan]::FromSeconds(1)
        )
    }
    catch {
        Stop-Audit -Code "REDACTION_RULE_INVALID" -Message "A redaction rule contains an invalid regular expression."
    }
    $script:RedactionRules.Add([pscustomobject]@{
        id = $Id
        regex = $regex
        replacement = $Replacement
        matches = 0
    })
}

function Initialize-RedactionRules {
    param([AllowNull()]$ManifestRedaction)

    Add-RedactionRule `
        -Id "builtin-email" `
        -Pattern "(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b" `
        -Replacement "[REDACTED:EMAIL]"
    Add-RedactionRule `
        -Id "builtin-secret" `
        -Pattern "(?i)\b(?:sk-(?:proj-)?[A-Za-z0-9_-]{8,}|(?:api[_-]?key|token|password)\s*[:=]\s*['""]?[^\s'"",;]{4,})" `
        -Replacement "[REDACTED:SECRET]"
    Add-RedactionRule `
        -Id "builtin-unix-home" `
        -Pattern "(?i)/home/[^/\s]+" `
        -Replacement "[REDACTED:USER_HOME]"
    Add-RedactionRule `
        -Id "builtin-windows-home" `
        -Pattern "(?i)\b[A-Z]:\\Users\\[^\\\s]+" `
        -Replacement "[REDACTED:USER_HOME]"

    if ($null -eq $ManifestRedaction) {
        return
    }
    Assert-AllowedProperties `
        -Object $ManifestRedaction `
        -Allowed @("rules") `
        -Code "REDACTION_CONFIG_INVALID"
    $rulesValue = Get-ObjectProperty -Object $ManifestRedaction -Name "rules"
    if ($null -eq $rulesValue) {
        return
    }
    if (-not (Test-JsonArray -Value $rulesValue)) {
        Stop-Audit -Code "REDACTION_CONFIG_INVALID" -Message "Redaction rules must be a JSON array."
    }
    $customRules = New-Object System.Collections.Generic.List[object]
    $ids = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::Ordinal
    )
    foreach ($rule in $rulesValue) {
        Assert-AllowedProperties `
            -Object $rule `
            -Allowed @("id", "pattern", "replacement") `
            -Code "REDACTION_RULE_INVALID"
        $id = Get-RequiredText -Object $rule -Name "id" -Code "REDACTION_RULE_INVALID"
        $pattern = Get-RequiredText -Object $rule -Name "pattern" -Code "REDACTION_RULE_INVALID"
        $replacement = Get-RequiredText -Object $rule -Name "replacement" -Code "REDACTION_RULE_INVALID"
        if ($id -cnotmatch "^[a-z][a-z0-9-]{0,63}$" -or
            $id.StartsWith("builtin-") -or
            -not $ids.Add($id) -or
            $replacement -cnotmatch "^\[REDACTED:[A-Z0-9_-]+\]$") {
            Stop-Audit -Code "REDACTION_RULE_INVALID" -Message "A custom redaction rule has an invalid ID or replacement."
        }
        $customRules.Add([pscustomobject]@{
            id = $id
            pattern = $pattern
            replacement = $replacement
        })
    }
    foreach ($rule in @($customRules | Sort-Object id -CaseSensitive)) {
        Add-RedactionRule `
            -Id $rule.id `
            -Pattern $rule.pattern `
            -Replacement $rule.replacement
    }
}

function Protect-Text {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    $result = $Text
    foreach ($rule in $script:RedactionRules) {
        try {
            $matches = $rule.regex.Matches($result)
            if ($matches.Count -gt 0) {
                $rule.matches = [int]$rule.matches + $matches.Count
                $result = $rule.regex.Replace($result, [string]$rule.replacement)
            }
        }
        catch [System.Text.RegularExpressions.RegexMatchTimeoutException] {
            Stop-Audit -Code "REDACTION_TIMEOUT" -Message "A redaction rule exceeded its deterministic execution bound."
        }
    }
    return $result
}

function Get-AutomaticSourceLinks {
    param(
        [Parameter(Mandatory = $true)][string]$SourceId,
        [Parameter(Mandatory = $true)][int[]]$Lines
    )

    return @(
        $Lines |
            Sort-Object -Unique |
            ForEach-Object { "$SourceId#L$_" }
    )
}

function New-RenderedMessage {
    param(
        [Parameter(Mandatory = $true)]$Message,
        [Parameter(Mandatory = $true)]$Observation
    )

    $base = [ordered]@{
        content = [string]$Message.redactedContent
        sourceLinks = @(
            Get-AutomaticSourceLinks `
                -SourceId ([string]$Message.sourceId) `
                -Lines @($Message.lines)
        )
        contextLinks = @($Observation.sourceLinks)
    }
    if ($Observation.stage -in @("correction", "manual_edit")) {
        $base["classification"] = $Observation.classification
        $base["causes"] = @($Observation.causes)
        $base["missedContext"] = @($Observation.redactedMissedContext)
        $base["confidence"] = $Observation.confidence
    }
    return [pscustomobject]$base
}

function Get-Ratio {
    param(
        [Parameter(Mandatory = $true)][double]$Numerator,
        [Parameter(Mandatory = $true)][double]$Denominator
    )

    if ($Denominator -eq 0) { return [double]0 }
    return [math]::Round(
        ($Numerator / $Denominator),
        4,
        [System.MidpointRounding]::AwayFromZero
    )
}

try {
    $entries = New-Object System.Collections.Generic.List[object]
    $manifestRedaction = $null
    $manifestBase = (Get-Location).Path

    if ($PSCmdlet.ParameterSetName -eq "Manifest") {
        $script:FailureSourceId = "manifest"
        $script:FailureLine = 0
        $manifestFullPath = Resolve-ExplicitFile `
            -Path $ManifestPath `
            -BasePath (Get-Location).Path `
            -ExpectedExtension ".json" `
            -Code "MANIFEST_PATH_INVALID"
        $manifestBase = [System.IO.Path]::GetDirectoryName($manifestFullPath)
        $manifestText = Read-Utf8Text `
            -FullPath $manifestFullPath `
            -Code "MANIFEST_INVALID_UTF8"
        try {
            $manifest = $manifestText | ConvertFrom-Json
        }
        catch {
            Stop-Audit -Code "MANIFEST_INVALID_JSON" -Message "The session audit manifest is not valid JSON."
        }
        Assert-AllowedProperties `
            -Object $manifest `
            -Allowed @("schemaVersion", "sessions", "redaction") `
            -Code "MANIFEST_FIELD_INVALID"
        if ([string](Get-ObjectProperty -Object $manifest -Name "schemaVersion") -cne "1.0") {
            Stop-Audit -Code "MANIFEST_SCHEMA_UNSUPPORTED" -Message "The session audit manifest schemaVersion must be 1.0."
        }
        $sessionsValue = Get-ObjectProperty -Object $manifest -Name "sessions"
        if (-not (Test-JsonArray -Value $sessionsValue) -or $sessionsValue.Count -eq 0) {
            Stop-Audit -Code "MANIFEST_SESSIONS_INVALID" -Message "The session audit manifest must contain a non-empty sessions array."
        }
        $manifestRedaction = Get-ObjectProperty -Object $manifest -Name "redaction"

        foreach ($session in $sessionsValue) {
            Assert-AllowedProperties `
                -Object $session `
                -Allowed @(
                    "path",
                    "sourceId",
                    "include",
                    "exclusionReason",
                    "sessionId",
                    "sessionKind",
                    "skill",
                    "privacy",
                    "observations"
                ) `
                -Code "MANIFEST_SESSION_INVALID"
            $sourceId = Get-RequiredText `
                -Object $session `
                -Name "sourceId" `
                -Code "MANIFEST_SOURCE_ID_INVALID"
            if (-not (Test-SafeId -Value $sourceId)) {
                Stop-Audit -Code "MANIFEST_SOURCE_ID_INVALID" -Message "A manifest source ID is not a safe stable identifier." -SourceId "manifest"
            }
            $script:FailureSourceId = $sourceId
            $pathValue = Get-RequiredText `
                -Object $session `
                -Name "path" `
                -Code "MANIFEST_SESSION_PATH_INVALID"
            $fullPath = Resolve-ExplicitFile `
                -Path $pathValue `
                -BasePath $manifestBase `
                -ExpectedExtension ".jsonl" `
                -Code "MANIFEST_SESSION_PATH_INVALID"

            $include = $true
            if (Test-ObjectProperty -Object $session -Name "include") {
                $includeValue = Get-ObjectProperty -Object $session -Name "include"
                if ($includeValue -isnot [bool]) {
                    Stop-Audit -Code "MANIFEST_INCLUDE_INVALID" -Message "Manifest include must be a JSON boolean."
                }
                $include = [bool]$includeValue
            }
            $exclusionReason = Get-OptionalText `
                -Object $session `
                -Name "exclusionReason" `
                -Code "MANIFEST_EXCLUSION_INVALID"
            if (-not $include -and $null -eq $exclusionReason) {
                Stop-Audit -Code "MANIFEST_EXCLUSION_INVALID" -Message "An explicitly excluded session requires an exclusion reason."
            }
            if ($include -and $null -ne $exclusionReason) {
                Stop-Audit -Code "MANIFEST_EXCLUSION_INVALID" -Message "An included session must not declare an exclusion reason."
            }

            $observationMap = @{}
            $observationsValue = Get-ObjectProperty -Object $session -Name "observations"
            if ($null -ne $observationsValue) {
                if (-not (Test-JsonArray -Value $observationsValue)) {
                    Stop-Audit -Code "MANIFEST_OBSERVATIONS_INVALID" -Message "Manifest observations must be a JSON array."
                }
                foreach ($observationValue in $observationsValue) {
                    $copied = Copy-ManifestObservation `
                        -Value $observationValue `
                        -Code "MANIFEST_OBSERVATION_INVALID"
                    if ($observationMap.ContainsKey($copied.line)) {
                        Stop-Audit -Code "MANIFEST_OBSERVATION_DUPLICATE" -Message "A JSONL line is annotated more than once in the manifest."
                    }
                    $observationMap[$copied.line] = $copied.observation
                }
            }

            $entries.Add([pscustomobject]@{
                fullPath = $fullPath
                sourceId = $sourceId
                include = $include
                exclusionReason = $exclusionReason
                manifestSessionId = Get-ObjectProperty -Object $session -Name "sessionId"
                manifestSessionKind = Get-ObjectProperty -Object $session -Name "sessionKind"
                manifestSkill = Get-ObjectProperty -Object $session -Name "skill"
                manifestPrivacy = Get-ObjectProperty -Object $session -Name "privacy"
                observationMap = $observationMap
            })
        }
    }
    else {
        if ($null -eq $SessionPath -or $SessionPath.Count -eq 0) {
            Stop-Audit -Code "SESSION_PATH_REQUIRED" -Message "At least one explicit JSONL session path is required."
        }
        foreach ($pathValue in $SessionPath) {
            $script:FailureSourceId = "input"
            $fullPath = Resolve-ExplicitFile `
                -Path $pathValue `
                -BasePath (Get-Location).Path `
                -ExpectedExtension ".jsonl" `
                -Code "SESSION_PATH_INVALID"
            $sourceId = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)
            if (-not (Test-SafeId -Value $sourceId)) {
                Stop-Audit -Code "SESSION_SOURCE_ID_INVALID" -Message "Direct-path input requires a safe filename stem; use a manifest sourceId otherwise." -SourceId "input"
            }
            $entries.Add([pscustomobject]@{
                fullPath = $fullPath
                sourceId = $sourceId
                include = $true
                exclusionReason = $null
                manifestSessionId = $null
                manifestSessionKind = $null
                manifestSkill = $null
                manifestPrivacy = $null
                observationMap = @{}
            })
        }
    }

    $sourceIds = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::Ordinal
    )
    $fullPaths = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($entry in $entries) {
        if (-not $sourceIds.Add([string]$entry.sourceId)) {
            Stop-Audit -Code "DUPLICATE_SOURCE_ID" -Message "Every selected session requires a unique source ID." -SourceId "manifest"
        }
        if (-not $fullPaths.Add([string]$entry.fullPath)) {
            Stop-Audit -Code "DUPLICATE_SESSION_PATH" -Message "The same JSONL session path was selected more than once." -SourceId ([string]$entry.sourceId)
        }
    }

    Initialize-RedactionRules -ManifestRedaction $manifestRedaction

    $processedSources = New-Object System.Collections.Generic.List[object]
    $allChainWork = New-Object System.Collections.Generic.List[object]
    $totalMessagePayloads = 0
    $totalUniqueMessages = 0
    $totalDuplicateMessages = 0
    $includedSessionCount = 0
    $excludedSessionCount = 0
    $privacyClassifications = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::Ordinal
    )

    foreach ($entry in @($entries | Sort-Object sourceId -CaseSensitive)) {
        $script:FailureSourceId = [string]$entry.sourceId
        $script:FailureLine = 0
        $records = @(Read-JsonLines -FullPath ([string]$entry.fullPath))
        $metadata = Get-SessionMetadata -Records $records
        $sessionId = Resolve-TextDeclaration `
            -MetadataValue $metadata.sessionId `
            -ManifestValue $entry.manifestSessionId `
            -Code "SESSION_ID_CONFLICT"
        $sessionKind = Resolve-TextDeclaration `
            -MetadataValue $metadata.sessionKind `
            -ManifestValue $entry.manifestSessionKind `
            -Code "SESSION_KIND_CONFLICT" `
            -Lowercase
        if ($null -eq $sessionKind -or $AllowedSessionKinds -cnotcontains $sessionKind) {
            Stop-Audit -Code "SESSION_KIND_MISSING" -Message "Every selected session must be declared root, fork, or subagent."
        }
        if ($null -ne $sessionId -and -not (Test-SafeId -Value $sessionId)) {
            Stop-Audit -Code "SESSION_ID_INVALID" -Message "A session ID is not a safe stable identifier."
        }

        $excludedReason = $null
        if ($sessionKind -in @("fork", "subagent")) {
            $excludedReason = "declared_$sessionKind"
        }
        elseif (-not [bool]$entry.include) {
            $excludedReason = "manifest_exclusion"
        }

        if ($null -ne $excludedReason) {
            $excludedSessionCount++
            $processedSources.Add([pscustomobject][ordered]@{
                sourceId = [string]$entry.sourceId
                status = "excluded"
                sessionId = $sessionId
                sessionKind = $sessionKind
                reason = if ($excludedReason -eq "manifest_exclusion") {
                    Protect-Text -Text ([string]$entry.exclusionReason)
                }
                else {
                    $excludedReason
                }
                linesRead = $records.Count
                sourceLink = if ($metadata.line -gt 0) {
                    "$($entry.sourceId)#L$($metadata.line)"
                }
                else {
                    $null
                }
            })
            continue
        }

        if ($sessionKind -cne "root") {
            Stop-Audit -Code "SESSION_KIND_INVALID" -Message "Only declared root sessions may be included."
        }
        if ($null -eq $sessionId) {
            Stop-Audit -Code "SESSION_ID_MISSING" -Message "Every included root session requires a stable session ID."
        }
        $skill = Resolve-ObjectDeclaration `
            -MetadataValue $metadata.skill `
            -ManifestValue $entry.manifestSkill `
            -Code "SESSION_SKILL_CONFLICT" `
            -Kind "skill"
        if ($null -eq $skill) {
            Stop-Audit -Code "SESSION_SKILL_MISSING" -Message "Every included root session requires skill name and version."
        }
        $privacy = Resolve-ObjectDeclaration `
            -MetadataValue $metadata.privacy `
            -ManifestValue $entry.manifestPrivacy `
            -Code "SESSION_PRIVACY_CONFLICT" `
            -Kind "privacy"
        if ($null -eq $privacy) {
            Stop-Audit -Code "SESSION_PRIVACY_MISSING" -Message "Every included root session requires privacy and redaction declarations."
        }
        [void]$privacyClassifications.Add([string]$privacy.classification)

        $candidates = New-Object System.Collections.Generic.List[object]
        $consumedManifestLines = New-Object "System.Collections.Generic.HashSet[int]"
        foreach ($record in $records) {
            $script:FailureLine = [int]$record.line
            $candidate = Get-MessageCandidate `
                -Event $record.event `
                -Line ([int]$record.line)
            $manifestObservation = if ($entry.observationMap.ContainsKey([int]$record.line)) {
                [void]$consumedManifestLines.Add([int]$record.line)
                $entry.observationMap[[int]$record.line]
            }
            else {
                $null
            }
            if ($null -eq $candidate) {
                if ($null -ne $manifestObservation) {
                    Stop-Audit -Code "ANNOTATION_NOT_MESSAGE" -Message "A manifest observation points to a line that is not a supported message payload."
                }
                continue
            }
            if ($null -eq $candidate.content -or
                [string]::IsNullOrWhiteSpace([string]$candidate.content)) {
                if ($null -ne $candidate.observation -or $null -ne $manifestObservation) {
                    Stop-Audit -Code "OBSERVED_MESSAGE_EMPTY" -Message "An observed message does not contain supported non-empty text."
                }
                continue
            }
            if ($null -ne $candidate.observation -and
                $null -ne $manifestObservation -and
                (ConvertTo-CanonicalJson -Value $candidate.observation) -cne
                    (ConvertTo-CanonicalJson -Value $manifestObservation)) {
                Stop-Audit -Code "OBSERVATION_CONFLICT" -Message "Manifest and inline observation declarations conflict."
            }
            if ($null -eq $candidate.observation) {
                $candidate.observation = $manifestObservation
            }
            $candidates.Add($candidate)
        }
        if ($consumedManifestLines.Count -ne $entry.observationMap.Count) {
            Stop-Audit -Code "MANIFEST_OBSERVATION_LINE_INVALID" -Message "A manifest observation line is outside the selected JSONL evidence."
        }

        $uniqueCandidates = New-Object System.Collections.Generic.List[object]
        $messageIdIndex = @{}
        $duplicateCount = 0
        foreach ($candidate in $candidates) {
            $script:FailureLine = [int]$candidate.line
            $duplicateTarget = $null
            if ($null -ne $candidate.messageId -and
                $messageIdIndex.ContainsKey([string]$candidate.messageId)) {
                $duplicateTarget = $uniqueCandidates[$messageIdIndex[[string]$candidate.messageId]]
                if ($duplicateTarget.role -cne $candidate.role -or
                    $duplicateTarget.content -cne $candidate.content) {
                    Stop-Audit -Code "MESSAGE_ID_CONFLICT" -Message "A stable message ID is reused for different payloads."
                }
            }
            elseif ($uniqueCandidates.Count -gt 0) {
                $previous = $uniqueCandidates[$uniqueCandidates.Count - 1]
                if ($previous.role -ceq $candidate.role -and
                    $previous.content -ceq $candidate.content) {
                    $duplicateTarget = $previous
                }
            }

            if ($null -ne $duplicateTarget) {
                if ($null -ne $duplicateTarget.observation -and
                    $null -ne $candidate.observation -and
                    (ConvertTo-CanonicalJson -Value $duplicateTarget.observation) -cne
                        (ConvertTo-CanonicalJson -Value $candidate.observation)) {
                    Stop-Audit -Code "DUPLICATE_OBSERVATION_CONFLICT" -Message "Duplicate message payloads carry conflicting observations."
                }
                if ($null -eq $duplicateTarget.observation) {
                    $duplicateTarget.observation = $candidate.observation
                }
                $duplicateTarget.lines = @($duplicateTarget.lines + [int]$candidate.line)
                if ($null -ne $candidate.messageId -and
                    -not $messageIdIndex.ContainsKey([string]$candidate.messageId)) {
                    $messageIdIndex[[string]$candidate.messageId] =
                        $uniqueCandidates.IndexOf($duplicateTarget)
                }
                $duplicateCount++
                continue
            }

            $retained = [pscustomobject]@{
                sourceId = [string]$entry.sourceId
                sessionId = $sessionId
                line = [int]$candidate.line
                lines = @([int]$candidate.line)
                role = $candidate.role
                content = [string]$candidate.content
                messageId = $candidate.messageId
                observation = $candidate.observation
                redactedContent = $null
            }
            $uniqueCandidates.Add($retained)
            if ($null -ne $candidate.messageId) {
                $messageIdIndex[[string]$candidate.messageId] = $uniqueCandidates.Count - 1
            }
        }

        $observed = New-Object System.Collections.Generic.List[object]
        foreach ($candidate in $uniqueCandidates) {
            if ($null -eq $candidate.observation) {
                continue
            }
            $script:FailureLine = [int]$candidate.line
            if ($candidate.role -notin @("user", "assistant")) {
                Stop-Audit -Code "OBSERVED_MESSAGE_ROLE_MISSING" -Message "An observed message must resolve to user or assistant role."
            }
            $normalizedObservation = Validate-Observation `
                -Value $candidate.observation `
                -Role ([string]$candidate.role)
            $candidate.observation = $normalizedObservation
            $candidate.redactedContent = Protect-Text -Text ([string]$candidate.content)
            $redactedMissedContext = New-Object System.Collections.Generic.List[object]
            foreach ($context in $normalizedObservation.missedContext) {
                $redactedMissedContext.Add([pscustomobject][ordered]@{
                    kind = $context.kind
                    description = Protect-Text -Text ([string]$context.description)
                    sourceLink = $context.sourceLink
                })
            }
            $normalizedObservation | Add-Member `
                -NotePropertyName "redactedMissedContext" `
                -NotePropertyValue $redactedMissedContext.ToArray()
            $observed.Add($candidate)
        }
        if ($observed.Count -eq 0) {
            Stop-Audit -Code "NO_OBSERVATIONS" -Message "An included root session contains no annotated observation chain."
        }

        $groups = @{}
        foreach ($candidate in $observed) {
            $chainId = [string]$candidate.observation.chainId
            if (-not $groups.ContainsKey($chainId)) {
                $groups[$chainId] = New-Object System.Collections.Generic.List[object]
            }
            $groups[$chainId].Add($candidate)
        }

        $sessionChainCount = 0
        foreach ($chainId in @($groups.Keys | Sort-Object -CaseSensitive)) {
            $events = @($groups[$chainId] | Sort-Object line)
            if ($events.Count -lt 2 -or
                $events[0].observation.stage -cne "request" -or
                $events[1].observation.stage -cne "first_output") {
                $script:FailureLine = [int]$events[0].line
                Stop-Audit -Code "CHAIN_OPENING_INVALID" -Message "Every observation chain must begin with request then first_output."
            }
            if (@($events | Where-Object { $_.observation.stage -ceq "request" }).Count -ne 1 -or
                @($events | Where-Object { $_.observation.stage -ceq "first_output" }).Count -ne 1) {
                $script:FailureLine = [int]$events[0].line
                Stop-Audit -Code "CHAIN_CARDINALITY_INVALID" -Message "A chain must contain exactly one request and one first output."
            }

            $chainSkill = $skill
            foreach ($event in $events) {
                if ($null -eq $event.observation.skill) { continue }
                if ((ConvertTo-CanonicalJson -Value $event.observation.skill) -cne
                    (ConvertTo-CanonicalJson -Value $chainSkill)) {
                    if ($event.observation.stage -ceq "request" -and
                        $chainSkill -eq $skill) {
                        $chainSkill = $event.observation.skill
                    }
                    else {
                        $script:FailureLine = [int]$event.line
                        Stop-Audit -Code "CHAIN_SKILL_CONFLICT" -Message "Skill declarations within one chain do not match."
                    }
                }
            }
            foreach ($event in $events) {
                if ($null -ne $event.observation.skill -and
                    (ConvertTo-CanonicalJson -Value $event.observation.skill) -cne
                        (ConvertTo-CanonicalJson -Value $chainSkill)) {
                    $script:FailureLine = [int]$event.line
                    Stop-Audit -Code "CHAIN_SKILL_CONFLICT" -Message "Skill declarations within one chain do not match."
                }
            }

            $requestEvent = $events[0]
            $firstOutputEvent = $events[1]
            $lastOutputEvent = $firstOutputEvent
            $correctionEvents = New-Object System.Collections.Generic.List[object]
            $revisedOutputEvents = New-Object System.Collections.Generic.List[object]
            $manualEditEvents = New-Object System.Collections.Generic.List[object]
            $acceptedOutputEvent = $null
            $acceptanceEvent = $null
            $pendingCorrection = $false
            $accepted = $false

            for ($index = 2; $index -lt $events.Count; $index++) {
                $event = $events[$index]
                $script:FailureLine = [int]$event.line
                $stage = [string]$event.observation.stage
                if ($accepted) {
                    Stop-Audit -Code "CHAIN_EVENT_AFTER_ACCEPTANCE" -Message "A chain contains observed activity after acceptance."
                }
                switch ($stage) {
                    "correction" {
                        if ($pendingCorrection) {
                            Stop-Audit -Code "CHAIN_CORRECTION_SEQUENCE_INVALID" -Message "A correction must be resolved or left final before another correction."
                        }
                        if ($event.observation.causes -ccontains "repeat_after_fix" -and
                            ($correctionEvents.Count -eq 0 -or $revisedOutputEvents.Count -eq 0)) {
                            Stop-Audit -Code "REPEAT_AFTER_FIX_SEQUENCE_INVALID" -Message "The repeat_after_fix cause requires an earlier correction and revised output in the same chain."
                        }
                        $correctionEvents.Add($event)
                        $pendingCorrection = $true
                    }
                    "revised_output" {
                        if (-not $pendingCorrection) {
                            Stop-Audit -Code "CHAIN_REVISION_SEQUENCE_INVALID" -Message "A revised output requires a preceding correction."
                        }
                        $revisedOutputEvents.Add($event)
                        $lastOutputEvent = $event
                        $pendingCorrection = $false
                    }
                    "accepted_output" {
                        if (-not $pendingCorrection) {
                            Stop-Audit -Code "CHAIN_ACCEPTED_OUTPUT_SEQUENCE_INVALID" -Message "An accepted revised output requires a preceding correction."
                        }
                        $revisedOutputEvents.Add($event)
                        $lastOutputEvent = $event
                        $acceptedOutputEvent = $event
                        $pendingCorrection = $false
                        $accepted = $true
                    }
                    "acceptance" {
                        if ($pendingCorrection) {
                            Stop-Audit -Code "CHAIN_ACCEPTANCE_SEQUENCE_INVALID" -Message "Acceptance cannot follow an unresolved correction."
                        }
                        $acceptedOutputEvent = $lastOutputEvent
                        $acceptanceEvent = $event
                        $accepted = $true
                    }
                    "manual_edit" {
                        if ($pendingCorrection) {
                            Stop-Audit -Code "CHAIN_MANUAL_EDIT_SEQUENCE_INVALID" -Message "A manual edit cannot overlap an unresolved correction."
                        }
                        if ($event.observation.causes -ccontains "repeat_after_fix" -and
                            ($correctionEvents.Count -eq 0 -or $revisedOutputEvents.Count -eq 0)) {
                            Stop-Audit -Code "REPEAT_AFTER_FIX_SEQUENCE_INVALID" -Message "The repeat_after_fix cause requires an earlier correction and revised output in the same chain."
                        }
                        $manualEditEvents.Add($event)
                    }
                    default {
                        Stop-Audit -Code "CHAIN_SEQUENCE_INVALID" -Message "A request or first output appears outside the chain opening."
                    }
                }
            }

            $classifiedEvents = $correctionEvents.ToArray() + $manualEditEvents.ToArray()
            $classifications = @(
                $classifiedEvents |
                    ForEach-Object { [string]$_.observation.classification }
            )
            $hasDefect = $classifications -ccontains "first_pass_defect"
            $hasScopeChange = $classifications -ccontains "user_scope_change"
            $causeSet = New-Object "System.Collections.Generic.HashSet[string]" (
                [System.StringComparer]::Ordinal
            )
            $contextMap = @{}
            $confidenceValues = New-Object System.Collections.Generic.List[double]
            foreach ($event in $classifiedEvents) {
                foreach ($cause in $event.observation.causes) {
                    [void]$causeSet.Add([string]$cause)
                }
                foreach ($context in $event.observation.redactedMissedContext) {
                    $contextKey = ConvertTo-CanonicalJson -Value $context
                    if (-not $contextMap.ContainsKey($contextKey)) {
                        $contextMap[$contextKey] = $context
                    }
                }
                $confidenceValues.Add([double]$event.observation.confidence)
            }
            $chainConfidence = if ($confidenceValues.Count -gt 0) {
                [double](@($confidenceValues | Measure-Object -Minimum).Minimum)
            }
            else {
                $null
            }

            $allSourceLinks = New-Object "System.Collections.Generic.HashSet[string]" (
                [System.StringComparer]::Ordinal
            )
            foreach ($event in $events) {
                foreach ($link in (Get-AutomaticSourceLinks `
                    -SourceId ([string]$event.sourceId) `
                    -Lines @($event.lines))) {
                    [void]$allSourceLinks.Add($link)
                }
                foreach ($link in $event.observation.sourceLinks) {
                    [void]$allSourceLinks.Add([string]$link)
                }
            }

            $outcome = if ($null -ne $acceptedOutputEvent) {
                if ($hasDefect) {
                    "accepted_after_rework"
                }
                elseif ($hasScopeChange) {
                    "accepted_after_scope_change"
                }
                else {
                    "accepted_first_pass"
                }
            }
            elseif ($pendingCorrection) {
                "awaiting_revision"
            }
            elseif ($manualEditEvents.Count -gt 0) {
                "manual_edit_unconfirmed"
            }
            elseif ($revisedOutputEvents.Count -gt 0) {
                "revised_unconfirmed"
            }
            else {
                "unconfirmed_first_output"
            }

            $allChainWork.Add([pscustomobject]@{
                sourceId = [string]$entry.sourceId
                sessionId = $sessionId
                chainId = $chainId
                requestLine = [int]$requestEvent.line
                skill = $chainSkill
                request = New-RenderedMessage -Message $requestEvent -Observation $requestEvent.observation
                firstOutput = New-RenderedMessage -Message $firstOutputEvent -Observation $firstOutputEvent.observation
                corrections = @(
                    foreach ($event in $correctionEvents) {
                        New-RenderedMessage -Message $event -Observation $event.observation
                    }
                )
                revisedOutputs = @(
                    foreach ($event in $revisedOutputEvents) {
                        New-RenderedMessage -Message $event -Observation $event.observation
                    }
                )
                acceptedOutput = if ($null -ne $acceptedOutputEvent) {
                    New-RenderedMessage `
                        -Message $acceptedOutputEvent `
                        -Observation $acceptedOutputEvent.observation
                }
                else {
                    $null
                }
                acceptance = if ($null -ne $acceptanceEvent) {
                    New-RenderedMessage `
                        -Message $acceptanceEvent `
                        -Observation $acceptanceEvent.observation
                }
                else {
                    $null
                }
                manualEdits = @(
                    foreach ($event in $manualEditEvents) {
                        New-RenderedMessage -Message $event -Observation $event.observation
                    }
                )
                causes = @($causeSet | Sort-Object -CaseSensitive)
                missedContext = @(
                    $contextMap.Keys |
                        Sort-Object -CaseSensitive |
                        ForEach-Object { $contextMap[$_] }
                )
                confidence = $chainConfidence
                firstPassDefect = [bool]$hasDefect
                userScopeChange = [bool]$hasScopeChange
                outcome = $outcome
                sourceLinks = Sort-SourceLinks -Links @($allSourceLinks)
            })
            $sessionChainCount++
        }

        $includedSessionCount++
        $totalMessagePayloads += $candidates.Count
        $totalUniqueMessages += $uniqueCandidates.Count
        $totalDuplicateMessages += $duplicateCount
        $processedSources.Add([pscustomobject][ordered]@{
            sourceId = [string]$entry.sourceId
            status = "included"
            sessionId = $sessionId
            sessionKind = "root"
            skill = $skill
            privacy = $privacy
            linesRead = $records.Count
            messagePayloads = $candidates.Count
            uniqueMessagePayloads = $uniqueCandidates.Count
            duplicateMessagePayloads = $duplicateCount
            observedChains = $sessionChainCount
            sourceLink = if ($metadata.line -gt 0) {
                "$($entry.sourceId)#L$($metadata.line)"
            }
            else {
                $null
            }
        })
    }

    if ($includedSessionCount -eq 0) {
        Stop-Audit -Code "NO_INCLUDED_SESSIONS" -Message "The explicit evidence set contains no included root session." -SourceId "manifest" -Line 0
    }
    if ($allChainWork.Count -eq 0) {
        Stop-Audit -Code "NO_OBSERVATION_CHAINS" -Message "The included root sessions contain no complete observation chain." -SourceId "manifest" -Line 0
    }

    $chains = @(
        $allChainWork |
            Sort-Object sourceId, requestLine, chainId |
            ForEach-Object {
                [pscustomobject][ordered]@{
                    sessionId = $_.sessionId
                    chainId = $_.chainId
                    skill = $_.skill
                    request = $_.request
                    firstOutput = $_.firstOutput
                    corrections = @($_.corrections)
                    revisedOutputs = @($_.revisedOutputs)
                    acceptedOutput = $_.acceptedOutput
                    acceptance = $_.acceptance
                    manualEdits = @($_.manualEdits)
                    causes = @($_.causes)
                    missedContext = @($_.missedContext)
                    confidence = $_.confidence
                    firstPassDefect = $_.firstPassDefect
                    userScopeChange = $_.userScopeChange
                    outcome = $_.outcome
                    sourceLinks = @($_.sourceLinks)
                }
            }
    )

    $chainCount = $chains.Count
    $defectChains = @($chains | Where-Object { $_.firstPassDefect }).Count
    $scopeChangeChains = @($chains | Where-Object { $_.userScopeChange }).Count
    $manualEditChains = @($chains | Where-Object { $_.manualEdits.Count -gt 0 }).Count
    $acceptedChains = @($chains | Where-Object { $null -ne $_.acceptedOutput }).Count
    $unresolvedChains = $chainCount - $acceptedChains
    $correctionEvents = @($chains | ForEach-Object { @($_.corrections) }).Count
    $manualEditEvents = @($chains | ForEach-Object { @($_.manualEdits) }).Count
    $classifiedEvents = @(
        $chains |
            ForEach-Object { @($_.corrections) + @($_.manualEdits) }
    )
    $defectEvents = @(
        $classifiedEvents |
            Where-Object { $_.classification -ceq "first_pass_defect" }
    ).Count
    $scopeChangeEvents = @(
        $classifiedEvents |
            Where-Object { $_.classification -ceq "user_scope_change" }
    ).Count
    $confidenceValues = @(
        $classifiedEvents |
            ForEach-Object { [double]$_.confidence }
    )
    $averageConfidence = if ($confidenceValues.Count -gt 0) {
        [math]::Round(
            [double](($confidenceValues | Measure-Object -Average).Average),
            4,
            [System.MidpointRounding]::AwayFromZero
        )
    }
    else {
        [double]0
    }

    $causeCounts = New-Object System.Collections.Generic.List[object]
    foreach ($cause in $AllowedCauses) {
        $count = @(
            $classifiedEvents |
                Where-Object { @($_.causes) -ccontains $cause }
        ).Count
        if ($count -gt 0) {
            $causeCounts.Add([pscustomobject][ordered]@{
                cause = $cause
                events = $count
            })
        }
    }

    $redactionSummary = @(
        foreach ($rule in $script:RedactionRules) {
            [pscustomobject][ordered]@{
                id = [string]$rule.id
                matches = [int]$rule.matches
            }
        }
    )

    $result = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        status = "complete"
        sources = @($processedSources | Sort-Object sourceId -CaseSensitive)
        chains = @($chains)
        metrics = [pscustomobject][ordered]@{
            sessionsProvided = $entries.Count
            sessionsIncluded = $includedSessionCount
            sessionsExcluded = $excludedSessionCount
            messagePayloads = $totalMessagePayloads
            uniqueMessagePayloads = $totalUniqueMessages
            duplicateMessagePayloads = $totalDuplicateMessages
            observedChains = $chainCount
            acceptedChains = $acceptedChains
            unresolvedChains = $unresolvedChains
            correctionEvents = $correctionEvents
            manualEditEvents = $manualEditEvents
            classifiedReworkEvents = $classifiedEvents.Count
            firstPassDefectEvents = $defectEvents
            userScopeChangeEvents = $scopeChangeEvents
            firstPassDefectChains = $defectChains
            userScopeChangeChains = $scopeChangeChains
            manualEditChains = $manualEditChains
            firstPassDefectRate = Get-Ratio -Numerator $defectChains -Denominator $chainCount
            firstPassSuccessRate = Get-Ratio -Numerator ($chainCount - $defectChains) -Denominator $chainCount
            userScopeChangeRate = Get-Ratio -Numerator $scopeChangeChains -Denominator $chainCount
            averageCorrectionsPerChain = Get-Ratio -Numerator $correctionEvents -Denominator $chainCount
            averageClassificationConfidence = $averageConfidence
            causeCounts = $causeCounts.ToArray()
        }
        privacy = [pscustomobject][ordered]@{
            contentEmission = "redacted"
            rawContentIncluded = $false
            sourcePathEmission = "source-id-only"
            classifications = @($privacyClassifications | Sort-Object -CaseSensitive)
            rules = @($redactionSummary)
        }
        diagnostics = @()
    }

    $result | ConvertTo-Json -Depth 24
    exit 0
}
catch {
    $exception = $_.Exception
    $code = if ($exception.Data.Contains("AuditCode")) {
        [string]$exception.Data["AuditCode"]
    }
    else {
        "SESSION_AUDIT_UNEXPECTED_ERROR"
    }
    $message = if ($exception.Data.Contains("AuditCode")) {
        [string]$exception.Message
    }
    else {
        "The session rework audit encountered an unexpected parser or filesystem error."
    }
    $sourceId = if ($exception.Data.Contains("SourceId")) {
        [string]$exception.Data["SourceId"]
    }
    else {
        $script:FailureSourceId
    }
    $line = if ($exception.Data.Contains("Line")) {
        [int]$exception.Data["Line"]
    }
    else {
        [int]$script:FailureLine
    }
    $failure = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        status = "blocked"
        sources = @()
        chains = @()
        metrics = $null
        privacy = [pscustomobject][ordered]@{
            contentEmission = "none"
            rawContentIncluded = $false
            sourcePathEmission = "source-id-only"
        }
        diagnostics = @(
            [pscustomobject][ordered]@{
                code = $code
                message = $message
                sourceId = $sourceId
                line = $line
            }
        )
    }
    $failure | ConvertTo-Json -Depth 8
    exit 2
}
