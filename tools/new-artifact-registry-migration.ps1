[CmdletBinding()]
param(
    [string]$WorkspaceRoot,
    [string]$DocsRoot = ".annifity/docs",
    [string]$EvidencePath,
    [string]$OutputPath,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "file-hash-compat.ps1")
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$AllowedLifecycles = @("draft", "reviewed", "baselined", "shipped", "superseded")
$ActiveLifecycles = @("baselined", "shipped")
$AllowedMetadataModes = @("frontmatter", "registry", "legacy-registry")
$AllowedTypes = @(
    "brd", "prd", "spec", "user-story", "uat", "decision", "changelog",
    "release-note", "session", "traceability", "roadmap", "risk"
)

function Test-Property {
    param($Object, [string]$Name)
    return $null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name]
}

function Get-RequiredText {
    param($Object, [string]$Name, [string]$Context)
    if (-not (Test-Property -Object $Object -Name $Name) -or
        [string]::IsNullOrWhiteSpace([string]$Object.$Name)) {
        throw "$Context is missing required '$Name'."
    }
    return ([string]$Object.$Name).Trim()
}

function Test-JsonArray {
    param($Value)
    return $null -ne $Value -and
        $Value -isnot [string] -and
        $Value -is [System.Collections.IEnumerable] -and
        $Value -isnot [System.Collections.IDictionary] -and
        $Value -isnot [pscustomobject]
}

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$Label,
        [switch]$RequireFile,
        [switch]$RequireDirectory
    )

    $normalized = $RepoPath.Replace("\", "/")
    if ([string]::IsNullOrWhiteSpace($normalized) -or
        [System.IO.Path]::IsPathRooted($normalized) -or
        $normalized -cne $normalized.Trim() -or
        $normalized.Contains("//") -or
        @($normalized.Split("/")) -contains "." -or
        @($normalized.Split("/")) -contains "..") {
        throw "$Label must be a canonical workspace-relative path: $RepoPath"
    }
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $script:Root $normalized))
    $rootPrefix = $script:Root.TrimEnd([char[]]"\/") +
        [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "$Label escapes the workspace: $RepoPath"
    }
    if ($RequireFile -and -not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "$Label does not exist: $RepoPath"
    }
    if ($RequireDirectory -and -not (Test-Path -LiteralPath $fullPath -PathType Container)) {
        throw "$Label is not a directory: $RepoPath"
    }
    return $fullPath
}

function ConvertTo-RepoPath {
    param([Parameter(Mandatory = $true)][string]$FullPath)
    return $FullPath.Substring($script:Root.Length).
        TrimStart([char[]]"\/").
        Replace("\", "/")
}

function Add-Diagnostic {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$List,
        [Parameter(Mandatory = $true)][string]$Code,
        [string]$ArtifactId = "",
        [string]$Path = "",
        [Parameter(Mandatory = $true)][string]$Message
    )
    $List.Add([pscustomobject][ordered]@{
        code = $Code
        artifactId = $ArtifactId
        path = $Path
        message = $Message
    }) | Out-Null
}

function Get-Frontmatter {
    param([Parameter(Mandatory = $true)][string]$Path)
    $content = [System.IO.File]::ReadAllText($Path, $Utf8NoBom).Replace("`r`n", "`n")
    $match = [regex]::Match(
        $content,
        "\A(?:\uFEFF)?---\n(?<yaml>.*?)\n---(?:\n|\z)",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    if (-not $match.Success) { return $null }
    $metadata = @{}
    foreach ($line in ($match.Groups["yaml"].Value -split "`n")) {
        if ($line -notmatch "^([A-Za-z0-9_-]+):\s*(.*?)\s*$") { continue }
        $value = $Matches[2].Trim()
        if ($value.Length -ge 2 -and
            (($value.StartsWith('"') -and $value.EndsWith('"')) -or
             ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        if (-not $metadata.ContainsKey($Matches[1])) {
            $metadata[$Matches[1]] = $value
        }
    }
    return $metadata
}

function Test-RecordMetadata {
    param(
        $Record,
        [string]$FullPath,
        [string]$RecordKey,
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Diagnostics
    )

    $mode = ([string]$Record.metadataMode).ToLowerInvariant()
    $metadata = Get-Frontmatter -Path $FullPath
    if ($mode -eq "frontmatter") {
        if ($null -eq $metadata) {
            Add-Diagnostic -List $Diagnostics -Code "FRONTMATTER_MISSING" `
                -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                -Message "Selected frontmatter record '$RecordKey' has no frontmatter."
            return
        }
        if (-not $metadata.ContainsKey("title") -or
            [string]::IsNullOrWhiteSpace([string]$metadata["title"])) {
            Add-Diagnostic -List $Diagnostics -Code "FRONTMATTER_MISMATCH" `
                -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                -Message "Frontmatter 'title' is required for selected record '$RecordKey'."
        }
        $expected = [ordered]@{
            artifact_id = [string]$Record.artifactId
            version = [string]$Record.version
            type = ([string]$Record.artifactType).ToLowerInvariant()
            updated = [string]$Record.documentUpdated
            source = [string]$Record.documentSource
        }
        foreach ($name in $expected.Keys) {
            if (-not $metadata.ContainsKey($name) -or
                [string]$metadata[$name] -cne [string]$expected[$name]) {
                Add-Diagnostic -List $Diagnostics -Code "FRONTMATTER_MISMATCH" `
                    -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                -Message "Frontmatter '$name' does not match selected record '$RecordKey'."
            }
        }
        $expectedLifecycle = ([string]$Record.lifecycle).ToLowerInvariant()
        $documentStatus = if ($metadata.ContainsKey("status")) {
            ([string]$metadata["status"]).ToLowerInvariant()
        }
        else {
            ""
        }
        if ([string]::IsNullOrWhiteSpace($documentStatus) -or
            ($documentStatus -cne $expectedLifecycle -and
                -not ($expectedLifecycle -eq "superseded" -and
                    @("baselined", "shipped") -contains $documentStatus))) {
            Add-Diagnostic -List $Diagnostics -Code "FRONTMATTER_MISMATCH" `
                -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                -Message "Frontmatter 'status' is missing or incompatible with selected record '$RecordKey'."
        }
        if (([string]$Record.artifactType).ToLowerInvariant() -eq "decision") {
            $expectedDecisionStatus = Get-RequiredText `
                -Object $Record `
                -Name "decisionStatus" `
                -Context "Decision record '$RecordKey'"
            if (-not $metadata.ContainsKey("decision_status") -or
                [string]$metadata["decision_status"] -cne $expectedDecisionStatus) {
                Add-Diagnostic -List $Diagnostics -Code "FRONTMATTER_MISMATCH" `
                    -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                    -Message "Frontmatter 'decision_status' does not match selected record '$RecordKey'."
            }
        }
    }
    elseif ($mode -eq "registry" -and $null -ne $metadata) {
        Add-Diagnostic -List $Diagnostics -Code "REGISTRY_MODE_FRONTMATTER_PRESENT" `
            -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
            -Message "Registry metadata mode forbids embedded frontmatter."
    }
    elseif ($mode -eq "legacy-registry") {
        if ($null -eq $metadata) {
            Add-Diagnostic -List $Diagnostics -Code "LEGACY_FRONTMATTER_MISSING" `
                -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                -Message "Migration-only legacy-registry mode requires an existing legacy frontmatter block."
        }
        else {
            $comparisons = [ordered]@{
                artifact_id = [string]$Record.artifactId
                version = [string]$Record.version
                type = ([string]$Record.artifactType).ToLowerInvariant()
                updated = [string]$Record.documentUpdated
                source = [string]$Record.documentSource
            }
            foreach ($name in $comparisons.Keys) {
                if ($metadata.ContainsKey($name) -and
                    -not [string]::IsNullOrWhiteSpace([string]$metadata[$name]) -and
                    [string]$metadata[$name] -cne [string]$comparisons[$name]) {
                    Add-Diagnostic -List $Diagnostics -Code "LEGACY_METADATA_CONFLICT" `
                        -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                        -Message "Legacy frontmatter '$name' conflicts with selected record '$RecordKey'."
                }
            }
            if ($metadata.ContainsKey("status") -and
                -not [string]::IsNullOrWhiteSpace([string]$metadata["status"])) {
                $legacyStatus = ([string]$metadata["status"]).ToLowerInvariant()
                $lifecycle = ([string]$Record.lifecycle).ToLowerInvariant()
                if ($legacyStatus -cne $lifecycle -and
                    -not ($lifecycle -eq "superseded" -and
                        @("baselined", "shipped") -contains $legacyStatus)) {
                    Add-Diagnostic -List $Diagnostics -Code "LEGACY_METADATA_CONFLICT" `
                        -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                    -Message "Legacy status '$legacyStatus' conflicts with lifecycle '$lifecycle'."
                }
            }
            if (([string]$Record.artifactType).ToLowerInvariant() -eq "decision") {
                $expectedDecisionStatus = Get-RequiredText `
                    -Object $Record `
                    -Name "decisionStatus" `
                    -Context "Decision record '$RecordKey'"
                if ($metadata.ContainsKey("decision_status") -and
                    -not [string]::IsNullOrWhiteSpace([string]$metadata["decision_status"]) -and
                    [string]$metadata["decision_status"] -cne $expectedDecisionStatus) {
                    Add-Diagnostic -List $Diagnostics -Code "LEGACY_METADATA_CONFLICT" `
                        -ArtifactId ([string]$Record.artifactId) -Path ([string]$Record.path) `
                        -Message "Legacy decision_status conflicts with selected record '$RecordKey'."
                }
            }
        }
    }
}

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $script:Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
else {
    $script:Root = [System.IO.Path]::GetFullPath(
        $(if ([System.IO.Path]::IsPathRooted($WorkspaceRoot)) {
            $WorkspaceRoot
        } else {
            Join-Path (Get-Location).Path $WorkspaceRoot
        })
    ).TrimEnd([char[]]"\/")
}
if (-not (Test-Path -LiteralPath $script:Root -PathType Container)) {
    throw "Workspace root does not exist: $WorkspaceRoot"
}

$docsFullPath = Resolve-RepoPath -RepoPath $DocsRoot -Label "Docs root" -RequireDirectory
$docsRepoPath = ConvertTo-RepoPath -FullPath $docsFullPath
$allFiles = @(
    Get-ChildItem -LiteralPath $docsFullPath -Recurse -File |
        Sort-Object FullName
)
$markdownPaths = @(
    $allFiles |
        Where-Object { $_.Extension -ieq ".md" } |
        ForEach-Object { ConvertTo-RepoPath -FullPath $_.FullName }
)

$diagnostics = [System.Collections.Generic.List[object]]::new()
$evidence = $null
$records = @()
$pointers = @()
$registryUpdated = ""
$registrySource = ""
if (-not [string]::IsNullOrWhiteSpace($EvidencePath)) {
    $evidenceFullPath = Resolve-RepoPath `
        -RepoPath $EvidencePath `
        -Label "Evidence manifest" `
        -RequireFile
    try {
        $evidence = [System.IO.File]::ReadAllText($evidenceFullPath, $Utf8NoBom) |
            ConvertFrom-Json
    }
    catch {
        throw "Evidence manifest is not valid JSON: $($_.Exception.Message)"
    }
    if ((Get-RequiredText -Object $evidence -Name "schemaVersion" -Context "Evidence manifest") -cne "1.0") {
        throw "Evidence manifest schemaVersion must be '1.0'."
    }
    if ((Get-RequiredText -Object $evidence -Name "status" -Context "Evidence manifest") -cne "accepted") {
        throw "Evidence manifest status must be 'accepted'."
    }
    $registryUpdated = Get-RequiredText -Object $evidence -Name "updated" -Context "Evidence manifest"
    if ($registryUpdated -cnotmatch "^\d{4}-\d{2}-\d{2}$") {
        throw "Evidence manifest updated must use YYYY-MM-DD."
    }
    $registrySource = Get-RequiredText -Object $evidence -Name "source" -Context "Evidence manifest"
    if (-not (Test-Property -Object $evidence -Name "records") -or
        -not (Test-JsonArray -Value $evidence.records)) {
        throw "Evidence manifest records must be a JSON array."
    }
    if (-not (Test-Property -Object $evidence -Name "pointers") -or
        -not (Test-JsonArray -Value $evidence.pointers)) {
        throw "Evidence manifest pointers must be a JSON array."
    }
    $records = @($evidence.records)
    $pointers = @($evidence.pointers)
}

$artifactIds = @(
    @($records | ForEach-Object { [string]$_.artifactId }) +
    @($pointers | ForEach-Object { [string]$_.artifactId }) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -CaseSensitive -Unique
)
$validRecords = [System.Collections.Generic.List[object]]::new()
$validPointers = [System.Collections.Generic.List[object]]::new()
$blockedArtifacts = [System.Collections.Generic.List[string]]::new()
$selectedPaths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
$globalRecordKeys = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)
$globalPaths = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::Ordinal
)

foreach ($artifactId in $artifactIds) {
    $beforeCount = $diagnostics.Count
    $groupRecords = @($records | Where-Object { [string]$_.artifactId -ceq $artifactId })
    $groupPointers = @($pointers | Where-Object { [string]$_.artifactId -ceq $artifactId })
    $recordMap = [System.Collections.Generic.Dictionary[string,object]]::new(
        [System.StringComparer]::Ordinal
    )

    if ($artifactId.Contains("@")) {
        Add-Diagnostic -List $diagnostics -Code "ARTIFACT_ID_INVALID" `
            -ArtifactId $artifactId -Message "artifactId must not contain '@'."
    }

    if ($groupRecords.Count -eq 0) {
        Add-Diagnostic -List $diagnostics -Code "RECORDS_MISSING" `
            -ArtifactId $artifactId -Message "Selected artifact has no records."
    }
    if ($groupPointers.Count -ne 1) {
        Add-Diagnostic -List $diagnostics -Code "POINTER_COUNT_INVALID" `
            -ArtifactId $artifactId -Message "Selected artifact must have exactly one pointer."
    }

    foreach ($record in $groupRecords) {
        try {
            $version = Get-RequiredText -Object $record -Name "version" -Context "Record '$artifactId'"
            $path = (Get-RequiredText -Object $record -Name "path" -Context "Record '$artifactId'").Replace("\", "/")
            $lifecycle = (Get-RequiredText -Object $record -Name "lifecycle" -Context "Record '$artifactId'").ToLowerInvariant()
            $metadataMode = (Get-RequiredText -Object $record -Name "metadataMode" -Context "Record '$artifactId'").ToLowerInvariant()
            $artifactType = (Get-RequiredText -Object $record -Name "artifactType" -Context "Record '$artifactId'").ToLowerInvariant()
            $documentUpdated = Get-RequiredText -Object $record -Name "documentUpdated" -Context "Record '$artifactId'"
            [void](Get-RequiredText -Object $record -Name "documentSource" -Context "Record '$artifactId'")
            $sha256 = Get-RequiredText -Object $record -Name "sha256" -Context "Record '$artifactId'"
            if (-not (Test-Property -Object $record -Name "supersedes") -or
                -not (Test-JsonArray -Value $record.supersedes)) {
                throw "Record '$artifactId@$version' supersedes must be an array."
            }
            $recordKey = "$artifactId@$version"
            if (-not $globalRecordKeys.Add($recordKey)) {
                Add-Diagnostic -List $diagnostics -Code "DUPLICATE_RECORD" `
                    -ArtifactId $artifactId -Path $path -Message "Duplicate record '$recordKey'."
            }
            if (-not $globalPaths.Add($path)) {
                Add-Diagnostic -List $diagnostics -Code "DUPLICATE_PATH" `
                    -ArtifactId $artifactId -Path $path -Message "Selected path is registered more than once."
            }
            if ($lifecycle -notin $AllowedLifecycles) {
                Add-Diagnostic -List $diagnostics -Code "LIFECYCLE_INVALID" `
                    -ArtifactId $artifactId -Path $path -Message "Unsupported lifecycle '$lifecycle'."
            }
            if ($metadataMode -notin $AllowedMetadataModes) {
                Add-Diagnostic -List $diagnostics -Code "METADATA_MODE_INVALID" `
                    -ArtifactId $artifactId -Path $path -Message "Unsupported metadataMode '$metadataMode'."
            }
            if ($artifactType -notin $AllowedTypes) {
                Add-Diagnostic -List $diagnostics -Code "ARTIFACT_TYPE_INVALID" `
                    -ArtifactId $artifactId -Path $path -Message "Unsupported artifactType '$artifactType'."
            }
            if ($artifactType -eq "decision") {
                $decisionStatus = Get-RequiredText `
                    -Object $record `
                    -Name "decisionStatus" `
                    -Context "Decision record '$recordKey'"
                if ($decisionStatus -notin @(
                    "proposed",
                    "accepted",
                    "rejected",
                    "withdrawn"
                )) {
                    Add-Diagnostic -List $diagnostics -Code "DECISION_STATUS_INVALID" `
                        -ArtifactId $artifactId -Path $path -Message "Unsupported decisionStatus '$decisionStatus'."
                }
            }
            if ($documentUpdated -cnotmatch "^\d{4}-\d{2}-\d{2}$") {
                Add-Diagnostic -List $diagnostics -Code "DOCUMENT_DATE_INVALID" `
                    -ArtifactId $artifactId -Path $path -Message "documentUpdated must use YYYY-MM-DD."
            }
            if ($sha256 -cnotmatch "^[a-f0-9]{64}$") {
                Add-Diagnostic -List $diagnostics -Code "HASH_INVALID" `
                    -ArtifactId $artifactId -Path $path -Message "Record SHA-256 is invalid."
            }
            $fullPath = Resolve-RepoPath -RepoPath $path -Label "Selected record" -RequireFile
            $docsPrefix = $docsFullPath.TrimEnd([char[]]"\/") +
                [System.IO.Path]::DirectorySeparatorChar
            if (-not $fullPath.StartsWith(
                $docsPrefix,
                [System.StringComparison]::OrdinalIgnoreCase
            )) {
                Add-Diagnostic -List $diagnostics -Code "PATH_OUTSIDE_DOCS" `
                    -ArtifactId $artifactId -Path $path -Message "Selected record is outside the docs root."
            }
            elseif ([System.IO.Path]::GetExtension($fullPath) -ine ".md") {
                Add-Diagnostic -List $diagnostics -Code "PATH_NOT_MARKDOWN" `
                    -ArtifactId $artifactId -Path $path -Message "Selected record must be Markdown."
            }
            [void]$selectedPaths.Add($path)
            $actualSha = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).
                Hash.
                ToLowerInvariant()
            if ($sha256 -cne $actualSha) {
                Add-Diagnostic -List $diagnostics -Code "HASH_MISMATCH" `
                    -ArtifactId $artifactId -Path $path -Message "Selected hash does not match exact file bytes."
            }
            Test-RecordMetadata `
                -Record $record `
                -FullPath $fullPath `
                -RecordKey $recordKey `
                -Diagnostics $diagnostics
            $recordMap[$recordKey] = $record
        }
        catch {
            Add-Diagnostic -List $diagnostics -Code "RECORD_INVALID" `
                -ArtifactId $artifactId -Message $_.Exception.Message
        }
    }

    $active = @(
        $groupRecords |
            Where-Object { ([string]$_.lifecycle).ToLowerInvariant() -in $ActiveLifecycles }
    )
    if ($active.Count -ne 1) {
        Add-Diagnostic -List $diagnostics -Code "ACTIVE_BASELINE_COUNT_INVALID" `
            -ArtifactId $artifactId -Message "Selected artifact must have exactly one active baseline."
    }

    if ($groupPointers.Count -eq 1) {
        $pointer = $groupPointers[0]
        foreach ($prefix in @("baseline", "latest")) {
            try {
                $pointerVersion = Get-RequiredText -Object $pointer -Name "${prefix}Version" -Context "Pointer '$artifactId'"
                $pointerPath = Get-RequiredText -Object $pointer -Name "${prefix}Path" -Context "Pointer '$artifactId'"
                $pointerSha = Get-RequiredText -Object $pointer -Name "${prefix}Sha256" -Context "Pointer '$artifactId'"
                $pointerKey = "$artifactId@$pointerVersion"
                if (-not $recordMap.ContainsKey($pointerKey)) {
                    Add-Diagnostic -List $diagnostics -Code "POINTER_RECORD_MISSING" `
                        -ArtifactId $artifactId -Path $pointerPath -Message "$prefix pointer record is missing."
                }
                else {
                    $target = $recordMap[$pointerKey]
                    if ([string]$target.path -cne $pointerPath -or
                        [string]$target.sha256 -cne $pointerSha) {
                        Add-Diagnostic -List $diagnostics -Code "POINTER_TRIPLE_MISMATCH" `
                            -ArtifactId $artifactId -Path $pointerPath -Message "$prefix pointer triple does not match its record."
                    }
                    if ($prefix -eq "baseline" -and
                        ([string]$target.lifecycle).ToLowerInvariant() -notin $ActiveLifecycles) {
                        Add-Diagnostic -List $diagnostics -Code "POINTER_BASELINE_INACTIVE" `
                            -ArtifactId $artifactId -Path $pointerPath -Message "Baseline pointer does not target an active baseline."
                    }
                    if ($prefix -eq "latest" -and
                        ([string]$target.lifecycle).ToLowerInvariant() -eq "superseded") {
                        Add-Diagnostic -List $diagnostics -Code "POINTER_LATEST_SUPERSEDED" `
                            -ArtifactId $artifactId -Path $pointerPath -Message "Latest pointer targets a superseded record."
                    }
                }
            }
            catch {
                Add-Diagnostic -List $diagnostics -Code "POINTER_INVALID" `
                    -ArtifactId $artifactId -Message $_.Exception.Message
            }
        }
        try {
            [void](Get-RequiredText -Object $pointer -Name "source" -Context "Pointer '$artifactId'")
        }
        catch {
            Add-Diagnostic -List $diagnostics -Code "POINTER_INVALID" `
                -ArtifactId $artifactId -Message $_.Exception.Message
        }
    }

    $incoming = [System.Collections.Generic.Dictionary[
        string,
        System.Collections.Generic.List[string]
    ]]::new([System.StringComparer]::Ordinal)
    foreach ($record in $groupRecords) {
        $recordKey = "$artifactId@$([string]$record.version)"
        foreach ($predecessor in @($record.supersedes)) {
            if ($predecessor -isnot [string] -or
                [string]::IsNullOrWhiteSpace([string]$predecessor)) {
                Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_INVALID" `
                    -ArtifactId $artifactId -Message "Record '$recordKey' has a non-string or empty predecessor."
                continue
            }
            $predecessorKey = ([string]$predecessor).Trim()
            if ($predecessorKey -ceq $recordKey -or
                -not $recordMap.ContainsKey($predecessorKey) -or
                -not $predecessorKey.StartsWith(
                    "$artifactId@",
                    [System.StringComparison]::Ordinal
                )) {
                Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_INVALID" `
                    -ArtifactId $artifactId -Message "Record '$recordKey' has invalid predecessor '$predecessorKey'."
                continue
            }

            $recordLifecycle = ([string]$record.lifecycle).ToLowerInvariant()
            $predecessorLifecycle = (
                [string]$recordMap[$predecessorKey].lifecycle
            ).ToLowerInvariant()
            if ($recordLifecycle -notin @("baselined", "shipped", "superseded")) {
                Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_STATE_INVALID" `
                    -ArtifactId $artifactId -Message "Record '$recordKey' is not currently or historically accepted."
            }
            if ($predecessorLifecycle -cne "superseded") {
                Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_STATE_INVALID" `
                    -ArtifactId $artifactId -Message "Predecessor '$predecessorKey' must be marked superseded."
            }
            if (-not $incoming.ContainsKey($predecessorKey)) {
                $incoming[$predecessorKey] = [System.Collections.Generic.List[string]]::new()
            }
            $incoming[$predecessorKey].Add($recordKey) | Out-Null
        }
    }

    foreach ($predecessorKey in @($incoming.Keys | Sort-Object)) {
        if ($incoming[$predecessorKey].Count -gt 1) {
            Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_AMBIGUOUS" `
                -ArtifactId $artifactId -Message "Predecessor '$predecessorKey' has competing successors."
        }
    }
    foreach ($record in $groupRecords) {
        $recordKey = "$artifactId@$([string]$record.version)"
        if (([string]$record.lifecycle).ToLowerInvariant() -eq "superseded" -and
            (-not $incoming.ContainsKey($recordKey) -or
                $incoming[$recordKey].Count -ne 1)) {
            Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_ORPHAN" `
                -ArtifactId $artifactId -Message "Superseded record '$recordKey' must have exactly one successor."
        }
    }

    $visitState = [System.Collections.Generic.Dictionary[string,int]]::new(
        [System.StringComparer]::Ordinal
    )
    $cycleNodes = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    $visitNode = $null
    $visitNode = {
        param([string]$Key)
        if ($visitState.ContainsKey($Key)) {
            if ($visitState[$Key] -eq 1 -and $cycleNodes.Add($Key)) {
                Add-Diagnostic -List $diagnostics -Code "SUPERSESSION_CYCLE" `
                    -ArtifactId $artifactId -Message "Supersession graph contains a cycle at '$Key'."
            }
            return
        }
        $visitState[$Key] = 1
        foreach ($predecessor in @($recordMap[$Key].supersedes)) {
            if ($predecessor -is [string]) {
                $predecessorKey = ([string]$predecessor).Trim()
                if ($recordMap.ContainsKey($predecessorKey)) {
                    & $visitNode $predecessorKey
                }
            }
        }
        $visitState[$Key] = 2
    }
    foreach ($recordKey in @($recordMap.Keys | Sort-Object)) {
        & $visitNode $recordKey
    }

    if ($diagnostics.Count -eq $beforeCount) {
        foreach ($record in $groupRecords) { $validRecords.Add($record) | Out-Null }
        if ($groupPointers.Count -eq 1) { $validPointers.Add($groupPointers[0]) | Out-Null }
    }
    else {
        $blockedArtifacts.Add($artifactId) | Out-Null
    }
}

$validRecordArray = @(
    $validRecords |
        Sort-Object `
            @{ Expression = { [string]$_.artifactId } },
            @{ Expression = { [string]$_.version } },
            @{ Expression = { [string]$_.path } }
)
$validPointerArray = @(
    $validPointers |
        Sort-Object @{ Expression = { [string]$_.artifactId } }
)
$unselectedPaths = @(
    $markdownPaths |
        Where-Object { -not $selectedPaths.Contains($_) } |
        Sort-Object
)
$proposedRegistry = if ($validPointerArray.Count -gt 0) {
    [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        updated = $registryUpdated
        source = $registrySource
        records = $validRecordArray
        pointers = $validPointerArray
    }
}
else {
    $null
}
$sortedDiagnostics = @(
    $diagnostics |
        Sort-Object code, artifactId, path, message
)
$result = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    status = if ($null -eq $proposedRegistry) {
        "blocked"
    } elseif ($blockedArtifacts.Count -gt 0) {
        "partial"
    } else {
        "candidate"
    }
    docsRoot = $docsRepoPath
    evidenceSource = if ($null -eq $evidence) { $null } else { $registrySource }
    summary = [pscustomobject][ordered]@{
        inventoryFiles = $allFiles.Count
        markdownCandidates = $markdownPaths.Count
        resolvableArtifacts = $validPointerArray.Count
        blockedSelectedArtifacts = @(
            $blockedArtifacts |
                Sort-Object -CaseSensitive -Unique
        ).Count
        blockedInventoryFiles = $unselectedPaths.Count
        proposedRegistryEmitted = $null -ne $proposedRegistry
    }
    blockedInventory = $unselectedPaths
    diagnostics = $sortedDiagnostics
    proposedRegistry = $proposedRegistry
}

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    if ($null -eq $proposedRegistry) {
        throw "No valid registry candidate is available to write."
    }
    $outputFullPath = Resolve-RepoPath -RepoPath $OutputPath -Label "Candidate output"
    $docsPrefix = $docsFullPath.TrimEnd([char[]]"\/") +
        [System.IO.Path]::DirectorySeparatorChar
    if ($outputFullPath.Equals(
        $docsFullPath,
        [System.StringComparison]::OrdinalIgnoreCase
    ) -or $outputFullPath.StartsWith(
        $docsPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Candidate output must stay outside the live docs root."
    }
    if (Test-Path -LiteralPath $outputFullPath) {
        throw "Refusing to overwrite candidate output: $OutputPath"
    }
    $outputParent = [System.IO.Path]::GetDirectoryName($outputFullPath)
    if (-not (Test-Path -LiteralPath $outputParent -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $outputParent)
    }
    $candidateJson = (
        ($proposedRegistry | ConvertTo-Json -Depth 100) -replace "`r`n", "`n"
    ) + "`n"
    [System.IO.File]::WriteAllText($outputFullPath, $candidateJson, $Utf8NoBom)
}

$resultJson = (($result | ConvertTo-Json -Depth 100) -replace "`r`n", "`n") + "`n"
if ($AsJson) {
    Write-Output $resultJson.TrimEnd()
}
else {
    Write-Output "$($result.status.ToUpperInvariant()) artifact registry migration"
    Write-Output "Resolvable artifacts: $($result.summary.resolvableArtifacts)"
    Write-Output "Blocked selected artifacts: $($result.summary.blockedSelectedArtifacts)"
    Write-Output "Unselected Markdown files: $($result.summary.blockedInventoryFiles)"
}
if ($null -eq $proposedRegistry) { exit 2 }
exit 0
