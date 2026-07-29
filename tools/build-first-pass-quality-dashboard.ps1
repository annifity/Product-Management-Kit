[CmdletBinding(DefaultParameterSetName = "Manifest")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "Manifest")]
    [string]$ManifestPath,

    [Parameter(Mandatory = $true, ParameterSetName = "Paths")]
    [string[]]$InputPaths,

    [string]$OutputPath,

    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$AllowedOutcomes = @(
    "accepted_first_pass",
    "accepted_after_scope_change",
    "accepted_after_rework",
    "awaiting_revision",
    "manual_edit_unconfirmed",
    "revised_unconfirmed",
    "unconfirmed_first_output"
)

function Resolve-RepoFile {
    param([Parameter(Mandatory = $true)][string]$Path, [string]$Label)

    if ([System.IO.Path]::IsPathRooted($Path) -or
        @($Path.Replace("\", "/").Split("/")) -contains ".." -or
        @($Path.Replace("\", "/").Split("/")) -contains ".") {
        throw "$Label must be a canonical repository-relative path: $Path"
    }
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
    $prefix = $Root.TrimEnd([char[]]"\/") + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "$Label does not exist inside the repository: $Path"
    }
    return $fullPath
}

function Get-RequiredText {
    param($Object, [string]$Name, [string]$Context)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        throw "$Context is missing '$Name'."
    }
    return ([string]$property.Value).Trim()
}

function Get-Boolean {
    param($Object, [string]$Name, [string]$Context)
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $property.Value -isnot [bool]) {
        throw "$Context '$Name' must be a JSON boolean."
    }
    return [bool]$property.Value
}

function Get-Median {
    param([int[]]$Values)
    if ($Values.Count -eq 0) { return $null }
    $sorted = @($Values | Sort-Object)
    $middle = [math]::Floor($sorted.Count / 2)
    if ($sorted.Count % 2 -eq 1) {
        return [double]$sorted[$middle]
    }
    return [math]::Round((([double]$sorted[$middle - 1] + [double]$sorted[$middle]) / 2), 2)
}

function Get-Rate {
    param([int]$Numerator, [int]$Denominator)
    if ($Denominator -eq 0) { return $null }
    return [math]::Round(($Numerator / [double]$Denominator), 4)
}

function Measure-Chains {
    param([object[]]$Chains)

    $firstPassAccepted = 0
    $defectCorrections = 0
    $repeatEvents = 0
    $unsupportedEvents = 0
    $contextMissEvents = 0
    $invalidDiagramChains = 0
    $turnCounts = New-Object System.Collections.Generic.List[int]

    foreach ($chain in $Chains) {
        $outcome = [string]$chain.outcome
        $firstPassDefect = [bool]$chain.firstPassDefect
        if (-not $firstPassDefect -and
            @("accepted_first_pass", "accepted_after_scope_change") -contains $outcome) {
            $firstPassAccepted++
        }

        $chainDefectTurns = 0
        $chainInvalidDiagram = $false
        foreach ($correction in @($chain.corrections)) {
            if ([string]$correction.classification -cne "first_pass_defect") {
                continue
            }
            $chainDefectTurns++
            $defectCorrections++
            $causes = @($correction.causes | ForEach-Object { [string]$_ } | Sort-Object -Unique)
            if ($causes -ccontains "repeat_after_fix") { $repeatEvents++ }
            if ($causes -ccontains "unsupported_content") { $unsupportedEvents++ }
            if ($causes -ccontains "missed_context") { $contextMissEvents++ }
            if ($causes -ccontains "invalid_diagram") { $chainInvalidDiagram = $true }
        }
        if ($chainInvalidDiagram) { $invalidDiagramChains++ }
        $turnCounts.Add($chainDefectTurns) | Out-Null
    }

    return [pscustomobject][ordered]@{
        chains = $Chains.Count
        firstPassAcceptedChains = $firstPassAccepted
        firstPassAcceptanceRate = Get-Rate -Numerator $firstPassAccepted -Denominator $Chains.Count
        medianCorrectionTurns = Get-Median -Values @($turnCounts)
        defectCorrectionEvents = $defectCorrections
        repeatAfterFixEvents = $repeatEvents
        repeatAfterFixRate = Get-Rate -Numerator $repeatEvents -Denominator $defectCorrections
        unsupportedContentDeletionEvents = $unsupportedEvents
        unsupportedContentDeletionRate = Get-Rate -Numerator $unsupportedEvents -Denominator $defectCorrections
        contextMissEvents = $contextMissEvents
        contextMissRate = Get-Rate -Numerator $contextMissEvents -Denominator $defectCorrections
        invalidDiagramChains = $invalidDiagramChains
        invalidDiagramRate = Get-Rate -Numerator $invalidDiagramChains -Denominator $Chains.Count
    }
}

$resolvedInputPaths = @()
if ($PSCmdlet.ParameterSetName -eq "Manifest") {
    $manifestFullPath = Resolve-RepoFile -Path $ManifestPath.Replace("\", "/") -Label "Dashboard manifest"
    $manifest = [System.IO.File]::ReadAllText($manifestFullPath) | ConvertFrom-Json
    if ((Get-RequiredText -Object $manifest -Name "schemaVersion" -Context "Dashboard manifest") -cne "1.0") {
        throw "Unsupported dashboard manifest schema."
    }
    if ($null -eq $manifest.PSObject.Properties["inputPaths"] -or @($manifest.inputPaths).Count -eq 0) {
        throw "Dashboard manifest must declare at least one input path."
    }
    $resolvedInputPaths = @($manifest.inputPaths | ForEach-Object { ([string]$_).Replace("\", "/") })
}
else {
    $resolvedInputPaths = @($InputPaths | ForEach-Object { ([string]$_).Replace("\", "/") })
}
if ($resolvedInputPaths.Count -eq 0 -or
    @($resolvedInputPaths | Sort-Object -Unique).Count -ne $resolvedInputPaths.Count) {
    throw "Dashboard input paths must be non-empty and unique."
}

$sources = @()
$chainMap = New-Object "System.Collections.Generic.Dictionary[string,object]" (
    [System.StringComparer]::Ordinal
)
$chainJsonMap = New-Object "System.Collections.Generic.Dictionary[string,string]" (
    [System.StringComparer]::Ordinal
)

foreach ($repoPath in ($resolvedInputPaths | Sort-Object)) {
    $fullPath = Resolve-RepoFile -Path $repoPath -Label "Observation input"
    $sha = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $audit = [System.IO.File]::ReadAllText($fullPath) | ConvertFrom-Json
    if ((Get-RequiredText -Object $audit -Name "schemaVersion" -Context "Observation '$repoPath'") -cne "1.0" -or
        (Get-RequiredText -Object $audit -Name "status" -Context "Observation '$repoPath'") -cne "complete") {
        throw "Observation '$repoPath' is not a completed schema 1.0 audit."
    }
    if ($null -eq $audit.PSObject.Properties["privacy"] -or
        (Get-Boolean -Object $audit.privacy -Name "rawContentIncluded" -Context "Observation '$repoPath' privacy")) {
        throw "Observation '$repoPath' must be privacy-safe and exclude raw content."
    }
    if ($null -eq $audit.PSObject.Properties["chains"]) {
        throw "Observation '$repoPath' is missing chains."
    }
    $sources += [pscustomobject][ordered]@{ path = $repoPath; sha256 = $sha }

    foreach ($chain in @($audit.chains)) {
        $sessionId = Get-RequiredText -Object $chain -Name "sessionId" -Context "Observation chain"
        $chainId = Get-RequiredText -Object $chain -Name "chainId" -Context "Observation chain"
        $skillName = Get-RequiredText -Object $chain.skill -Name "name" -Context "Chain '$sessionId/$chainId' skill"
        $skillVersion = Get-RequiredText -Object $chain.skill -Name "version" -Context "Chain '$sessionId/$chainId' skill"
        $outcome = Get-RequiredText -Object $chain -Name "outcome" -Context "Chain '$sessionId/$chainId'"
        if ($AllowedOutcomes -cnotcontains $outcome) {
            throw "Chain '$sessionId/$chainId' has unsupported outcome '$outcome'."
        }
        [void](Get-Boolean -Object $chain -Name "firstPassDefect" -Context "Chain '$sessionId/$chainId'")
        [void](Get-Boolean -Object $chain -Name "userScopeChange" -Context "Chain '$sessionId/$chainId'")
        if ($null -eq $chain.PSObject.Properties["corrections"]) {
            throw "Chain '$sessionId/$chainId' is missing corrections."
        }
        foreach ($correction in @($chain.corrections)) {
            $classification = Get-RequiredText -Object $correction -Name "classification" -Context "Chain '$sessionId/$chainId' correction"
            if (@("first_pass_defect", "user_scope_change") -cnotcontains $classification) {
                throw "Chain '$sessionId/$chainId' has unsupported correction classification '$classification'."
            }
            if ($null -eq $correction.PSObject.Properties["causes"]) {
                throw "Chain '$sessionId/$chainId' correction is missing causes."
            }
            if ($classification -ceq "user_scope_change" -and @($correction.causes).Count -gt 0) {
                throw "User scope change in '$sessionId/$chainId' must not carry defect causes."
            }
        }

        $key = "$sessionId|$chainId"
        $canonical = $chain | ConvertTo-Json -Depth 20 -Compress
        if ($chainMap.ContainsKey($key)) {
            if ($chainJsonMap[$key] -cne $canonical) {
                throw "Conflicting duplicate observation chain '$key'."
            }
            continue
        }
        $chainMap[$key] = [pscustomobject][ordered]@{
            sessionId = $sessionId
            chainId = $chainId
            skill = [pscustomobject][ordered]@{ name = $skillName; version = $skillVersion }
            corrections = @($chain.corrections)
            firstPassDefect = [bool]$chain.firstPassDefect
            userScopeChange = [bool]$chain.userScopeChange
            outcome = $outcome
        }
        $chainJsonMap[$key] = $canonical
    }
}

$chains = @($chainMap.Values | Sort-Object { $_.skill.name }, { $_.skill.version }, sessionId, chainId)
$overall = Measure-Chains -Chains $chains
$groupRows = @()
$groups = $chains | Group-Object { "$($_.skill.name)`u001f$($_.skill.version)" }
foreach ($group in $groups) {
    $parts = $group.Name -split "`u001f", 2
    $metrics = Measure-Chains -Chains @($group.Group)
    $row = [ordered]@{ skill = $parts[0]; version = $parts[1] }
    foreach ($property in $metrics.PSObject.Properties) {
        $row[$property.Name] = $property.Value
    }
    $groupRows += [pscustomobject]$row
}
$groupRows = @($groupRows | Sort-Object skill, version)

$targets = [pscustomobject][ordered]@{
    firstPassAcceptanceRate = [pscustomobject][ordered]@{
        operator = "gte"; target = 0.70
        status = if ($null -eq $overall.firstPassAcceptanceRate) { "baseline-required" } elseif ($overall.firstPassAcceptanceRate -ge 0.70) { "met" } else { "not-met" }
    }
    medianCorrectionTurns = [pscustomobject][ordered]@{
        operator = "lte"; target = 2
        status = if ($null -eq $overall.medianCorrectionTurns) { "baseline-required" } elseif ($overall.medianCorrectionTurns -le 2) { "met" } else { "not-met" }
    }
    repeatAfterFixRate = [pscustomobject][ordered]@{
        operator = "lt"; target = 0.05
        status = if ($null -eq $overall.repeatAfterFixRate) { "baseline-required" } elseif ($overall.repeatAfterFixRate -lt 0.05) { "met" } else { "not-met" }
    }
    invalidDiagramRate = [pscustomobject][ordered]@{
        operator = "eq"; target = 0
        status = if ($null -eq $overall.invalidDiagramRate) { "baseline-required" } elseif ($overall.invalidDiagramRate -eq 0) { "met" } else { "not-met" }
    }
    unsupportedContentDeletionRate = [pscustomobject][ordered]@{
        operator = "relative-reduction"; target = 0.60; status = "baseline-required"
    }
}

$result = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    status = "complete"
    sources = @($sources | Sort-Object path)
    overall = $overall
    bySkillVersion = @($groupRows)
    targets = $targets
    diagnostics = @()
}
$json = ($result | ConvertTo-Json -Depth 20) + "`n"
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
    if (Test-Path -LiteralPath $outputFullPath) {
        throw "Refusing to overwrite dashboard output: $outputFullPath"
    }
    $parent = [System.IO.Path]::GetDirectoryName($outputFullPath)
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($outputFullPath, $json, $Utf8NoBom)
}
if ($AsJson) {
    Write-Output $json.TrimEnd()
}
else {
    Write-Output "OK first-pass dashboard: $($chains.Count) chain(s), $($groupRows.Count) skill/version group(s)."
    Write-Output "First-pass acceptance: $($overall.firstPassAcceptanceRate)"
    Write-Output "Median correction turns: $($overall.medianCorrectionTurns)"
}

