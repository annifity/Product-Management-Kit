[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SkillsRoot = Join-Path $Root "skills"
$UiCapabilityContractPath = Join-Path $Root "tests/fixtures/contracts/skill-ui-capability-contract.json"
$AllowedFrontmatterKeys = @("name", "description")
$validated = 0

function Get-QuotedYamlValue {
    param(
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $pattern = '(?m)^\s{2}' + [regex]::Escape($Key) + ':\s+"([^"]*)"\s*$'
    $matches = [regex]::Matches($Content, $pattern)
    if ($matches.Count -ne 1) {
        throw "$Path must contain exactly one quoted interface.$Key value."
    }
    return $matches[0].Groups[1].Value
}

if (-not (Test-Path -LiteralPath $SkillsRoot)) {
    throw "Missing canonical skills directory."
}
if (-not (Test-Path -LiteralPath $UiCapabilityContractPath)) {
    throw "Missing UI capability contract."
}
$uiCapabilityContract = [System.IO.File]::ReadAllText(
    $UiCapabilityContractPath
) | ConvertFrom-Json
$canonicalSkillNames = @(
    Get-ChildItem -LiteralPath $SkillsRoot -Directory |
        Sort-Object Name |
        ForEach-Object { $_.Name }
)
$contractSkillNames = @(
    $uiCapabilityContract.skills.PSObject.Properties |
        ForEach-Object { $_.Name } |
        Sort-Object
)
if (($canonicalSkillNames -join "`n") -cne ($contractSkillNames -join "`n")) {
    throw "UI capability contract skill set must exactly match canonical skills."
}

foreach ($skillDir in (Get-ChildItem -LiteralPath $SkillsRoot -Directory | Sort-Object Name)) {
    $skillPath = Join-Path $skillDir.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) {
        throw "Canonical skill '$($skillDir.Name)' is missing SKILL.md."
    }

    $content = [System.IO.File]::ReadAllText($skillPath).Replace("`r`n", "`n")
    $frontmatterMatch = [regex]::Match($content, "\A---\n(?<yaml>.*?)\n---(?:\n|\z)", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $frontmatterMatch.Success) {
        throw "skills/$($skillDir.Name)/SKILL.md has invalid YAML frontmatter delimiters."
    }

    $values = @{}
    foreach ($line in ($frontmatterMatch.Groups["yaml"].Value -split "`n")) {
        if ($line -notmatch "^(?<key>[A-Za-z0-9_-]+):\s*(?<value>.*)$") {
            throw "skills/$($skillDir.Name)/SKILL.md has unsupported multiline or malformed frontmatter: '$line'."
        }
        $key = $Matches["key"]
        if ($AllowedFrontmatterKeys -notcontains $key) {
            throw "skills/$($skillDir.Name)/SKILL.md has unsupported frontmatter key '$key'. Allowed keys: name, description."
        }
        if ($values.ContainsKey($key)) {
            throw "skills/$($skillDir.Name)/SKILL.md repeats frontmatter key '$key'."
        }
        $values[$key] = $Matches["value"].Trim().Trim("'", '"')
    }

    foreach ($requiredKey in $AllowedFrontmatterKeys) {
        if (-not $values.ContainsKey($requiredKey) -or [string]::IsNullOrWhiteSpace([string]$values[$requiredKey])) {
            throw "skills/$($skillDir.Name)/SKILL.md is missing non-empty '$requiredKey' frontmatter."
        }
    }
    if ($values.Count -ne $AllowedFrontmatterKeys.Count) {
        throw "skills/$($skillDir.Name)/SKILL.md frontmatter must contain exactly name and description."
    }

    $name = [string]$values["name"]
    $description = [string]$values["description"]
    if ($name -ne $skillDir.Name) {
        throw "Skill name '$name' must match folder '$($skillDir.Name)'."
    }
    if ($name.Length -gt 64 -or $name -notmatch "^[a-z0-9]+(?:-[a-z0-9]+)*$") {
        throw "Skill name '$name' must be lowercase kebab-case and at most 64 characters."
    }
    if ($description.Length -gt 1024) {
        throw "Skill '$name' description exceeds 1024 characters."
    }
    if ($description.Contains("<") -or $description.Contains(">")) {
        throw "Skill '$name' description cannot contain angle brackets."
    }
    if ($description -notmatch "(?i)\buse\s+(when|for|before|after|alongside|as|to)\b") {
        throw "Skill '$name' description lacks a recognizable trigger cue."
    }

    $openAiRelativePath = "skills/$name/agents/openai.yaml"
    $openAiPath = Join-Path $skillDir.FullName "agents/openai.yaml"
    if (-not (Test-Path -LiteralPath $openAiPath)) {
        throw "Missing canonical UI metadata: $openAiRelativePath"
    }
    $openAiContent = [System.IO.File]::ReadAllText($openAiPath).Replace("`r`n", "`n")
    if ($openAiContent -notmatch "(?m)^interface:\s*$") {
        throw "$openAiRelativePath is missing the interface mapping."
    }
    $displayName = Get-QuotedYamlValue -Content $openAiContent -Key "display_name" -Path $openAiRelativePath
    $shortDescription = Get-QuotedYamlValue -Content $openAiContent -Key "short_description" -Path $openAiRelativePath
    $defaultPrompt = Get-QuotedYamlValue -Content $openAiContent -Key "default_prompt" -Path $openAiRelativePath
    if ([string]::IsNullOrWhiteSpace($displayName)) {
        throw "$openAiRelativePath display_name cannot be empty."
    }
    if ($shortDescription.Length -lt 25 -or $shortDescription.Length -gt 64) {
        throw "$openAiRelativePath short_description must be 25-64 characters (actual: $($shortDescription.Length))."
    }
    if ($defaultPrompt -notmatch [regex]::Escape("`$$name")) {
        throw "$openAiRelativePath default_prompt must explicitly mention `$$name."
    }
    $uiText = "$shortDescription $defaultPrompt"
    $requiredUiTerms = @($uiCapabilityContract.skills.$name)
    if ($requiredUiTerms.Count -eq 0) {
        throw "$openAiRelativePath has no required UI capability terms."
    }
    foreach ($requiredUiTerm in $requiredUiTerms) {
        if ($uiText.IndexOf(
                [string]$requiredUiTerm,
                [System.StringComparison]::OrdinalIgnoreCase
            ) -lt 0) {
            throw (
                "$openAiRelativePath does not surface required capability " +
                "'$requiredUiTerm'."
            )
        }
    }

    $validated++
}

Write-Host "OK canonical skill format and UI metadata validation passed ($validated skills)."
