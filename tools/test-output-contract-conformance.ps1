[CmdletBinding()]
param(
    [string]$ContractPath = "tests/fixtures/contracts/all-skills-output-contract.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Read-RepoText {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    if ([System.IO.Path]::IsPathRooted($RelativePath) -or
        @($RelativePath.Replace("\", "/").Split("/")) -contains "..") {
        throw "Contract path must be repository-relative: $RelativePath"
    }
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $Root $RelativePath))
    $rootPrefix = $Root.TrimEnd([char[]]"\/") + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "Contract references missing or out-of-root path: $RelativePath"
    }
    return [System.IO.File]::ReadAllText($fullPath)
}

function Get-H2Section {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Heading,
        [Parameter(Mandatory = $true)][string]$Skill
    )

    $normalized = $Text.Replace("`r`n", "`n")
    $pattern = "(?ms)^##\s+" + [regex]::Escape($Heading) + "\s*\n(?<body>.*?)(?=^##\s+|\z)"
    $matches = [regex]::Matches($normalized, $pattern)
    if ($matches.Count -ne 1) {
        throw "Skill '$Skill' must contain exactly one '$Heading' section; found $($matches.Count)."
    }
    $body = $matches[0].Groups["body"].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($body)) {
        throw "Skill '$Skill' has an empty '$Heading' section."
    }
    return $body
}

function Assert-Terms {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)]$Terms,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($termValue in @($Terms)) {
        $term = [string]$termValue
        if ([string]::IsNullOrWhiteSpace($term) -or
            $Text.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "$Context is missing required field/term '$term'."
        }
    }
}

$contract = (Read-RepoText -RelativePath $ContractPath) | ConvertFrom-Json
if ([string]$contract.schemaVersion -cne "1.0") {
    throw "Unsupported skill output contract schema."
}
$records = @($contract.skills)
$canonicalSkills = @(
    Get-ChildItem -LiteralPath (Join-Path $Root "skills") -Directory |
        Select-Object -ExpandProperty Name |
        Sort-Object
)
$contractSkills = @($records | ForEach-Object { [string]$_.skill } | Sort-Object)
if (($canonicalSkills -join "`n") -cne ($contractSkills -join "`n")) {
    throw "Output contract skill set does not exactly match canonical skills.`nCanonical: $($canonicalSkills -join ', ')`nContract: $($contractSkills -join ', ')"
}
if (@($contractSkills | Sort-Object -Unique).Count -ne $contractSkills.Count) {
    throw "Output contract repeats a skill."
}

foreach ($record in $records) {
    $skill = [string]$record.skill
    $skillText = Read-RepoText -RelativePath "skills/$skill/SKILL.md"
    $inputSection = Get-H2Section -Text $skillText -Heading "Input Contract" -Skill $skill
    $outputSection = Get-H2Section -Text $skillText -Heading "Output" -Skill $skill
    $handoffSection = Get-H2Section -Text $skillText -Heading "Handoff" -Skill $skill

    Assert-Terms -Text $inputSection -Terms $record.input.requiredTerms -Context "Skill '$skill' Input Contract"
    Assert-Terms -Text $outputSection -Terms $record.output.requiredTerms -Context "Skill '$skill' Output"
    Assert-Terms -Text $handoffSection -Terms $record.handoff.requiredTerms -Context "Skill '$skill' Handoff"

    if ($null -eq $record.PSObject.Properties["templates"]) {
        throw "Skill '$skill' contract must declare a templates array, even when empty."
    }
    foreach ($template in @($record.templates)) {
        $templatePath = [string]$template.path
        $templateText = Read-RepoText -RelativePath $templatePath
        Assert-Terms `
            -Text $templateText `
            -Terms $template.requiredTerms `
            -Context "Skill '$skill' template '$templatePath'"
    }
}

Write-Host "OK output-contract and template conformance ($($records.Count)/$($canonicalSkills.Count) skills)."

