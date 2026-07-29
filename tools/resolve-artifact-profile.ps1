[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "Path")]
    [string]$RequestPath,

    [Parameter(Mandatory = $true, ParameterSetName = "Json")]
    [string]$RequestJson,

    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$LayerPriorities = @{
    "explicit-request"   = 900
    "accepted-decision"  = 800
    "accepted-baseline"  = 790
    "artifact-profile"   = 700
    "project-profile"    = 690
    "team-preferences"   = 680
    "terminology"        = 600
    "open-questions"     = 590
    "canonical-fallback" = 100
}

function Test-ObjectProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object.PSObject.Properties[$Name]
}

function Get-OptionalProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        $Default = $null
    )

    if (Test-ObjectProperty -Object $Object -Name $Name) {
        return $Object.$Name
    }
    return $Default
}

function Get-StrictBoolean {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [bool]$Default = $false
    )

    if (-not (Test-ObjectProperty -Object $Object -Name $Name)) {
        return $Default
    }
    $value = $Object.$Name
    if ($value -isnot [bool]) {
        throw "'$Name' must be a JSON boolean."
    }
    return [bool]$value
}

function ConvertTo-StringArray {
    param($Value)

    if ($null -eq $Value) {
        return @()
    }
    if ($Value -is [string]) {
        return @([string]$Value)
    }
    return @($Value | ForEach-Object { [string]$_ })
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Purpose,
        [switch]$AllowMissing
    )

    $candidate = if ([System.IO.Path]::IsPathRooted($Path)) {
        [System.IO.Path]::GetFullPath($Path)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
    }

    $rootPrefix = $Root.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    $insideRoot = $candidate.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase) -or
        $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)
    if (-not $insideRoot) {
        throw "$Purpose must stay inside the repository root: $Path"
    }
    if (-not $AllowMissing -and -not (Test-Path -LiteralPath $candidate)) {
        throw "$Purpose does not exist: $Path"
    }
    return $candidate
}

function Get-RepoRelativePath {
    param([Parameter(Mandatory = $true)][string]$FullPath)

    if ($FullPath.Equals($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "."
    }
    return $FullPath.Substring($Root.Length).TrimStart("\", "/").Replace("\", "/")
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
        $parts = foreach ($key in @($Value.Keys | ForEach-Object { [string]$_ } | Sort-Object)) {
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

function Get-CanonicalHash {
    param([Parameter(Mandatory = $true)]$Value)

    $canonical = ConvertTo-CanonicalJson -Value $Value
    $bytes = $Utf8NoBom.GetBytes($canonical)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }
    return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
}

function Get-TextHash {
    param([AllowEmptyString()][Parameter(Mandatory = $true)][string]$Text)

    $bytes = $Utf8NoBom.GetBytes($Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }
    return (($hash | ForEach-Object { $_.ToString("x2") }) -join "")
}

function Read-JsonDocument {
    param(
        [Parameter(Mandatory = $true)][string]$FullPath,
        [Parameter(Mandatory = $true)][string]$Purpose
    )

    $extension = [System.IO.Path]::GetExtension($FullPath)
    if ($extension -notin @(".json", ".md")) {
        throw "$Purpose must be a .json or .md file."
    }

    $text = [System.IO.File]::ReadAllText($FullPath)
    if ($extension.Equals(
        ".md",
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        $matches = [regex]::Matches($text, '(?ms)```json\s*(.*?)\s*```')
        if ($matches.Count -ne 1) {
            throw "$Purpose Markdown source must contain exactly one fenced json block."
        }
        $text = $matches[0].Groups[1].Value
    }

    try {
        return $text | ConvertFrom-Json
    }
    catch {
        throw "$Purpose contains invalid JSON: $($_.Exception.Message)"
    }
}

function New-CaseInsensitiveSet {
    param($Values)

    $set = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($value in (ConvertTo-StringArray -Value $Values)) {
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            [void]$set.Add($value)
        }
    }
    Write-Output -NoEnumerate $set
}

function Get-SourceDocumentValue {
    param(
        [Parameter(Mandatory = $true)]$Source,
        [Parameter(Mandatory = $true)][string]$SourceId
    )

    $hasValues = Test-ObjectProperty -Object $Source -Name "values"
    $hasPath = Test-ObjectProperty -Object $Source -Name "path"
    if ($hasValues -eq $hasPath) {
        throw "Source '$SourceId' must contain exactly one of 'values' or 'path'."
    }

    if ($hasValues) {
        return [pscustomobject]@{
            Document = [pscustomobject]@{
                values = $Source.values
            }
            Path = "inline:$SourceId"
            IsInline = $true
        }
    }

    $fullPath = Resolve-RepoPath -Path ([string]$Source.path) -Purpose "Profile source '$SourceId'"
    return [pscustomobject]@{
        Document = Read-JsonDocument -FullPath $fullPath -Purpose "Profile source '$SourceId'"
        Path = Get-RepoRelativePath -FullPath $fullPath
        IsInline = $false
    }
}

function Merge-StringArrays {
    param($First, $Second)

    return @(
        @(
            (ConvertTo-StringArray -Value $First) +
            (ConvertTo-StringArray -Value $Second)
        ) |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
    )
}

function Assert-AcceptedStatus {
    param(
        [Parameter(Mandatory = $true)][string]$Layer,
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][string]$SourceId
    )

    if ($Layer -eq "accepted-decision") {
        $allowed = @("accepted")
        if ($allowed -notcontains $Status.ToLowerInvariant()) {
            throw "Accepted decision '$SourceId' has non-accepted status '$Status'."
        }
    }
    if ($Layer -eq "accepted-baseline") {
        $allowed = @("baselined", "shipped")
        if ($allowed -notcontains $Status.ToLowerInvariant()) {
            throw "Accepted baseline '$SourceId' has non-baseline status '$Status'."
        }
    }
}

function Add-BlockingResolutionConflict {
    param(
        [Parameter(Mandatory = $true)]$ConflictList,
        [Parameter(Mandatory = $true)]$ReasonList,
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][string]$Kind,
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $true)][string]$Resolution
    )

    [void]$ConflictList.Add([pscustomobject][ordered]@{
        key = $Key
        kind = $Kind
        severity = "material"
        selectedSource = $null
        otherSources = [object[]]@()
        resolution = $Resolution
    })
    $ReasonList.Add($Reason)
}

function Resolve-AcceptedAuthority {
    param(
        [Parameter(Mandatory = $true)]$Source,
        [Parameter(Mandatory = $true)][string]$Layer,
        [Parameter(Mandatory = $true)][string]$SourceId
    )

    if (-not (Test-ObjectProperty -Object $Source -Name "authority") -or
        $Source.authority -isnot [pscustomobject]) {
        throw "Accepted source '$SourceId' requires an authority object verified by the authoritative baseline resolver."
    }
    $authority = $Source.authority
    $requiredAuthorityProperties = @(
        "workspaceRoot",
        "registryPath",
        "artifactId",
        "artifactType",
        "baselineVersion",
        "baselinePath",
        "baselineSha256"
    )
    foreach ($name in $requiredAuthorityProperties) {
        if (-not (Test-ObjectProperty -Object $authority -Name $name) -or
            [string]::IsNullOrWhiteSpace([string]$authority.$name)) {
            throw "Accepted source '$SourceId' authority is missing '$name'."
        }
    }
    $expectedSha = ([string]$authority.baselineSha256).ToLowerInvariant()
    if ($expectedSha -cnotmatch "^[a-f0-9]{64}$") {
        throw "Accepted source '$SourceId' authority baselineSha256 is invalid."
    }

    $authorityWorkspace = Resolve-RepoPath `
        -Path ([string]$authority.workspaceRoot) `
        -Purpose "Accepted authority workspace for '$SourceId'"
    if (-not (Test-Path -LiteralPath $authorityWorkspace -PathType Container)) {
        throw "Accepted source '$SourceId' authority workspace is not a directory."
    }

    $baselineResolver = Join-Path $PSScriptRoot "resolve-authoritative-baseline.ps1"
    $powerShell = (Get-Process -Id $PID).Path
    $resolverOutput = @(
        & $powerShell -NoProfile -ExecutionPolicy Bypass `
            -File $baselineResolver `
            -ArtifactId ([string]$authority.artifactId) `
            -WorkspaceRoot $authorityWorkspace `
            -RegistryPath ([string]$authority.registryPath) `
            -AsJson 2>&1
    )
    $resolverExitCode = $LASTEXITCODE
    $global:LASTEXITCODE = 0
    $resolverText = $resolverOutput -join [Environment]::NewLine
    try {
        $resolvedAuthority = $resolverText | ConvertFrom-Json
    }
    catch {
        throw "Accepted source '$SourceId' authority resolver returned invalid JSON: $resolverText"
    }
    if ($resolverExitCode -ne 0 -or $resolvedAuthority.verdict -cne "resolved") {
        $diagnostics = @($resolvedAuthority.diagnostics | ForEach-Object { [string]$_.code }) -join ", "
        throw "Accepted source '$SourceId' authority did not resolve: $diagnostics"
    }

    if ([string]$resolvedAuthority.baseline.version -cne [string]$authority.baselineVersion -or
        [string]$resolvedAuthority.baseline.path -cne ([string]$authority.baselinePath).Replace("\", "/") -or
        [string]$resolvedAuthority.baseline.sha256 -cne $expectedSha) {
        throw "Accepted source '$SourceId' authority does not match the resolved baseline version, path, or SHA-256."
    }
    if ([string]$resolvedAuthority.baseline.artifactType -cne
        ([string]$authority.artifactType).ToLowerInvariant()) {
        throw "Accepted source '$SourceId' authority artifactType does not match the resolved baseline."
    }
    if ($Layer -eq "accepted-decision" -and (
        [string]$resolvedAuthority.baseline.artifactType -cne "decision" -or
        [string]$resolvedAuthority.baseline.decisionStatus -cne "accepted"
    )) {
        throw "Accepted decision '$SourceId' is not an accepted decision baseline."
    }

    if (-not (Test-ObjectProperty -Object $Source -Name "values") -or
        $Source.values -isnot [pscustomobject]) {
        throw "Accepted source '$SourceId' must provide inline values with per-value evidence."
    }
    if (-not (Test-ObjectProperty -Object $Source -Name "valueEvidence") -or
        $Source.valueEvidence -isnot [pscustomobject]) {
        throw "Accepted source '$SourceId' requires valueEvidence for every supplied value."
    }
    $authorityDocument = [System.IO.File]::ReadAllText(
        [string]$resolvedAuthority.baseline.absolutePath
    )
    foreach ($property in @($Source.values.PSObject.Properties)) {
        if (-not (Test-ObjectProperty -Object $Source.valueEvidence -Name $property.Name)) {
            throw "Accepted source '$SourceId' is missing valueEvidence for '$($property.Name)'."
        }
        $evidence = $Source.valueEvidence.($property.Name)
        if ($evidence -isnot [pscustomobject] -or
            -not (Test-ObjectProperty -Object $evidence -Name "excerpt") -or
            -not (Test-ObjectProperty -Object $evidence -Name "excerptSha256")) {
            throw "Accepted source '$SourceId' valueEvidence for '$($property.Name)' requires excerpt and excerptSha256."
        }
        $excerpt = [string]$evidence.excerpt
        $excerptSha = ([string]$evidence.excerptSha256).ToLowerInvariant()
        if ([string]::IsNullOrWhiteSpace($excerpt) -or
            $excerptSha -cnotmatch "^[a-f0-9]{64}$" -or
            (Get-TextHash -Text $excerpt) -cne $excerptSha) {
            throw "Accepted source '$SourceId' valueEvidence for '$($property.Name)' has an invalid excerpt hash."
        }
        if ($authorityDocument.IndexOf(
            $excerpt,
            [System.StringComparison]::Ordinal
        ) -lt 0) {
            throw "Accepted source '$SourceId' valueEvidence for '$($property.Name)' is not present in the verified artifact."
        }
    }

    return [pscustomobject][ordered]@{
        artifactId = [string]$resolvedAuthority.artifactId
        version = [string]$resolvedAuthority.baseline.version
        path = [string]$resolvedAuthority.baseline.path
        sha256 = [string]$resolvedAuthority.baseline.sha256
        lifecycle = [string]$resolvedAuthority.baseline.lifecycle
        artifactType = [string]$resolvedAuthority.baseline.artifactType
        decisionStatus = [string]$resolvedAuthority.baseline.decisionStatus
        registryPath = [string]$resolvedAuthority.provenance[0].path
        registrySource = [string]$resolvedAuthority.provenance[0].source
        pointerSource = [string]$resolvedAuthority.provenance[1].source
    }
}

$request = if ($PSCmdlet.ParameterSetName -eq "Json") {
    try {
        $RequestJson | ConvertFrom-Json
    }
    catch {
        throw "Resolution request JSON is invalid: $($_.Exception.Message)"
    }
}
else {
    $requestFullPath = Resolve-RepoPath -Path $RequestPath -Purpose "Resolution request"
    Read-JsonDocument -FullPath $requestFullPath -Purpose "Resolution request"
}

foreach ($requiredRequestProperty in @("schemaVersion", "project", "artifactType", "action", "sources")) {
    if (-not (Test-ObjectProperty -Object $request -Name $requiredRequestProperty)) {
        throw "Resolution request is missing '$requiredRequestProperty'."
    }
}
if ([string]$request.schemaVersion -ne "1.0") {
    throw "Unsupported artifact generation contract version '$($request.schemaVersion)'."
}
foreach ($name in @("project", "artifactType", "action")) {
    if ($request.$name -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$request.$name)) {
        throw "Resolution request '$name' must be a non-empty JSON string."
    }
}

$allowedActions = @("create", "revise", "baseline", "publish", "export")
$action = ([string]$request.action).ToLowerInvariant()
if ($allowedActions -notcontains $action) {
    throw "Unsupported artifact action '$($request.action)'."
}

$changeAuthorized = Get-StrictBoolean -Object $request -Name "changeAuthorized" -Default $false
$changeEvidenceValue = Get-OptionalProperty -Object $request -Name "changeEvidence" -Default ""
if ($changeEvidenceValue -isnot [string]) {
    throw "changeEvidence must be a JSON string."
}
$changeEvidence = [string]$changeEvidenceValue
if ($changeAuthorized -and [string]::IsNullOrWhiteSpace($changeEvidence)) {
    throw "changeEvidence is required when changeAuthorized is true."
}

$requiredKeys = New-CaseInsensitiveSet -Values (
    Get-OptionalProperty -Object $request -Name "requiredKeys" -Default @()
)
foreach ($standardKey in @(
    "outcome",
    "consumer",
    "deliverableMode",
    "sourceAuthority",
    "baselineTarget",
    "constraints",
    "materialDecisions"
)) {
    [void]$requiredKeys.Add($standardKey)
}
$requestMaterialKeys = New-CaseInsensitiveSet -Values (
    Get-OptionalProperty -Object $request -Name "materialKeys" -Default @()
)
foreach ($intrinsicMaterialKey in @(
    "outcome",
    "consumer",
    "deliverableMode",
    "sourceAuthority",
    "baselineTarget",
    "constraints",
    "materialDecisions",
    "format.frontmatter",
    "baseline.metadataMode"
)) {
    [void]$requestMaterialKeys.Add($intrinsicMaterialKey)
}
$requestResolvedQuestionIds = @(
    ConvertTo-StringArray -Value (
        Get-OptionalProperty -Object $request -Name "resolvedQuestionIds" -Default @()
    )
)
if ($requestResolvedQuestionIds.Count -gt 0) {
    throw "Top-level resolvedQuestionIds is not authoritative. Declare resolvesQuestions on an explicit-request, accepted-decision, or accepted-baseline source."
}

$normalizedSources = New-Object System.Collections.ArrayList
$seenSourceIds = New-CaseInsensitiveSet -Values @()

foreach ($source in @($request.sources)) {
    foreach ($requiredSourceProperty in @("id", "layer")) {
        if (-not (Test-ObjectProperty -Object $source -Name $requiredSourceProperty)) {
            throw "A profile source is missing '$requiredSourceProperty'."
        }
    }

    $sourceId = [string]$source.id
    if ([string]::IsNullOrWhiteSpace($sourceId)) {
        throw "Profile source id cannot be empty."
    }
    if (-not $seenSourceIds.Add($sourceId)) {
        throw "Duplicate profile source id '$sourceId'."
    }

    $layer = ([string]$source.layer).ToLowerInvariant()
    if (-not $LayerPriorities.ContainsKey($layer)) {
        throw "Source '$sourceId' uses unsupported layer '$layer'."
    }

    $sourceDocument = Get-SourceDocumentValue -Source $source -SourceId $sourceId
    $document = $sourceDocument.Document
    if (-not $sourceDocument.IsInline) {
        foreach ($profileProperty in @(
            "schemaVersion",
            "profileId",
            "project",
            "artifactType",
            "status",
            "values"
        )) {
            if (-not (Test-ObjectProperty -Object $document -Name $profileProperty)) {
                throw "Path-backed profile source '$sourceId' is missing '$profileProperty'."
            }
        }
        if ([string]$document.schemaVersion -cne "1.0") {
            throw "Path-backed profile source '$sourceId' has unsupported schemaVersion '$($document.schemaVersion)'."
        }
        if ($document.profileId -isnot [string] -or
            [string]::IsNullOrWhiteSpace([string]$document.profileId)) {
            throw "Path-backed profile source '$sourceId' has an invalid profileId."
        }
    }
    if (
        (Test-ObjectProperty -Object $document -Name "project") -and
        -not ([string]$document.project).Equals(
            [string]$request.project,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    ) {
        throw "Profile source '$sourceId' targets project '$($document.project)', not '$($request.project)'."
    }
    if (Test-ObjectProperty -Object $document -Name "artifactType") {
        $documentArtifactType = [string]$document.artifactType
        if (
            $documentArtifactType -ne "all" -and
            -not $documentArtifactType.Equals(
                [string]$request.artifactType,
                [System.StringComparison]::OrdinalIgnoreCase
            )
        ) {
            throw "Profile source '$sourceId' targets artifact '$documentArtifactType', not '$($request.artifactType)'."
        }
    }
    if (-not (Test-ObjectProperty -Object $document -Name "values")) {
        throw "Profile source '$sourceId' does not contain a values property."
    }
    if ($null -eq $document.values -or $document.values -isnot [pscustomobject]) {
        throw "Profile source '$sourceId' values must be a JSON object."
    }

    $sourceHasStatus = Test-ObjectProperty -Object $source -Name "status"
    $documentHasStatus = Test-ObjectProperty -Object $document -Name "status"
    if (
        $sourceHasStatus -and $documentHasStatus -and
        -not ([string]$source.status).Equals(
            [string]$document.status,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    ) {
        throw "Profile source '$sourceId' status '$($source.status)' conflicts with document status '$($document.status)'."
    }
    $status = [string](
        Get-OptionalProperty -Object $source -Name "status" -Default (
            Get-OptionalProperty -Object $document -Name "status" -Default "active"
        )
    )
    Assert-AcceptedStatus -Layer $layer -Status $status -SourceId $sourceId
    $authority = if ($layer -in @("accepted-decision", "accepted-baseline")) {
        Resolve-AcceptedAuthority `
            -Source $source `
            -Layer $layer `
            -SourceId $sourceId
    }
    else {
        $null
    }

    $materialKeys = Merge-StringArrays -First (
        Get-OptionalProperty -Object $document -Name "materialKeys" -Default @()
    ) -Second (
        Get-OptionalProperty -Object $source -Name "materialKeys" -Default @()
    )
    $locks = Merge-StringArrays -First (
        Get-OptionalProperty -Object $document -Name "locks" -Default @()
    ) -Second (
        Get-OptionalProperty -Object $source -Name "locks" -Default @()
    )
    $resolvesQuestions = @(
        Merge-StringArrays -First (
            Get-OptionalProperty -Object $document -Name "resolvesQuestions" -Default @()
        ) -Second (
            Get-OptionalProperty -Object $source -Name "resolvesQuestions" -Default @()
        )
    )
    $canResolveQuestions = $layer -in @(
        "explicit-request",
        "accepted-decision",
        "accepted-baseline"
    )
    if ($resolvesQuestions.Count -gt 0 -and -not $canResolveQuestions) {
        throw "Source '$sourceId' in layer '$layer' cannot resolve questions. Use an explicit request or accepted source."
    }
    $questions = @(
        @(
            Get-OptionalProperty -Object $document -Name "questions" -Default @()
        ) + @(
            Get-OptionalProperty -Object $source -Name "questions" -Default @()
        )
    )
    foreach ($question in $questions) {
        $questionMaterial = Get-StrictBoolean `
            -Object $question `
            -Name "material" `
            -Default $false
        if ($questionMaterial -and
            (Test-ObjectProperty -Object $question -Name "affectsKeys")) {
            foreach ($affectedKey in @(
                ConvertTo-StringArray -Value $question.affectsKeys
            )) {
                [void]$requestMaterialKeys.Add($affectedKey)
            }
        }
    }

    [void]$normalizedSources.Add([pscustomobject]@{
        Id = $sourceId
        Layer = $layer
        Priority = [int]$LayerPriorities[$layer]
        Status = $status
        Path = [string]$sourceDocument.Path
        Values = $document.values
        MaterialKeys = New-CaseInsensitiveSet -Values $materialKeys
        Locks = New-CaseInsensitiveSet -Values $locks
        ResolvesQuestions = New-CaseInsensitiveSet -Values $resolvesQuestions
        Questions = $questions
        IsAccepted = $layer -in @("accepted-decision", "accepted-baseline")
        CanResolveQuestions = $canResolveQuestions
        Authority = $authority
    })
}

if ($normalizedSources.Count -eq 0) {
    throw "Resolution request must contain at least one source."
}

$assignmentsByKey = @{}
foreach ($source in @($normalizedSources)) {
    foreach ($property in @($source.Values.PSObject.Properties | Sort-Object Name)) {
        $key = [string]$property.Name
        if ([string]::IsNullOrWhiteSpace($key)) {
            throw "Source '$($source.Id)' contains an empty value key."
        }
        if (-not $assignmentsByKey.ContainsKey($key)) {
            $assignmentsByKey[$key] = New-Object System.Collections.ArrayList
        }
        [void]$assignmentsByKey[$key].Add([pscustomobject]@{
            Key = $key
            Value = $property.Value
            CanonicalValue = ConvertTo-CanonicalJson -Value $property.Value
            Source = $source
        })
    }
}

$resolvedProfile = [ordered]@{}
$provenance = New-Object System.Collections.ArrayList
$conflicts = New-Object System.Collections.ArrayList
$blockingReasons = New-Object System.Collections.Generic.List[string]
$confirmationReasons = New-Object System.Collections.Generic.List[string]

foreach ($key in @($assignmentsByKey.Keys | Sort-Object)) {
    $candidates = @(
        $assignmentsByKey[$key] |
            Sort-Object @{ Expression = { $_.Source.Priority }; Descending = $true },
                @{ Expression = { $_.Source.Id }; Descending = $false }
    )
    $selected = $candidates[0]
    $resolvedProfile[$key] = $selected.Value

    $overrode = @(
        $candidates |
            Where-Object { $_.CanonicalValue -ne $selected.CanonicalValue } |
            ForEach-Object { $_.Source.Id } |
            Sort-Object -Unique
    )
    [void]$provenance.Add([pscustomobject][ordered]@{
        key = $key
        sourceId = $selected.Source.Id
        layer = $selected.Source.Layer
        priority = $selected.Source.Priority
        status = $selected.Source.Status
        sourcePath = $selected.Source.Path
        authority = $selected.Source.Authority
        overrode = [object[]]$overrode
    })

    $sameRankDifferent = @(
        $candidates |
            Where-Object {
                $_.Source.Priority -eq $selected.Source.Priority -and
                $_.CanonicalValue -ne $selected.CanonicalValue
            }
    )
    if ($sameRankDifferent.Count -gt 0) {
        $sameRankSources = @(
            @($selected.Source.Id) +
            @($sameRankDifferent | ForEach-Object { $_.Source.Id })
        ) | Sort-Object -Unique
        $isMaterial = $requestMaterialKeys.Contains($key) -or
            $selected.Source.MaterialKeys.Contains($key) -or
            $selected.Source.Locks.Contains($key) -or
            @($sameRankDifferent | Where-Object {
                $_.Source.MaterialKeys.Contains($key) -or $_.Source.Locks.Contains($key)
            }).Count -gt 0

        $severity = if ($isMaterial) { "material" } else { "warning" }
        [void]$conflicts.Add([pscustomobject][ordered]@{
            key = $key
            kind = "same-precedence-conflict"
            severity = $severity
            selectedSource = $selected.Source.Id
            otherSources = [object[]]@(
                $sameRankSources | Where-Object { $_ -ne $selected.Source.Id }
            )
            resolution = if ($isMaterial) {
                "unresolved"
            }
            else {
                "stable-source-id-selection"
            }
        })
        if ($isMaterial) {
            $blockingReasons.Add("material same-precedence conflict for '$key'")
        }
        else {
            $confirmationReasons.Add("non-material same-precedence conflict for '$key'")
        }
    }

    foreach ($candidate in @($candidates | Select-Object -Skip 1)) {
        if ($candidate.CanonicalValue -eq $selected.CanonicalValue) {
            continue
        }
        if (
            $candidate.Source.Priority -eq $selected.Source.Priority
        ) {
            continue
        }

        $materialAcceptedChange = $selected.Source.Layer -eq "explicit-request" -and
            $candidate.Source.IsAccepted -and (
                $requestMaterialKeys.Contains($key) -or
                $selected.Source.MaterialKeys.Contains($key) -or
                $candidate.Source.MaterialKeys.Contains($key) -or
                $candidate.Source.Locks.Contains($key)
            )

        if ($materialAcceptedChange) {
            if ($changeAuthorized) {
                [void]$conflicts.Add([pscustomobject][ordered]@{
                    key = $key
                    kind = "authorized-accepted-value-change"
                    severity = "warning"
                    selectedSource = $selected.Source.Id
                    otherSources = [object[]]@($candidate.Source.Id)
                    resolution = "authorized-change-requires-confirmation"
                })
                $confirmationReasons.Add("authorized accepted-value change for '$key'")
            }
            else {
                [void]$conflicts.Add([pscustomobject][ordered]@{
                    key = $key
                    kind = "locked-accepted-value-change"
                    severity = "material"
                    selectedSource = $selected.Source.Id
                    otherSources = [object[]]@($candidate.Source.Id)
                    resolution = "route-to-change"
                })
                $blockingReasons.Add("unauthorized accepted-value change for '$key'")
            }
        }
        else {
            [void]$conflicts.Add([pscustomobject][ordered]@{
                key = $key
                kind = "precedence-override"
                severity = "informational"
                selectedSource = $selected.Source.Id
                otherSources = [object[]]@($candidate.Source.Id)
                resolution = "higher-precedence-selected"
            })
        }
    }
}

foreach ($requiredKey in @($requiredKeys | Sort-Object)) {
    if (-not $resolvedProfile.Contains($requiredKey)) {
        [void]$conflicts.Add([pscustomobject][ordered]@{
            key = $requiredKey
            kind = "missing-required-value"
            severity = "material"
            selectedSource = $null
            otherSources = [object[]]@()
            resolution = "supply-authoritative-value"
        })
        $blockingReasons.Add("missing required value '$requiredKey'")
    }
}

$objectContextKeys = @(
    "consumer",
    "sourceAuthority",
    "baselineTarget",
    "constraints",
    "materialDecisions"
)
foreach ($contextKey in $objectContextKeys) {
    if ($resolvedProfile.Contains($contextKey) -and
        $resolvedProfile[$contextKey] -isnot [pscustomobject]) {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key $contextKey `
            -Kind "invalid-generation-context" `
            -Reason "generation context '$contextKey' must be a JSON object" `
            -Resolution "supply-structured-context"
    }
}
if ($resolvedProfile.Contains("deliverableMode") -and (
    $resolvedProfile["deliverableMode"] -isnot [string] -or
    [string]::IsNullOrWhiteSpace([string]$resolvedProfile["deliverableMode"])
)) {
    Add-BlockingResolutionConflict `
        -ConflictList $conflicts `
        -ReasonList $blockingReasons `
        -Key "deliverableMode" `
        -Kind "invalid-generation-context" `
        -Reason "deliverableMode must be a non-empty string" `
        -Resolution "supply-deliverable-mode"
}
if ($resolvedProfile.Contains("outcome") -and (
    $resolvedProfile["outcome"] -isnot [string] -or
    [string]::IsNullOrWhiteSpace([string]$resolvedProfile["outcome"])
)) {
    Add-BlockingResolutionConflict `
        -ConflictList $conflicts `
        -ReasonList $blockingReasons `
        -Key "outcome" `
        -Kind "invalid-generation-context" `
        -Reason "outcome must be a non-empty string" `
        -Resolution "supply-artifact-outcome"
}
if ($resolvedProfile.Contains("consumer") -and
    $resolvedProfile["consumer"] -is [pscustomobject]) {
    $consumer = $resolvedProfile["consumer"]
    if (-not (Test-ObjectProperty -Object $consumer -Name "primary") -or
        $consumer.primary -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$consumer.primary)) {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "consumer" `
            -Kind "invalid-generation-context" `
            -Reason "consumer.primary must be a non-empty string" `
            -Resolution "supply-primary-consumer"
    }
}
if ($resolvedProfile.Contains("constraints") -and
    $resolvedProfile["constraints"] -is [pscustomobject]) {
    $constraints = $resolvedProfile["constraints"]
    if (-not (Test-ObjectProperty -Object $constraints -Name "noInventedBehavior") -or
        $constraints.noInventedBehavior -isnot [bool]) {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "constraints" `
            -Kind "invalid-generation-context" `
            -Reason "constraints.noInventedBehavior must be a JSON boolean" `
            -Resolution "supply-no-invention-constraint"
    }
}
if ($resolvedProfile.Contains("materialDecisions") -and
    $resolvedProfile["materialDecisions"] -is [pscustomobject] -and
    @($resolvedProfile["materialDecisions"].PSObject.Properties).Count -eq 0) {
    Add-BlockingResolutionConflict `
        -ConflictList $conflicts `
        -ReasonList $blockingReasons `
        -Key "materialDecisions" `
        -Kind "invalid-generation-context" `
        -Reason "materialDecisions must record confirmed values or explicit applicability" `
        -Resolution "complete-material-decision-preflight"
}

$normalizedSourceIds = New-CaseInsensitiveSet -Values @(
    $normalizedSources | ForEach-Object { $_.Id }
)
if ($resolvedProfile.Contains("sourceAuthority") -and
    $resolvedProfile["sourceAuthority"] -is [pscustomobject]) {
    $sourceAuthority = $resolvedProfile["sourceAuthority"]
    if (-not (Test-ObjectProperty -Object $sourceAuthority -Name "primary") -or
        $sourceAuthority.primary -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$sourceAuthority.primary)) {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "sourceAuthority" `
            -Kind "invalid-source-authority" `
            -Reason "sourceAuthority.primary must name a supplied source ID" `
            -Resolution "supply-authoritative-source-id"
    }
    else {
        $authorityIds = @([string]$sourceAuthority.primary)
        if (Test-ObjectProperty -Object $sourceAuthority -Name "supporting") {
            $authorityIds += @(ConvertTo-StringArray -Value $sourceAuthority.supporting)
        }
        foreach ($authorityId in @($authorityIds | Sort-Object -Unique)) {
            if (-not $normalizedSourceIds.Contains($authorityId)) {
                Add-BlockingResolutionConflict `
                    -ConflictList $conflicts `
                    -ReasonList $blockingReasons `
                    -Key "sourceAuthority" `
                    -Kind "unknown-source-authority" `
                    -Reason "sourceAuthority references missing source '$authorityId'" `
                    -Resolution "name-a-supplied-source-id"
            }
        }
    }
}

if ($resolvedProfile.Contains("baselineTarget") -and
    $resolvedProfile["baselineTarget"] -is [pscustomobject]) {
    $baselineTarget = $resolvedProfile["baselineTarget"]
    $baselineMode = if (Test-ObjectProperty -Object $baselineTarget -Name "mode") {
        ([string]$baselineTarget.mode).Trim().ToLowerInvariant()
    }
    else {
        ""
    }
    if ([string]::IsNullOrWhiteSpace($baselineMode)) {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "baselineTarget" `
            -Kind "invalid-baseline-target" `
            -Reason "baselineTarget.mode is required" `
            -Resolution "supply-baseline-target-mode"
    }
    elseif ($action -eq "create" -and $baselineMode -ne "new-artifact") {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "baselineTarget" `
            -Kind "action-baseline-mismatch" `
            -Reason "create action requires baselineTarget.mode 'new-artifact'" `
            -Resolution "align-action-and-baseline-target"
    }
    elseif ($action -in @("revise", "baseline", "publish") -and
        $baselineMode -eq "new-artifact") {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "baselineTarget" `
            -Kind "action-baseline-mismatch" `
            -Reason "'$action' action cannot target a new artifact" `
            -Resolution "resolve-exact-existing-baseline"
    }

    if ($action -in @("revise", "baseline", "publish")) {
        $baselineTargetComplete = $true
        foreach ($targetProperty in @("artifactId", "version", "path", "sha256")) {
            if (-not (Test-ObjectProperty -Object $baselineTarget -Name $targetProperty) -or
                [string]::IsNullOrWhiteSpace([string]$baselineTarget.$targetProperty)) {
                $baselineTargetComplete = $false
                Add-BlockingResolutionConflict `
                    -ConflictList $conflicts `
                    -ReasonList $blockingReasons `
                    -Key "baselineTarget.$targetProperty" `
                    -Kind "incomplete-baseline-target" `
                    -Reason "baseline target is missing '$targetProperty'" `
                    -Resolution "resolve-authoritative-baseline"
            }
        }
        if ((Test-ObjectProperty -Object $baselineTarget -Name "sha256") -and
            [string]$baselineTarget.sha256 -cnotmatch "^[a-f0-9]{64}$") {
            $baselineTargetComplete = $false
            Add-BlockingResolutionConflict `
                -ConflictList $conflicts `
                -ReasonList $blockingReasons `
                -Key "baselineTarget.sha256" `
                -Kind "invalid-baseline-target" `
                -Reason "baselineTarget.sha256 is invalid" `
                -Resolution "resolve-authoritative-baseline"
        }

        if ($baselineTargetComplete) {
            $matchingAcceptedBaseline = @(
                $normalizedSources |
                    Where-Object {
                        $_.Layer -eq "accepted-baseline" -and
                        $null -ne $_.Authority -and
                        $_.Authority.artifactId -ceq [string]$baselineTarget.artifactId -and
                        $_.Authority.version -ceq [string]$baselineTarget.version -and
                        $_.Authority.path -ceq ([string]$baselineTarget.path).Replace("\", "/") -and
                        $_.Authority.sha256 -ceq ([string]$baselineTarget.sha256).ToLowerInvariant()
                    }
            )
            if ($matchingAcceptedBaseline.Count -eq 0) {
                Add-BlockingResolutionConflict `
                    -ConflictList $conflicts `
                    -ReasonList $blockingReasons `
                    -Key "baselineTarget" `
                    -Kind "unverified-baseline-target" `
                    -Reason "baseline target does not match a verified accepted-baseline source" `
                    -Resolution "run-authoritative-baseline-resolution"
            }
        }
    }
}

$hasFrontmatterSetting = $resolvedProfile.Contains("format.frontmatter")
$hasMetadataMode = $resolvedProfile.Contains("baseline.metadataMode")
if ($hasFrontmatterSetting -or $hasMetadataMode) {
    if (-not $hasFrontmatterSetting -or
        $resolvedProfile["format.frontmatter"] -isnot [bool] -or
        -not $hasMetadataMode -or
        $resolvedProfile["baseline.metadataMode"] -isnot [string]) {
        Add-BlockingResolutionConflict `
            -ConflictList $conflicts `
            -ReasonList $blockingReasons `
            -Key "baseline.metadataMode" `
            -Kind "metadata-mode-mismatch" `
            -Reason "format.frontmatter and baseline.metadataMode must be supplied together with boolean/string types" `
            -Resolution "align-artifact-and-baseline-metadata"
    }
    else {
        $expectedMetadataMode = if ([bool]$resolvedProfile["format.frontmatter"]) {
            "frontmatter"
        }
        else {
            "registry"
        }
        if (-not ([string]$resolvedProfile["baseline.metadataMode"]).Equals(
            $expectedMetadataMode,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            Add-BlockingResolutionConflict `
                -ConflictList $conflicts `
                -ReasonList $blockingReasons `
                -Key "baseline.metadataMode" `
                -Kind "metadata-mode-mismatch" `
                -Reason "format.frontmatter requires baseline.metadataMode '$expectedMetadataMode'" `
                -Resolution "align-artifact-and-baseline-metadata"
        }
    }
}

$resolvedQuestionIds = New-CaseInsensitiveSet -Values @()
foreach ($source in @($normalizedSources)) {
    if ($source.CanResolveQuestions) {
        foreach ($questionId in $source.ResolvesQuestions) {
            [void]$resolvedQuestionIds.Add($questionId)
        }
    }
}

$openQuestions = New-Object System.Collections.ArrayList
$seenQuestionIds = New-CaseInsensitiveSet -Values @()
foreach ($source in @(
    $normalizedSources |
        Sort-Object @{ Expression = { $_.Priority }; Descending = $true },
            @{ Expression = { $_.Id }; Descending = $false }
)) {
    foreach ($question in @($source.Questions)) {
        foreach ($requiredQuestionProperty in @("id", "text")) {
            if (-not (Test-ObjectProperty -Object $question -Name $requiredQuestionProperty)) {
                throw "Question in source '$($source.Id)' is missing '$requiredQuestionProperty'."
            }
        }
        $questionId = [string]$question.id
        if (-not $seenQuestionIds.Add($questionId)) {
            throw "Duplicate open question id '$questionId'."
        }

        $questionStatus = [string](
            Get-OptionalProperty -Object $question -Name "status" -Default "open"
        )
        $statusClaimsResolved = $questionStatus.ToLowerInvariant() -in @("resolved", "closed")
        $resolvingSources = @(
            $normalizedSources |
                Where-Object {
                    $_.CanResolveQuestions -and
                    $_.ResolvesQuestions.Contains($questionId)
                }
        )
        if ($statusClaimsResolved -and $resolvingSources.Count -eq 0) {
            throw "Question '$questionId' is marked '$questionStatus' without an authoritative resolvesQuestions declaration."
        }

        $affectsKeys = @(
            ConvertTo-StringArray -Value (
                Get-OptionalProperty -Object $question -Name "affectsKeys" -Default @()
            ) |
                Sort-Object -Unique
        )
        $resolutionBindingValid = $true
        if ($resolvingSources.Count -gt 0) {
            foreach ($affectedKey in $affectsKeys) {
                $hasAuthoritativeValue = @(
                    $resolvingSources |
                        Where-Object {
                            Test-ObjectProperty -Object $_.Values -Name $affectedKey
                        }
                ).Count -gt 0
                if (-not $hasAuthoritativeValue) {
                    throw "Question '$questionId' is declared resolved but no authoritative resolving source supplies affected key '$affectedKey'."
                }

                $selectedProvenance = @(
                    $provenance |
                        Where-Object { $_.key -ieq $affectedKey }
                )
                $selectedByResolver = $selectedProvenance.Count -eq 1 -and
                    @(
                        $resolvingSources |
                            Where-Object {
                                $_.Id -ieq [string]$selectedProvenance[0].sourceId
                            }
                    ).Count -gt 0
                if (-not $selectedByResolver) {
                    $resolutionBindingValid = $false
                    Add-BlockingResolutionConflict `
                        -ConflictList $conflicts `
                        -ReasonList $blockingReasons `
                        -Key $affectedKey `
                        -Kind "question-resolution-overridden" `
                        -Reason "resolved question '$questionId' is not bound to the selected value for '$affectedKey'" `
                        -Resolution "select-or-confirm-authoritative-resolution"
                }
            }
        }

        $isAlreadyResolved = $resolvedQuestionIds.Contains($questionId) -and
            $resolutionBindingValid
        if ($isAlreadyResolved) {
            continue
        }

        $isMaterialQuestion = Get-StrictBoolean `
            -Object $question `
            -Name "material" `
            -Default $false
        [void]$openQuestions.Add([pscustomobject][ordered]@{
            id = $questionId
            text = [string]$question.text
            sourceId = $source.Id
            material = $isMaterialQuestion
            affectsKeys = [object[]]$affectsKeys
            blocksWrite = $isMaterialQuestion
        })

        if ($isMaterialQuestion) {
            $blockingReasons.Add("unresolved material question '$questionId'")
            [void]$conflicts.Add([pscustomobject][ordered]@{
                key = if ($affectsKeys.Count -gt 0) { $affectsKeys -join "," } else { "*" }
                kind = "unresolved-material-question"
                severity = "material"
                selectedSource = $null
                otherSources = [object[]]@($source.Id)
                resolution = "resolve-question-with-authoritative-source"
            })
        }
        else {
            $confirmationReasons.Add("unresolved non-material question '$questionId'")
        }
    }
}

$blockingReasonArray = @($blockingReasons | Sort-Object -Unique)
$confirmationReasonArray = @($confirmationReasons | Sort-Object -Unique)
$writeState = if ($blockingReasonArray.Count -gt 0) {
    "blocked"
}
elseif ($confirmationReasonArray.Count -gt 0) {
    "confirmation-required"
}
else {
    "allowed"
}
$writeReasons = if ($writeState -eq "blocked") {
    $blockingReasonArray
}
else {
    $confirmationReasonArray
}
$requiredAction = switch ($writeState) {
    "blocked" { "resolve-material-conflicts-or-route-to-change" }
    "confirmation-required" { "preview-and-confirm-fingerprint" }
    default { "proceed-with-resolved-profile" }
}

$sortedProvenance = [object[]]@($provenance | Sort-Object key, sourceId)
$sortedConflicts = [object[]]@(
    $conflicts |
        Sort-Object key, kind, selectedSource, @{ Expression = { $_.otherSources -join "," } }
)
$sortedOpenQuestions = [object[]]@($openQuestions | Sort-Object id, sourceId)
$sortedBlockers = [object[]]@(
    $sortedConflicts |
        Where-Object { $_.severity -eq "material" } |
        ForEach-Object {
            [pscustomobject][ordered]@{
                key = $_.key
                kind = $_.kind
                selectedSource = $_.selectedSource
                otherSources = [object[]]$_.otherSources
                requiredAction = $_.resolution
            }
        } |
        Sort-Object key, kind, selectedSource
)
$generationContext = [ordered]@{
    outcome = if ($resolvedProfile.Contains("outcome")) {
        $resolvedProfile["outcome"]
    }
    else {
        $null
    }
    consumer = if ($resolvedProfile.Contains("consumer")) {
        $resolvedProfile["consumer"]
    }
    else {
        $null
    }
    deliverableMode = if ($resolvedProfile.Contains("deliverableMode")) {
        $resolvedProfile["deliverableMode"]
    }
    else {
        $null
    }
    sourceAuthority = if ($resolvedProfile.Contains("sourceAuthority")) {
        $resolvedProfile["sourceAuthority"]
    }
    else {
        $null
    }
    baselineTarget = if ($resolvedProfile.Contains("baselineTarget")) {
        $resolvedProfile["baselineTarget"]
    }
    else {
        $null
    }
    constraints = if ($resolvedProfile.Contains("constraints")) {
        $resolvedProfile["constraints"]
    }
    else {
        [pscustomobject]@{}
    }
    materialDecisions = if ($resolvedProfile.Contains("materialDecisions")) {
        $resolvedProfile["materialDecisions"]
    }
    else {
        [pscustomobject]@{}
    }
}
$disposition = [ordered]@{
    state = $writeState
    reasons = [object[]]$writeReasons
    requiredAction = $requiredAction
}

$fingerprintInput = [ordered]@{
    contractVersion = "1.0"
    project = [string]$request.project
    artifactType = [string]$request.artifactType
    action = $action
    changeAuthorized = $changeAuthorized
    changeEvidence = $changeEvidence
    generationContext = $generationContext
    resolvedProfile = $resolvedProfile
    provenance = $sortedProvenance
    conflicts = $sortedConflicts
    blockers = $sortedBlockers
    openQuestions = $sortedOpenQuestions
    writeDisposition = $disposition
}
$fingerprintValue = Get-CanonicalHash -Value $fingerprintInput

$result = [ordered]@{
    contractVersion = "1.0"
    project = [string]$request.project
    artifactType = [string]$request.artifactType
    action = $action
    generationContext = $generationContext
    resolvedProfile = $resolvedProfile
    provenance = $sortedProvenance
    conflicts = $sortedConflicts
    blockers = $sortedBlockers
    openQuestions = $sortedOpenQuestions
    fingerprint = [ordered]@{
        algorithm = "SHA-256"
        value = "sha256:$fingerprintValue"
    }
    writeDisposition = $disposition
}

$json = $result | ConvertTo-Json -Depth 100
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $outputFullPath = Resolve-RepoPath -Path $OutputPath -Purpose "Resolver output" -AllowMissing
    $outputDirectory = Split-Path -Parent $outputFullPath
    if (-not (Test-Path -LiteralPath $outputDirectory)) {
        throw "Resolver output directory does not exist: $(Get-RepoRelativePath -FullPath $outputDirectory)"
    }
    if (Test-Path -LiteralPath $outputFullPath) {
        throw "Refusing to overwrite an existing resolver output: $(Get-RepoRelativePath -FullPath $outputFullPath)"
    }
    [System.IO.File]::WriteAllText($outputFullPath, $json + [Environment]::NewLine, $Utf8NoBom)
}

Write-Output $json
