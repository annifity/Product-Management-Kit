[CmdletBinding()]
param(
    [string]$WorkspaceRoot = ".",

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[A-Za-z0-9][A-Za-z0-9._-]{1,127}$")]
    [string]$DesignId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceArtifactId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceVersion,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^sha256:[0-9a-f]{64}$")]
    [string]$SourceSha256,

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^sha256:[0-9a-f]{64}$")]
    [string]$ContractFingerprint,

    [ValidateSet("screen-architecture", "wireframe", "visual-design", "interactive-html")]
    [string]$Mode = "interactive-html",

    [ValidateSet("bound-system", "existing-ui", "free-design")]
    [string]$DesignAuthorityMode = "free-design",

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DesignAuthoritySource,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DecisionOwner,

    [string]$Destination
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Root = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Resolve-PathInsideRoot {
    param(
        [Parameter(Mandatory = $true)][string]$RootPath,
        [Parameter(Mandatory = $true)][string]$Candidate,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $rootWithSeparator = $RootPath.TrimEnd([char[]]"\/") + [System.IO.Path]::DirectorySeparatorChar
    $fullPath = if ([System.IO.Path]::IsPathRooted($Candidate)) {
        [System.IO.Path]::GetFullPath($Candidate)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $RootPath $Candidate))
    }

    if (-not $fullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label must stay inside workspace root '$RootPath'."
    }
    return $fullPath
}

function ConvertTo-WorkspacePath {
    param([Parameter(Mandatory = $true)][string]$FullPath)

    return $FullPath.Substring($Root.Length).TrimStart([char[]]"\/").Replace("\", "/")
}

function Write-Template {
    param(
        [Parameter(Mandatory = $true)][string]$TemplatePath,
        [Parameter(Mandatory = $true)][string]$OutputPath,
        [Parameter(Mandatory = $true)][hashtable]$Tokens
    )

    $text = [System.IO.File]::ReadAllText($TemplatePath)
    foreach ($key in $Tokens.Keys) {
        $text = $text.Replace("{{${key}}}", [string]$Tokens[$key])
    }
    [System.IO.File]::WriteAllText($OutputPath, ($text -replace "`r`n", "`n"), $Utf8NoBom)
}

$sourceFullPath = Resolve-PathInsideRoot -RootPath $Root -Candidate $SourcePath -Label "SourcePath"
if (-not (Test-Path -LiteralPath $sourceFullPath -PathType Leaf)) {
    throw "SourcePath does not identify an existing file: $SourcePath"
}

$actualSourceHash = "sha256:" + (Get-FileHash -LiteralPath $sourceFullPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualSourceHash -cne $SourceSha256) {
    throw "Source SHA-256 mismatch. Expected '$SourceSha256'; actual '$actualSourceHash'."
}

if ([string]::IsNullOrWhiteSpace($Destination)) {
    $Destination = ".annifity/docs/designs/$DesignId"
}
$packageRoot = Resolve-PathInsideRoot -RootPath $Root -Candidate $Destination -Label "Destination"
if (Test-Path -LiteralPath $packageRoot) {
    throw "Destination already exists; use the controlled mutation workflow to revise it: $packageRoot"
}

$previewRoot = Join-Path $packageRoot "preview"
New-Item -ItemType Directory -Path $previewRoot -Force | Out-Null

$sourceRelativePath = ConvertTo-WorkspacePath -FullPath $sourceFullPath
$tokens = @{
    TITLE = $Title
    DESIGN_ID = $DesignId
    SOURCE_ID = "$SourceArtifactId@$SourceVersion"
    SOURCE_PATH = $sourceRelativePath
    SOURCE_SHA256 = $SourceSha256
    CONTRACT_FINGERPRINT = $ContractFingerprint
    MODE = $Mode
    DESIGN_AUTHORITY_MODE = $DesignAuthorityMode
    DESIGN_AUTHORITY_SOURCE = $DesignAuthoritySource
    DECISION_OWNER = $DecisionOwner
}

$templateMap = [ordered]@{
    "_refs/templates/design/design-handoff.md" = "design-handoff.md"
    "_refs/templates/design/design-brief.md" = "design-brief.md"
    "_refs/templates/design/design-system.md" = "DESIGN.md"
    "_refs/templates/design/design-traceability.md" = "traceability.md"
    "_refs/templates/design/screen-design.md" = "screens.md"
    "_refs/templates/design/design-review.md" = "review.md"
    "_refs/templates/design/portable-html.html" = "preview/index.html"
}

foreach ($entry in $templateMap.GetEnumerator()) {
    $templatePath = Join-Path $RepositoryRoot $entry.Key
    if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
        throw "Missing design template: $($entry.Key)"
    }
    Write-Template `
        -TemplatePath $templatePath `
        -OutputPath (Join-Path $packageRoot $entry.Value) `
        -Tokens $tokens
}

$today = (Get-Date).ToString("yyyy-MM-dd")
$designContract = [ordered]@{
    schemaVersion = "1.0"
    designId = $DesignId
    version = "1.0"
    status = "draft"
    source = [ordered]@{
        artifactId = $SourceArtifactId
        version = $SourceVersion
        path = $sourceRelativePath
        sha256 = $SourceSha256
        requirementIds = @()
    }
    authority = [ordered]@{
        mockupAuthority = if ($DesignAuthorityMode -eq "bound-system") { "accepted-presentation" } else { "illustrative" }
        behaviorAuthority = "accepted-source-only"
        approvedBy = $null
        approvedAt = $null
    }
    target = [ordered]@{
        surfaces = @()
        viewports = @()
        locales = @()
        fidelity = $Mode
    }
    designSystem = [ordered]@{
        id = $DesignAuthoritySource
        version = "unspecified"
        status = if ($DesignAuthorityMode -eq "bound-system") { "accepted" } else { "provisional" }
    }
    flows = @()
    screens = @()
    states = @()
    interactions = @()
    designGaps = @()
    quality = [ordered]@{
        readiness = "needs-review"
        accessibilityReviewed = $false
        responsiveReviewed = $false
        traceabilityComplete = $false
    }
    gate = [ordered]@{
        gateId = "phase.design.ready"
        decision = "pending"
        approvalRecordId = $null
    }
}
$designContractJson = (($designContract | ConvertTo-Json -Depth 12) -replace "`r`n", "`n") + "`n"
[System.IO.File]::WriteAllText((Join-Path $packageRoot "design-contract.json"), $designContractJson, $Utf8NoBom)

$manifest = [ordered]@{
    schemaVersion = "1.0"
    designId = $DesignId
    title = $Title
    status = "draft"
    mode = $Mode
    sourceSpec = [ordered]@{
        artifactId = $SourceArtifactId
        version = $SourceVersion
        path = $sourceRelativePath
        sha256 = $SourceSha256
    }
    contractFingerprint = $ContractFingerprint
    designAuthority = [ordered]@{
        mode = $DesignAuthorityMode
        source = $DesignAuthoritySource
    }
    decisionOwner = $DecisionOwner
    artifacts = @(
        [ordered]@{ kind = "contract"; path = "design-contract.json" },
        [ordered]@{ kind = "handoff"; path = "design-handoff.md" },
        [ordered]@{ kind = "brief"; path = "design-brief.md" },
        [ordered]@{ kind = "design-system"; path = "DESIGN.md" },
        [ordered]@{ kind = "traceability"; path = "traceability.md" },
        [ordered]@{ kind = "screens"; path = "screens.md" },
        [ordered]@{ kind = "review"; path = "review.md" },
        [ordered]@{ kind = "preview"; path = "preview/index.html" }
    )
    blockers = @()
    created = $today
    updated = $today
}

$manifestJson = (($manifest | ConvertTo-Json -Depth 10) -replace "`r`n", "`n") + "`n"
[System.IO.File]::WriteAllText((Join-Path $packageRoot "design-manifest.json"), $manifestJson, $Utf8NoBom)

[pscustomobject][ordered]@{
    status = "created"
    designId = $DesignId
    packagePath = ConvertTo-WorkspacePath -FullPath $packageRoot
    source = "$SourceArtifactId@$SourceVersion"
    mode = $Mode
}
