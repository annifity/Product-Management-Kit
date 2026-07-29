[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ArtifactId,

    [string]$WorkspaceRoot,

    [string]$RegistryPath = ".annifity/docs/artifact-state-registry.json",

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:Diagnostics = New-Object System.Collections.Generic.List[object]
$AllowedLifecycles = @("draft", "reviewed", "baselined", "shipped", "superseded")
$ActiveBaselineStates = @("baselined", "shipped")
$AllowedTypes = @(
    "brd", "prd", "spec", "user-story", "uat", "decision", "changelog",
    "release-note", "session", "traceability", "roadmap", "risk"
)

function Add-Diagnostic {
    param(
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Path = "",
        [string]$RecordKey = ""
    )

    $script:Diagnostics.Add([pscustomobject][ordered]@{
        code = $Code
        message = $Message
        path = $Path
        recordKey = $RecordKey
    }) | Out-Null
}

trap {
    Add-Diagnostic `
        -Code "RESOLVER_UNEXPECTED_ERROR" `
        -Message "The resolver encountered an unexpected filesystem or parser error." `
        -Path ([string]$RegistryPath) `
        -RecordKey ([string]$ArtifactId)
    $failureDiagnostics = @(
        $script:Diagnostics |
            Sort-Object code, path, recordKey, message -Unique
    )
    $failureResult = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        verdict = "blocked"
        artifactId = $ArtifactId
        baseline = $null
        latest = $null
        provenance = @()
        diagnostics = @($failureDiagnostics)
    }
    if ($AsJson) {
        $failureResult | ConvertTo-Json -Depth 12
    }
    else {
        Write-Output "BLOCKED $ArtifactId"
        foreach ($diagnostic in $failureDiagnostics) {
            Write-Output "[$($diagnostic.code)] $($diagnostic.message)"
        }
    }
    exit 2
}

function Get-ObjectProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($null -eq $Object) { return $null }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Test-ObjectProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    return $null -ne $Object -and $null -ne $Object.PSObject.Properties[$Name]
}

function Test-JsonArray {
    param([AllowNull()]$Value)
    return $null -ne $Value -and $Value -is [System.Array]
}

function Test-JsonObject {
    param([AllowNull()]$Value)
    return $null -ne $Value -and $Value -is [pscustomobject]
}

function Get-RequiredText {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$Path = "",
        [string]$RecordKey = ""
    )

    $value = Get-ObjectProperty -Object $Object -Name $Name
    if ($null -eq $value -or
        $value -isnot [string] -or
        [string]::IsNullOrWhiteSpace([string]$value)) {
        Add-Diagnostic -Code $Code -Message "$Context is missing required '$Name'." -Path $Path -RecordKey $RecordKey
        return ""
    }
    return ([string]$value).Trim()
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Replace("\", "/").TrimStart("/")
}

function ConvertTo-RepoPath {
    param(
        [Parameter(Mandatory = $true)][string]$FullPath,
        [Parameter(Mandatory = $true)][string]$Root
    )

    $normalizedRoot = $Root.TrimEnd([char[]]"\/")
    if ($FullPath.Equals($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "."
    }
    return $FullPath.Substring($normalizedRoot.Length).TrimStart([char[]]"\/").Replace("\", "/")
}

function Resolve-RegisteredPath {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Context,
        [string]$RecordKey = "",
        [string]$InvalidPathCode = "INVALID_REGISTERED_PATH"
    )

    if ([string]::IsNullOrWhiteSpace($RepoPath)) { return $null }
    if ($RepoPath -cne $RepoPath.Trim() -or
        $RepoPath.Contains("\") -or
        $RepoPath.Contains("//") -or
        $RepoPath.EndsWith("/")) {
        Add-Diagnostic -Code $InvalidPathCode -Message "$Context path must use one canonical workspace-relative spelling." -Path $RepoPath -RecordKey $RecordKey
        return $null
    }

    $segments = @($RepoPath.Split([char]"/"))
    foreach ($segment in $segments) {
        if ([string]::IsNullOrEmpty($segment) -or
            $segment -ceq "." -or
            $segment -ceq ".." -or
            $segment.EndsWith(".") -or
            $segment.EndsWith(" ") -or
            $segment.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ge 0) {
            Add-Diagnostic -Code $InvalidPathCode -Message "$Context path contains a rooted, dot-segment, or non-canonical component." -Path $RepoPath -RecordKey $RecordKey
            return $null
        }
    }

    try {
        if ([System.IO.Path]::IsPathRooted($RepoPath)) {
            Add-Diagnostic -Code $InvalidPathCode -Message "$Context path must be workspace-relative." -Path $RepoPath -RecordKey $RecordKey
            return $null
        }
        $normalizedRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]"\/")
        $candidate = [System.IO.Path]::GetFullPath((Join-Path $normalizedRoot $RepoPath))
    }
    catch [System.ArgumentException] {
        Add-Diagnostic -Code $InvalidPathCode -Message "$Context path is not a valid canonical workspace-relative path." -Path $RepoPath -RecordKey $RecordKey
        return $null
    }
    catch [System.NotSupportedException] {
        Add-Diagnostic -Code $InvalidPathCode -Message "$Context path is not a valid canonical workspace-relative path." -Path $RepoPath -RecordKey $RecordKey
        return $null
    }

    $rootPrefix = $normalizedRoot + [System.IO.Path]::DirectorySeparatorChar
    $insideRoot = $candidate.Equals($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
        $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)

    if (-not $insideRoot) {
        Add-Diagnostic -Code $InvalidPathCode -Message "$Context path escapes the workspace root." -Path $RepoPath -RecordKey $RecordKey
        return $null
    }

    $roundTripPath = ConvertTo-RepoPath -FullPath $candidate -Root $normalizedRoot
    if ($roundTripPath -cne $RepoPath) {
        Add-Diagnostic -Code $InvalidPathCode -Message "$Context path is an alias of a different canonical workspace path." -Path $RepoPath -RecordKey $RecordKey
        return $null
    }

    $currentPath = $normalizedRoot
    if (Test-Path -LiteralPath $currentPath) {
        $rootItem = Get-Item -Force -LiteralPath $currentPath
        if (($rootItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            Add-Diagnostic -Code "REPARSE_PATH_REJECTED" -Message "$Context path traverses a symbolic link or reparse point." -Path $RepoPath -RecordKey $RecordKey
            return $null
        }
    }
    $missingAncestor = $false
    foreach ($segment in $segments) {
        $parentPath = $currentPath
        $currentPath = Join-Path $currentPath $segment
        if (-not $missingAncestor -and (Test-Path -LiteralPath $currentPath)) {
            $canonicalItems = @(
                Get-ChildItem -Force -LiteralPath $parentPath |
                    Where-Object {
                        $_.Name.Equals(
                            $segment,
                            [System.StringComparison]::OrdinalIgnoreCase
                        )
                    }
            )
            if ($canonicalItems.Count -ne 1 -or $canonicalItems[0].Name -cne $segment) {
                Add-Diagnostic -Code $InvalidPathCode -Message "$Context path is an alias of a differently-cased or canonical filesystem path." -Path $RepoPath -RecordKey $RecordKey
                return $null
            }
            $item = $canonicalItems[0]
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                Add-Diagnostic -Code "REPARSE_PATH_REJECTED" -Message "$Context path traverses a symbolic link or reparse point." -Path $RepoPath -RecordKey $RecordKey
                return $null
            }
        }
        else {
            $missingAncestor = $true
        }
    }
    return $candidate
}

function Get-DocumentSnapshot {
    param(
        [Parameter(Mandatory = $true)][string]$FullPath,
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$RecordKey
    )

    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
        Add-Diagnostic -Code "DOCUMENT_NOT_FOUND" -Message "Registered document does not exist." -Path $RepoPath -RecordKey $RecordKey
        return $null
    }

    $bytes = [System.IO.File]::ReadAllBytes($FullPath)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha256.ComputeHash($bytes)
    }
    finally {
        $sha256.Dispose()
    }
    $actualSha256 = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLowerInvariant()

    $stream = [System.IO.MemoryStream]::new($bytes, $false)
    $reader = [System.IO.StreamReader]::new(
        $stream,
        [System.Text.UTF8Encoding]::new($false, $true),
        $true
    )
    try {
        $content = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
        $stream.Dispose()
    }

    return [pscustomobject]@{
        content = $content
        sha256 = $actualSha256
    }
}

function ConvertFrom-FrontmatterScalar {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)

    $inSingleQuote = $false
    $inDoubleQuote = $false
    $escaped = $false
    $commentIndex = -1
    for ($index = 0; $index -lt $Value.Length; $index++) {
        $character = $Value[$index]
        if ($inDoubleQuote) {
            if ($escaped) {
                $escaped = $false
            }
            elseif ($character -eq "\") {
                $escaped = $true
            }
            elseif ($character -eq '"') {
                $inDoubleQuote = $false
            }
            continue
        }
        if ($inSingleQuote) {
            if ($character -eq "'") {
                if ($index + 1 -lt $Value.Length -and $Value[$index + 1] -eq "'") {
                    $index++
                }
                else {
                    $inSingleQuote = $false
                }
            }
            continue
        }
        if ($character -eq '"') {
            $inDoubleQuote = $true
            continue
        }
        if ($character -eq "'") {
            $inSingleQuote = $true
            continue
        }
        if ($character -eq "#" -and
            ($index -eq 0 -or [char]::IsWhiteSpace($Value[$index - 1]))) {
            $commentIndex = $index
            break
        }
    }

    $scalar = if ($commentIndex -ge 0) {
        $Value.Substring(0, $commentIndex).Trim()
    }
    else {
        $Value.Trim()
    }
    if ([string]::IsNullOrEmpty($scalar)) {
        return $null
    }
    if ($scalar.Length -ge 2 -and $scalar.StartsWith('"') -and $scalar.EndsWith('"')) {
        return $scalar.Substring(1, $scalar.Length - 2)
    }
    if ($scalar.Length -ge 2 -and $scalar.StartsWith("'") -and $scalar.EndsWith("'")) {
        return $scalar.Substring(1, $scalar.Length - 2).Replace("''", "'")
    }
    if ($scalar -cmatch "^(?:null|Null|NULL|~)$") {
        return $null
    }
    return $scalar
}

function Get-Frontmatter {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content,
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$RecordKey,
        [switch]$Required
    )

    $normalized = $Content.Replace("`r`n", "`n")
    $match = [regex]::Match(
        $normalized,
        "\A(?:\uFEFF)?---\n(?<yaml>.*?)\n---(?:\n|\z)",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    if (-not $match.Success) {
        if ($Required) {
            Add-Diagnostic -Code "DOCUMENT_FRONTMATTER_MISSING" -Message "Registered document has no supported frontmatter block." -Path $RepoPath -RecordKey $RecordKey
        }
        return $null
    }

    $metadata = @{}
    foreach ($line in ($match.Groups["yaml"].Value -split "`n")) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith("#")) { continue }
        if ($line -notmatch "^([A-Za-z0-9_-]+):\s*(.*?)\s*$") { continue }

        $key = $Matches[1]
        $value = ConvertFrom-FrontmatterScalar -Value $Matches[2]
        if ($metadata.ContainsKey($key)) {
            Add-Diagnostic -Code "DOCUMENT_METADATA_DUPLICATE" -Message "Frontmatter repeats '$key'." -Path $RepoPath -RecordKey $RecordKey
        }
        else {
            $metadata[$key] = $value
        }
    }
    return $metadata
}

function Get-FrontmatterValue {
    param(
        [AllowNull()][hashtable]$Metadata,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string]$RecordKey
    )

    if ($null -eq $Metadata -or -not $Metadata.ContainsKey($Name) -or
        [string]::IsNullOrWhiteSpace([string]$Metadata[$Name])) {
        Add-Diagnostic -Code "DOCUMENT_METADATA_MISSING" -Message "Document frontmatter is missing required '$Name'." -Path $RepoPath -RecordKey $RecordKey
        return ""
    }
    return ([string]$Metadata[$Name]).Trim()
}

function Test-Sha256 {
    param([string]$Value)
    return -not [string]::IsNullOrWhiteSpace($Value) -and $Value -cmatch "^[a-f0-9]{64}$"
}

function Test-RequiredPointerTriple {
    param(
        [Parameter(Mandatory = $true)]$Pointer,
        [Parameter(Mandatory = $true)][string]$Prefix,
        [Parameter(Mandatory = $true)][string]$ArtifactKey,
        [Parameter(Mandatory = $true)][string]$Root
    )

    $version = Get-RequiredText -Object $Pointer -Name "${Prefix}Version" -Code "POINTER_METADATA_MISSING" -Context "Pointer '$ArtifactKey'" -RecordKey $ArtifactKey
    $path = Get-RequiredText -Object $Pointer -Name "${Prefix}Path" -Code "POINTER_METADATA_MISSING" -Context "Pointer '$ArtifactKey'" -RecordKey $ArtifactKey
    $sha256 = Get-RequiredText -Object $Pointer -Name "${Prefix}Sha256" -Code "POINTER_METADATA_MISSING" -Context "Pointer '$ArtifactKey'" -Path $path -RecordKey $ArtifactKey
    if (-not [string]::IsNullOrWhiteSpace($sha256) -and -not (Test-Sha256 -Value $sha256)) {
        Add-Diagnostic -Code "POINTER_HASH_INVALID" -Message "Pointer '$ArtifactKey' has an invalid ${Prefix}Sha256." -Path $path -RecordKey $ArtifactKey
    }
    if (-not [string]::IsNullOrWhiteSpace($path)) {
        Resolve-RegisteredPath `
            -RepoPath $path `
            -Root $Root `
            -Context "Pointer '$ArtifactKey' ${Prefix}" `
            -RecordKey $ArtifactKey | Out-Null
    }
    return [pscustomobject]@{
        version = $version
        path = $path
        sha256 = $sha256
    }
}

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}
elseif (-not [System.IO.Path]::IsPathRooted($WorkspaceRoot)) {
    $WorkspaceRoot = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $WorkspaceRoot))
}
else {
    $WorkspaceRoot = [System.IO.Path]::GetFullPath($WorkspaceRoot)
}

$normalizedWorkspaceRoot = [System.IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd([char[]]"\/")
$registryRepoPath = [string]$RegistryPath
$registryPathAllowed = -not [string]::IsNullOrWhiteSpace($registryRepoPath)
$registryFullPath = $null
if ($registryPathAllowed) {
    $verifiedRegistryPath = Resolve-RegisteredPath `
        -RepoPath $registryRepoPath `
        -Root $normalizedWorkspaceRoot `
        -Context "Registry" `
        -InvalidPathCode "INVALID_REGISTRY_PATH"
    if ($null -eq $verifiedRegistryPath) {
        $registryPathAllowed = $false
    }
    else {
        $registryFullPath = $verifiedRegistryPath
    }
}

$registry = $null
try {
    if (-not $registryPathAllowed) {
        $registry = $null
    }
    elseif (-not (Test-Path -LiteralPath $registryFullPath -PathType Leaf)) {
        Add-Diagnostic -Code "REGISTRY_NOT_FOUND" -Message "Artifact-state registry does not exist." -Path $registryRepoPath
    }
    else {
        $registryText = [System.IO.File]::ReadAllText($registryFullPath)
        try {
            $registry = $registryText | ConvertFrom-Json
        }
        catch {
            Add-Diagnostic -Code "REGISTRY_INVALID_JSON" -Message "Artifact-state registry is not valid JSON." -Path $registryRepoPath
        }
    }
}
catch {
    throw
}

if ($null -ne $registry -and -not (Test-JsonObject -Value $registry)) {
    Add-Diagnostic -Code "REGISTRY_TYPE_INVALID" -Message "Artifact-state registry root must be a JSON object." -Path $registryRepoPath
    $registry = $null
}

$recordMap = New-Object "System.Collections.Generic.Dictionary[string,object]" (
    [System.StringComparer]::Ordinal
)
$recordList = New-Object System.Collections.Generic.List[object]
$pointerMap = New-Object "System.Collections.Generic.Dictionary[string,object]" (
    [System.StringComparer]::Ordinal
)
$registrySource = ""

if ($null -ne $registry) {
    $schemaVersion = Get-RequiredText -Object $registry -Name "schemaVersion" -Code "REGISTRY_METADATA_MISSING" -Context "Registry" -Path $registryRepoPath
    if (-not [string]::IsNullOrWhiteSpace($schemaVersion) -and $schemaVersion -cne "1.0") {
        Add-Diagnostic -Code "REGISTRY_SCHEMA_UNSUPPORTED" -Message "Unsupported schemaVersion '$schemaVersion'." -Path $registryRepoPath
    }
    $registryUpdated = Get-RequiredText -Object $registry -Name "updated" -Code "REGISTRY_METADATA_MISSING" -Context "Registry" -Path $registryRepoPath
    if (-not [string]::IsNullOrWhiteSpace($registryUpdated) -and $registryUpdated -notmatch "^\d{4}-\d{2}-\d{2}$") {
        Add-Diagnostic -Code "REGISTRY_METADATA_INVALID" -Message "Registry 'updated' must use YYYY-MM-DD." -Path $registryRepoPath
    }
    $registrySource = Get-RequiredText -Object $registry -Name "source" -Code "REGISTRY_METADATA_MISSING" -Context "Registry" -Path $registryRepoPath

    $recordsProperty = $registry.PSObject.Properties["records"]
    $recordsValue = if ($null -eq $recordsProperty) { $null } else { ,$recordsProperty.Value }
    $records = @()
    if (-not (Test-ObjectProperty -Object $registry -Name "records") -or
        -not (Test-JsonArray -Value $recordsValue)) {
        Add-Diagnostic -Code "REGISTRY_RECORDS_TYPE_INVALID" -Message "Registry 'records' must be a JSON array." -Path $registryRepoPath
    }
    else {
        $records = @($recordsValue)
    }
    if ($records.Count -eq 0) {
        Add-Diagnostic -Code "REGISTRY_RECORDS_MISSING" -Message "Registry must contain at least one record." -Path $registryRepoPath
    }

    foreach ($record in $records) {
        if (-not (Test-JsonObject -Value $record)) {
            Add-Diagnostic -Code "REGISTRY_RECORD_TYPE_INVALID" -Message "Every registry record must be a JSON object." -Path $registryRepoPath
            continue
        }
        $artifactKey = Get-RequiredText -Object $record -Name "artifactId" -Code "RECORD_METADATA_MISSING" -Context "Registry record" -Path $registryRepoPath
        $version = Get-RequiredText -Object $record -Name "version" -Code "RECORD_METADATA_MISSING" -Context "Registry record '$artifactKey'" -Path $registryRepoPath
        $recordKey = if ($artifactKey -and $version) { "$artifactKey@$version" } else { "" }
        $repoPath = Get-RequiredText -Object $record -Name "path" -Code "RECORD_METADATA_MISSING" -Context "Registry record '$recordKey'" -Path $registryRepoPath -RecordKey $recordKey
        $lifecycle = (Get-RequiredText -Object $record -Name "lifecycle" -Code "RECORD_METADATA_MISSING" -Context "Registry record '$recordKey'" -Path $repoPath -RecordKey $recordKey).ToLowerInvariant()
        $registeredSha = (Get-RequiredText -Object $record -Name "sha256" -Code "RECORD_METADATA_MISSING" -Context "Registry record '$recordKey'" -Path $repoPath -RecordKey $recordKey).ToLowerInvariant()
        $metadataModeValue = Get-ObjectProperty -Object $record -Name "metadataMode"
        $metadataMode = if ($null -eq $metadataModeValue -or [string]::IsNullOrWhiteSpace([string]$metadataModeValue)) {
            "frontmatter"
        }
        else {
            ([string]$metadataModeValue).Trim().ToLowerInvariant()
        }
        $supersedesProperty = $record.PSObject.Properties["supersedes"]
        $supersedesValue = if ($null -eq $supersedesProperty) { $null } else { ,$supersedesProperty.Value }
        $supersedes = @()
        if (-not (Test-ObjectProperty -Object $record -Name "supersedes") -or
            -not (Test-JsonArray -Value $supersedesValue)) {
            Add-Diagnostic -Code "RECORD_SUPERSEDES_TYPE_INVALID" -Message "Record '$recordKey' supersedes must be a JSON array." -Path $repoPath -RecordKey $recordKey
        }
        else {
            foreach ($supersedesItem in @($supersedesValue)) {
                if ($supersedesItem -isnot [string] -or
                    [string]::IsNullOrWhiteSpace([string]$supersedesItem)) {
                    Add-Diagnostic -Code "RECORD_SUPERSEDES_TYPE_INVALID" -Message "Record '$recordKey' supersedes entries must be non-empty strings." -Path $repoPath -RecordKey $recordKey
                    continue
                }
                $supersedes += ([string]$supersedesItem).Trim()
            }
        }

        if ($artifactKey.Contains("@")) {
            Add-Diagnostic -Code "RECORD_METADATA_INVALID" -Message "artifactId must not contain '@'." -Path $repoPath -RecordKey $recordKey
        }
        if ($AllowedLifecycles -notcontains $lifecycle) {
            Add-Diagnostic -Code "RECORD_LIFECYCLE_INVALID" -Message "Unsupported lifecycle '$lifecycle'." -Path $repoPath -RecordKey $recordKey
        }
        if ($registeredSha -and -not (Test-Sha256 -Value $registeredSha)) {
            Add-Diagnostic -Code "RECORD_HASH_INVALID" -Message "Record SHA-256 must be 64 lowercase hexadecimal characters." -Path $repoPath -RecordKey $recordKey
        }
        if (@("frontmatter", "registry", "legacy-registry") -notcontains $metadataMode) {
            Add-Diagnostic -Code "RECORD_METADATA_MODE_INVALID" -Message "Unsupported metadataMode '$metadataMode'." -Path $repoPath -RecordKey $recordKey
        }
        if ($recordKey -and $recordMap.ContainsKey($recordKey)) {
            Add-Diagnostic -Code "DUPLICATE_RECORD" -Message "Registry repeats record '$recordKey'." -Path $repoPath -RecordKey $recordKey
            continue
        }

        $fullPath = if ($repoPath) {
            Resolve-RegisteredPath -RepoPath $repoPath -Root $WorkspaceRoot -Context "Record '$recordKey'" -RecordKey $recordKey
        }
        else {
            $null
        }
        $fileExists = $null -ne $fullPath -and (Test-Path -LiteralPath $fullPath -PathType Leaf)
        if ($null -ne $fullPath -and -not $fileExists) {
            Add-Diagnostic -Code "DOCUMENT_NOT_FOUND" -Message "Registered document does not exist." -Path $repoPath -RecordKey $recordKey
        }
        $snapshot = if ($fileExists) {
            Get-DocumentSnapshot -FullPath $fullPath -RepoPath $repoPath -RecordKey $recordKey
        }
        else {
            $null
        }
        $metadata = $null
        $legacyMetadata = $null
        if ($null -ne $snapshot -and $metadataMode -eq "frontmatter") {
            $metadata = Get-Frontmatter `
                -Content $snapshot.content `
                -RepoPath $repoPath `
                -RecordKey $recordKey `
                -Required
        }
        elseif ($null -ne $snapshot -and $metadataMode -eq "registry") {
            $embeddedMetadata = Get-Frontmatter `
                -Content $snapshot.content `
                -RepoPath $repoPath `
                -RecordKey $recordKey
            if ($null -ne $embeddedMetadata) {
                Add-Diagnostic -Code "DOCUMENT_METADATA_MODE_CONFLICT" -Message "Registry metadata mode forbids a supported document frontmatter block." -Path $repoPath -RecordKey $recordKey
            }
        }
        elseif ($null -ne $snapshot -and $metadataMode -eq "legacy-registry") {
            $legacyMetadata = Get-Frontmatter `
                -Content $snapshot.content `
                -RepoPath $repoPath `
                -RecordKey $recordKey
            if ($null -eq $legacyMetadata) {
                Add-Diagnostic -Code "LEGACY_FRONTMATTER_MISSING" -Message "Migration-only legacy-registry mode requires an existing legacy frontmatter block." -Path $repoPath -RecordKey $recordKey
            }
        }

        $actualSha = ""
        if ($null -ne $snapshot) {
            $actualSha = $snapshot.sha256
            if ($registeredSha -and $registeredSha -cne $actualSha) {
                Add-Diagnostic -Code "HASH_MISMATCH" -Message "Registered SHA-256 does not match current file bytes." -Path $repoPath -RecordKey $recordKey
            }
        }

        $documentType = ""
        $documentUpdated = ""
        $documentSource = ""
        $decisionStatus = ""
        if ($null -ne $metadata) {
            $documentId = Get-FrontmatterValue -Metadata $metadata -Name "artifact_id" -RepoPath $repoPath -RecordKey $recordKey
            $documentTitle = Get-FrontmatterValue -Metadata $metadata -Name "title" -RepoPath $repoPath -RecordKey $recordKey
            $documentType = (Get-FrontmatterValue -Metadata $metadata -Name "type" -RepoPath $repoPath -RecordKey $recordKey).ToLowerInvariant()
            $documentStatus = (Get-FrontmatterValue -Metadata $metadata -Name "status" -RepoPath $repoPath -RecordKey $recordKey).ToLowerInvariant()
            $documentUpdated = Get-FrontmatterValue -Metadata $metadata -Name "updated" -RepoPath $repoPath -RecordKey $recordKey
            $documentSource = Get-FrontmatterValue -Metadata $metadata -Name "source" -RepoPath $repoPath -RecordKey $recordKey
            $documentVersion = Get-FrontmatterValue -Metadata $metadata -Name "version" -RepoPath $repoPath -RecordKey $recordKey

            if ($documentId -and $documentId -cne $artifactKey) {
                Add-Diagnostic -Code "DOCUMENT_METADATA_MISMATCH" -Message "Document artifact_id '$documentId' does not match registry '$artifactKey'." -Path $repoPath -RecordKey $recordKey
            }
            if ($documentVersion -and $documentVersion -cne $version) {
                Add-Diagnostic -Code "DOCUMENT_METADATA_MISMATCH" -Message "Document version '$documentVersion' does not match registry '$version'." -Path $repoPath -RecordKey $recordKey
            }
            $documentLifecycleMatches = $documentStatus -and (
                $documentStatus -ceq $lifecycle -or
                ($lifecycle -eq "superseded" -and
                    @("baselined", "shipped") -contains $documentStatus)
            )
            if ($documentStatus -and -not $documentLifecycleMatches) {
                Add-Diagnostic -Code "DOCUMENT_METADATA_MISMATCH" -Message "Document publication status '$documentStatus' is incompatible with registry lifecycle '$lifecycle'." -Path $repoPath -RecordKey $recordKey
            }
            if ($documentType -and $AllowedTypes -notcontains $documentType) {
                Add-Diagnostic -Code "DOCUMENT_METADATA_INVALID" -Message "Document type '$documentType' is unsupported." -Path $repoPath -RecordKey $recordKey
            }
            if ($documentType -eq "decision") {
                $decisionStatus = Get-FrontmatterValue -Metadata $metadata -Name "decision_status" -RepoPath $repoPath -RecordKey $recordKey
                if ($decisionStatus -and @("proposed", "accepted", "rejected", "withdrawn") -notcontains $decisionStatus.ToLowerInvariant()) {
                    Add-Diagnostic -Code "DOCUMENT_METADATA_INVALID" -Message "Decision document has unsupported decision_status '$decisionStatus'." -Path $repoPath -RecordKey $recordKey
                }
            }
            if ($documentUpdated -and $documentUpdated -notmatch "^\d{4}-\d{2}-\d{2}$") {
                Add-Diagnostic -Code "DOCUMENT_METADATA_INVALID" -Message "Document updated date must use YYYY-MM-DD." -Path $repoPath -RecordKey $recordKey
            }
        }
        elseif ($metadataMode -in @("registry", "legacy-registry")) {
            $documentType = (Get-RequiredText -Object $record -Name "artifactType" -Code "RECORD_DOCUMENT_METADATA_MISSING" -Context "Registry metadata for '$recordKey'" -Path $repoPath -RecordKey $recordKey).ToLowerInvariant()
            $documentUpdated = Get-RequiredText -Object $record -Name "documentUpdated" -Code "RECORD_DOCUMENT_METADATA_MISSING" -Context "Registry metadata for '$recordKey'" -Path $repoPath -RecordKey $recordKey
            $documentSource = Get-RequiredText -Object $record -Name "documentSource" -Code "RECORD_DOCUMENT_METADATA_MISSING" -Context "Registry metadata for '$recordKey'" -Path $repoPath -RecordKey $recordKey

            if ($documentType -and $AllowedTypes -notcontains $documentType) {
                Add-Diagnostic -Code "RECORD_DOCUMENT_METADATA_INVALID" -Message "Registry artifactType '$documentType' is unsupported." -Path $repoPath -RecordKey $recordKey
            }
            if ($documentUpdated -and $documentUpdated -notmatch "^\d{4}-\d{2}-\d{2}$") {
                Add-Diagnostic -Code "RECORD_DOCUMENT_METADATA_INVALID" -Message "Registry documentUpdated date must use YYYY-MM-DD." -Path $repoPath -RecordKey $recordKey
            }

            if ($documentType -eq "decision") {
                $decisionStatus = Get-RequiredText -Object $record -Name "decisionStatus" -Code "RECORD_DOCUMENT_METADATA_MISSING" -Context "Registry metadata for decision '$recordKey'" -Path $repoPath -RecordKey $recordKey
                if ($decisionStatus -and @("proposed", "accepted", "rejected", "withdrawn") -notcontains $decisionStatus.ToLowerInvariant()) {
                    Add-Diagnostic -Code "RECORD_DOCUMENT_METADATA_INVALID" -Message "Registry decisionStatus '$decisionStatus' is unsupported." -Path $repoPath -RecordKey $recordKey
                }
            }

            if ($metadataMode -eq "legacy-registry" -and $null -ne $legacyMetadata) {
                $legacyComparisons = [ordered]@{
                    artifact_id = $artifactKey
                    version = $version
                    type = $documentType
                    updated = $documentUpdated
                    source = $documentSource
                }
                foreach ($legacyName in $legacyComparisons.Keys) {
                    if ($legacyMetadata.ContainsKey($legacyName) -and
                        -not [string]::IsNullOrWhiteSpace([string]$legacyMetadata[$legacyName]) -and
                        [string]$legacyMetadata[$legacyName] -cne [string]$legacyComparisons[$legacyName]) {
                        Add-Diagnostic -Code "LEGACY_METADATA_CONFLICT" -Message "Legacy frontmatter '$legacyName' conflicts with registry metadata." -Path $repoPath -RecordKey $recordKey
                    }
                }

                if ($legacyMetadata.ContainsKey("status") -and
                    -not [string]::IsNullOrWhiteSpace([string]$legacyMetadata["status"])) {
                    $legacyStatus = ([string]$legacyMetadata["status"]).Trim().ToLowerInvariant()
                    $legacyStatusMatches = $legacyStatus -ceq $lifecycle -or
                        ($lifecycle -eq "superseded" -and
                            @("baselined", "shipped") -contains $legacyStatus)
                    if (-not $legacyStatusMatches) {
                        Add-Diagnostic -Code "LEGACY_METADATA_CONFLICT" -Message "Legacy frontmatter status '$legacyStatus' conflicts with registry lifecycle '$lifecycle'." -Path $repoPath -RecordKey $recordKey
                    }
                }

                if ($documentType -eq "decision" -and
                    $legacyMetadata.ContainsKey("decision_status") -and
                    -not [string]::IsNullOrWhiteSpace([string]$legacyMetadata["decision_status"]) -and
                    [string]$legacyMetadata["decision_status"] -cne $decisionStatus) {
                    Add-Diagnostic -Code "LEGACY_METADATA_CONFLICT" -Message "Legacy decision_status conflicts with registry metadata." -Path $repoPath -RecordKey $recordKey
                }
            }
        }

        $entry = [pscustomobject]@{
            artifactId = $artifactKey
            version = $version
            key = $recordKey
            path = $repoPath
            fullPath = $fullPath
            lifecycle = $lifecycle
            registeredSha256 = $registeredSha
            actualSha256 = $actualSha
            supersedes = @($supersedes)
            metadata = $metadata
            metadataMode = $metadataMode
            documentType = $documentType
            documentUpdated = $documentUpdated
            documentSource = $documentSource
            decisionStatus = $decisionStatus
        }
        $recordList.Add($entry) | Out-Null
        if ($recordKey) {
            $recordMap[$recordKey] = $entry
        }
    }

    $pathOwners = @{}
    foreach ($entry in $recordList) {
        if (-not $entry.path) { continue }
        if ($pathOwners.ContainsKey($entry.path)) {
            Add-Diagnostic -Code "DUPLICATE_PATH" -Message "Registry path is shared by '$($pathOwners[$entry.path])' and '$($entry.key)'." -Path $entry.path -RecordKey $entry.key
        }
        else {
            $pathOwners[$entry.path] = $entry.key
        }
    }

    $incoming = New-Object "System.Collections.Generic.Dictionary[string,object]" (
        [System.StringComparer]::Ordinal
    )
    foreach ($entry in $recordList) {
        foreach ($targetKey in $entry.supersedes) {
            if (-not $targetKey) { continue }
            if ($targetKey -ceq $entry.key) {
                Add-Diagnostic -Code "INVALID_SUPERSESSION_SELF" -Message "Record supersedes itself." -Path $entry.path -RecordKey $entry.key
                continue
            }
            if (-not $recordMap.ContainsKey($targetKey)) {
                Add-Diagnostic -Code "INVALID_SUPERSESSION_TARGET" -Message "Supersession target '$targetKey' does not exist." -Path $entry.path -RecordKey $entry.key
                continue
            }

            $target = $recordMap[$targetKey]
            if ($target.artifactId -cne $entry.artifactId) {
                Add-Diagnostic -Code "INVALID_SUPERSESSION_IDENTITY" -Message "Supersession crosses stable artifact identities." -Path $entry.path -RecordKey $entry.key
            }
            if (@("baselined", "shipped", "superseded") -notcontains $entry.lifecycle) {
                Add-Diagnostic -Code "INVALID_SUPERSESSION_STATE" -Message "Only a baselined, shipped, or historically superseded record may supersede another version." -Path $entry.path -RecordKey $entry.key
            }
            if ($target.lifecycle -cne "superseded") {
                Add-Diagnostic -Code "INVALID_SUPERSESSION_STATE" -Message "Supersession target '$targetKey' must have lifecycle 'superseded'." -Path $target.path -RecordKey $targetKey
            }
            if (-not $incoming.ContainsKey($targetKey)) {
                $incoming[$targetKey] = New-Object System.Collections.Generic.List[string]
            }
            $incoming[$targetKey].Add($entry.key)
        }
    }

    foreach ($targetKey in $incoming.Keys) {
        if ($incoming[$targetKey].Count -gt 1) {
            Add-Diagnostic -Code "INVALID_SUPERSESSION_AMBIGUOUS" -Message "Record '$targetKey' has multiple successors: $($incoming[$targetKey] -join ', ')." -Path $recordMap[$targetKey].path -RecordKey $targetKey
        }
    }
    foreach ($entry in $recordList) {
        if ($entry.lifecycle -eq "superseded" -and
            (-not $incoming.ContainsKey($entry.key) -or $incoming[$entry.key].Count -ne 1)) {
            Add-Diagnostic -Code "INVALID_SUPERSESSION_ORPHAN" -Message "Superseded record must have exactly one successor." -Path $entry.path -RecordKey $entry.key
        }
    }

    $visitState = New-Object "System.Collections.Generic.Dictionary[string,int]" (
        [System.StringComparer]::Ordinal
    )
    function Visit-SupersessionNode {
        param([Parameter(Mandatory = $true)][string]$Key)

        if ($visitState.ContainsKey($Key)) {
            if ($visitState[$Key] -eq 1) {
                Add-Diagnostic -Code "INVALID_SUPERSESSION_CYCLE" -Message "Supersession graph contains a cycle at '$Key'." -Path $recordMap[$Key].path -RecordKey $Key
            }
            return
        }

        $visitState[$Key] = 1
        foreach ($targetKey in $recordMap[$Key].supersedes) {
            if ($recordMap.ContainsKey($targetKey)) {
                Visit-SupersessionNode -Key $targetKey
            }
        }
        $visitState[$Key] = 2
    }
    foreach ($key in ($recordMap.Keys | Sort-Object)) {
        Visit-SupersessionNode -Key $key
    }

    $pointersProperty = $registry.PSObject.Properties["pointers"]
    $pointersValue = if ($null -eq $pointersProperty) { $null } else { ,$pointersProperty.Value }
    $pointers = @()
    if (-not (Test-ObjectProperty -Object $registry -Name "pointers") -or
        -not (Test-JsonArray -Value $pointersValue)) {
        Add-Diagnostic -Code "REGISTRY_POINTERS_TYPE_INVALID" -Message "Registry 'pointers' must be a JSON array." -Path $registryRepoPath
    }
    else {
        $pointers = @($pointersValue)
    }
    if ($pointers.Count -eq 0) {
        Add-Diagnostic -Code "REGISTRY_POINTERS_MISSING" -Message "Registry must contain at least one pointer." -Path $registryRepoPath
    }

    foreach ($pointer in $pointers) {
        if (-not (Test-JsonObject -Value $pointer)) {
            Add-Diagnostic -Code "REGISTRY_POINTER_TYPE_INVALID" -Message "Every registry pointer must be a JSON object." -Path $registryRepoPath
            continue
        }
        $pointerId = Get-RequiredText -Object $pointer -Name "artifactId" -Code "POINTER_METADATA_MISSING" -Context "Registry pointer" -Path $registryRepoPath
        $pointerSource = Get-RequiredText -Object $pointer -Name "source" -Code "POINTER_METADATA_MISSING" -Context "Pointer '$pointerId'" -Path $registryRepoPath -RecordKey $pointerId
        $baselineTriple = Test-RequiredPointerTriple -Pointer $pointer -Prefix "baseline" -ArtifactKey $pointerId -Root $WorkspaceRoot
        $latestTriple = Test-RequiredPointerTriple -Pointer $pointer -Prefix "latest" -ArtifactKey $pointerId -Root $WorkspaceRoot

        if ($pointerMap.ContainsKey($pointerId)) {
            Add-Diagnostic -Code "DUPLICATE_POINTER" -Message "Registry repeats pointer for '$pointerId'." -Path $registryRepoPath -RecordKey $pointerId
            continue
        }

        $pointerEntry = [pscustomobject]@{
            artifactId = $pointerId
            source = $pointerSource
            baseline = $baselineTriple
            latest = $latestTriple
        }
        $pointerMap[$pointerId] = $pointerEntry
    }

    $artifactIds = @(
        $recordList |
            ForEach-Object { $_.artifactId } |
            Where-Object { $_ } |
            Sort-Object -CaseSensitive -Unique
    )
    $artifactIdSet = New-Object "System.Collections.Generic.HashSet[string]" (
        [System.StringComparer]::Ordinal
    )
    foreach ($id in $artifactIds) {
        [void]$artifactIdSet.Add($id)
    }
    foreach ($pointerId in @($pointerMap.Keys | Sort-Object -CaseSensitive)) {
        if (-not $artifactIdSet.Contains($pointerId)) {
            Add-Diagnostic -Code "ORPHAN_POINTER" -Message "Pointer '$pointerId' has no registered artifact records." -Path $registryRepoPath -RecordKey $pointerId
        }
    }
    foreach ($id in $artifactIds) {
        $artifactRecords = @($recordList | Where-Object { $_.artifactId -ceq $id })
        $activeRecords = @($artifactRecords | Where-Object { $ActiveBaselineStates -contains $_.lifecycle })
        if ($activeRecords.Count -eq 0) {
            Add-Diagnostic -Code "MISSING_ACTIVE_BASELINE" -Message "Artifact '$id' has no baselined or shipped record." -RecordKey $id
        }
        elseif ($activeRecords.Count -gt 1) {
            Add-Diagnostic -Code "AMBIGUOUS_ACTIVE_BASELINE" -Message "Artifact '$id' has multiple active baselines: $($activeRecords.key -join ', ')." -RecordKey $id
        }

        if (-not $pointerMap.ContainsKey($id)) {
            Add-Diagnostic -Code "MISSING_POINTER" -Message "Artifact '$id' has no baseline/latest pointer." -Path $registryRepoPath -RecordKey $id
            continue
        }

        $pointer = $pointerMap[$id]
        $baselineKey = "$id@$($pointer.baseline.version)"
        if (-not $recordMap.ContainsKey($baselineKey)) {
            Add-Diagnostic -Code "STALE_BASELINE_POINTER" -Message "Baseline pointer references missing record '$baselineKey'." -Path $pointer.baseline.path -RecordKey $id
        }
        else {
            $baselineRecord = $recordMap[$baselineKey]
            if ($baselineRecord.path -cne $pointer.baseline.path -or
                $baselineRecord.registeredSha256 -cne $pointer.baseline.sha256 -or
                $activeRecords.Count -ne 1 -or
                $activeRecords[0].key -cne $baselineKey) {
                Add-Diagnostic -Code "STALE_BASELINE_POINTER" -Message "Baseline pointer does not match the unique active baseline record." -Path $pointer.baseline.path -RecordKey $id
            }
        }

        $latestKey = "$id@$($pointer.latest.version)"
        if (-not $recordMap.ContainsKey($latestKey)) {
            Add-Diagnostic -Code "STALE_LATEST_POINTER" -Message "Latest pointer references missing record '$latestKey'." -Path $pointer.latest.path -RecordKey $id
        }
        else {
            $latestRecord = $recordMap[$latestKey]
            if ($latestRecord.path -cne $pointer.latest.path -or
                $latestRecord.registeredSha256 -cne $pointer.latest.sha256 -or
                $latestRecord.lifecycle -eq "superseded") {
                Add-Diagnostic -Code "STALE_LATEST_POINTER" -Message "Latest pointer does not match a non-superseded registered record." -Path $pointer.latest.path -RecordKey $id
            }
        }
    }
}

if (-not $recordList.ToArray().Where({ $_.artifactId -ceq $ArtifactId }, "First")) {
    Add-Diagnostic -Code "ARTIFACT_NOT_FOUND" -Message "Artifact '$ArtifactId' is not registered." -Path $registryRepoPath -RecordKey $ArtifactId
}

$sortedDiagnostics = @(
    $script:Diagnostics |
        Sort-Object code, path, recordKey, message -Unique
)
$targetPointer = if ($pointerMap.ContainsKey($ArtifactId)) { $pointerMap[$ArtifactId] } else { $null }
$targetRecords = @($recordList | Where-Object { $_.artifactId -ceq $ArtifactId })
$targetActive = @($targetRecords | Where-Object { $ActiveBaselineStates -contains $_.lifecycle })

$baselineResult = $null
$latestResult = $null
$provenance = @()
if ($sortedDiagnostics.Count -eq 0 -and $null -ne $targetPointer -and $targetActive.Count -eq 1) {
    $baselineRecord = $recordMap["$ArtifactId@$($targetPointer.baseline.version)"]
    $latestRecord = $recordMap["$ArtifactId@$($targetPointer.latest.version)"]

    $baselineResult = [pscustomobject][ordered]@{
        path = $baselineRecord.path
        absolutePath = $baselineRecord.fullPath
        version = $baselineRecord.version
        lifecycle = $baselineRecord.lifecycle
        sha256 = $baselineRecord.actualSha256
        metadataMode = $baselineRecord.metadataMode
        artifactType = $baselineRecord.documentType
        updated = $baselineRecord.documentUpdated
        source = $baselineRecord.documentSource
        decisionStatus = $baselineRecord.decisionStatus
    }
    $latestResult = [pscustomobject][ordered]@{
        path = $latestRecord.path
        absolutePath = $latestRecord.fullPath
        version = $latestRecord.version
        lifecycle = $latestRecord.lifecycle
        sha256 = $latestRecord.actualSha256
        metadataMode = $latestRecord.metadataMode
        artifactType = $latestRecord.documentType
        updated = $latestRecord.documentUpdated
        source = $latestRecord.documentSource
        decisionStatus = $latestRecord.decisionStatus
    }
    $documentSource = [string]$baselineRecord.documentSource
    $provenance = @(
        [pscustomobject][ordered]@{
            kind = "registry"
            path = $registryRepoPath
            source = $registrySource
        },
        [pscustomobject][ordered]@{
            kind = "baseline-pointer"
            path = $targetPointer.baseline.path
            source = $targetPointer.source
        },
        [pscustomobject][ordered]@{
            kind = "document"
            path = $baselineRecord.path
            source = $documentSource
        }
    )
}

if ($sortedDiagnostics.Count -eq 0 -and
    ($null -eq $baselineResult -or $null -eq $latestResult)) {
    Add-Diagnostic -Code "RESOLUTION_INCOMPLETE" -Message "Exact baseline/latest resolution did not produce both target records." -Path $registryRepoPath -RecordKey $ArtifactId
    $sortedDiagnostics = @(
        $script:Diagnostics |
            Sort-Object code, path, recordKey, message -Unique
    )
}

$result = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    verdict = if ($sortedDiagnostics.Count -eq 0) { "resolved" } else { "blocked" }
    artifactId = $ArtifactId
    baseline = $baselineResult
    latest = $latestResult
    provenance = @($provenance)
    diagnostics = @($sortedDiagnostics)
}

if ($AsJson) {
    $result | ConvertTo-Json -Depth 12
}
else {
    if ($result.verdict -eq "resolved") {
        Write-Output "RESOLVED $ArtifactId"
        Write-Output "Baseline: $($baselineResult.path) @ $($baselineResult.version)"
        Write-Output "SHA-256: $($baselineResult.sha256)"
        Write-Output "Latest: $($latestResult.path) @ $($latestResult.version)"
        Write-Output "Registry: $registryRepoPath"
    }
    else {
        Write-Output "BLOCKED $ArtifactId"
        foreach ($diagnostic in $sortedDiagnostics) {
            Write-Output "[$($diagnostic.code)] $($diagnostic.message)"
        }
    }
}

if ($result.verdict -eq "resolved") {
    exit 0
}
exit 2
