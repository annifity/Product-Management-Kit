[CmdletBinding()]
param(
    [string]$FixturePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($FixturePath)) {
    $FixturePath = Join-Path $Root "tests/fixtures/routing/skill-routing-cases.json"
}
elseif (-not [System.IO.Path]::IsPathRooted($FixturePath)) {
    $FixturePath = Join-Path $Root $FixturePath
}
$SkillsRoot = Join-Path $Root "skills"
$AllowedKinds = @("positive", "negative", "ambiguous", "handoff")
$AllowedLanguages = @("en", "vi")
$GenericRoutingTokens = @{
    "after" = $true; "and" = $true; "applies" = $true; "before" = $true
    "create" = $true; "for" = $true; "from" = $true; "including" = $true
    "into" = $true; "need" = $true; "needs" = $true; "product" = $true
    "request" = $true; "review" = $true; "that" = $true; "the" = $true
    "this" = $true; "use" = $true; "user" = $true; "users" = $true
    "using" = $true; "when" = $true; "with" = $true
}

function Get-RoutingTokens {
    param([Parameter(Mandatory = $true)][string]$Text)

    $tokens = @{}
    foreach ($match in [regex]::Matches($Text.ToLowerInvariant(), "[\p{L}\p{N}]+")) {
        $token = $match.Value
        if ($token.Length -lt 4 -or $GenericRoutingTokens.ContainsKey($token)) { continue }

        if ($token.Length -gt 5 -and $token.EndsWith("ies")) {
            $token = $token.Substring(0, $token.Length - 3) + "y"
        }
        elseif ($token.Length -gt 6 -and $token.EndsWith("ing")) {
            $token = $token.Substring(0, $token.Length - 3)
        }
        elseif ($token.Length -gt 5 -and $token.EndsWith("ed")) {
            $token = $token.Substring(0, $token.Length - 2)
        }
        elseif ($token.Length -gt 4 -and $token.EndsWith("s")) {
            $token = $token.Substring(0, $token.Length - 1)
        }

        if ($token.Length -ge 4 -and -not $GenericRoutingTokens.ContainsKey($token)) {
            $tokens[$token] = $true
        }
    }

    return @($tokens.Keys)
}

function Get-PromptMetadataOverlap {
    param(
        [Parameter(Mandatory = $true)][string]$Prompt,
        [Parameter(Mandatory = $true)]$SkillMetadata
    )

    $metadataTokens = @{}
    foreach ($token in (Get-RoutingTokens -Text ("{0} {1}" -f $SkillMetadata.Name, $SkillMetadata.Description))) {
        $metadataTokens[$token] = $true
    }

    return @(
        Get-RoutingTokens -Text $Prompt |
            Where-Object { $metadataTokens.ContainsKey($_) } |
            Sort-Object -Unique
    )
}

function Get-SkillMetadata {
    param([Parameter(Mandatory = $true)][string]$Path)

    $content = [System.IO.File]::ReadAllText($Path)
    $lines = ($content -replace "`r`n", "`n") -split "`n"
    if ($lines.Count -lt 3 -or $lines[0].Trim() -ne "---") {
        throw "Missing frontmatter: $Path"
    }

    $name = $null
    $description = $null
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq "---") { break }
        if ($lines[$i] -match "^name:\s*(.+?)\s*$") {
            $name = $Matches[1].Trim("'", '"')
        }
        elseif ($lines[$i] -match "^description:\s*(.+?)\s*$") {
            $description = $Matches[1].Trim("'", '"')
        }
    }

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($description)) {
        throw "Missing name or description: $Path"
    }

    return [pscustomobject]@{
        Name = $name
        Description = $description
    }
}

function Assert-SkillExists {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Skills,
        [Parameter(Mandatory = $true)][string]$Skill,
        [Parameter(Mandatory = $true)][string]$CaseId
    )

    if (-not $Skills.ContainsKey($Skill)) {
        throw "Routing case '$CaseId' references unknown skill '$Skill'."
    }
}

if (-not (Test-Path -LiteralPath $FixturePath)) {
    throw "Missing routing fixture: tests/fixtures/routing/skill-routing-cases.json"
}

$skills = @{}
Get-ChildItem -LiteralPath $SkillsRoot -Directory | Sort-Object Name | ForEach-Object {
    $skillPath = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) {
        throw "Canonical skill folder is missing SKILL.md: $($_.Name)"
    }
    $metadata = Get-SkillMetadata -Path $skillPath
    if ($skills.ContainsKey($metadata.Name)) {
        throw "Duplicate canonical skill name: $($metadata.Name)"
    }
    if ($metadata.Description -notmatch "(?i)\buse\s+(when|for|before|after|alongside|as|to)\b") {
        throw "Skill '$($metadata.Name)' description lacks a recognizable trigger cue."
    }
    $skills[$metadata.Name] = $metadata
}

$suite = Get-Content -Raw -LiteralPath $FixturePath -Encoding UTF8 | ConvertFrom-Json
if ($suite.schemaVersion -ne 2) {
    throw "Unsupported routing fixture schemaVersion: $($suite.schemaVersion)"
}

$cases = @($suite.cases)
if ($cases.Count -eq 0) {
    throw "Routing fixture contains no cases."
}

$seenIds = @{}
$seenPrompts = @{}
$coveredKinds = @{}
$coveredLanguages = @{}
$positiveSkills = @{}
$routeLanguageCoverage = @{}
foreach ($skillName in $skills.Keys) {
    $routeLanguageCoverage[$skillName] = @{}
}

foreach ($case in $cases) {
    $id = [string]$case.id
    $kind = [string]$case.kind
    $language = [string]$case.language
    $prompt = [string]$case.prompt
    $reason = [string]$case.reason

    if ($id -notmatch "^[a-z0-9]+(?:-[a-z0-9]+)*$") {
        throw "Routing case id must be lowercase kebab-case: '$id'."
    }
    if ($seenIds.ContainsKey($id)) {
        throw "Duplicate routing case id: $id"
    }
    $seenIds[$id] = $true

    if ($AllowedKinds -notcontains $kind) {
        throw "Routing case '$id' has unsupported kind '$kind'."
    }
    if ($AllowedLanguages -notcontains $language) {
        throw "Routing case '$id' has unsupported language '$language'."
    }
    if ($prompt.Trim().Length -lt 12) {
        throw "Routing case '$id' prompt is too short to be realistic."
    }
    if ($language -eq "vi" -and $prompt -notmatch "[\u00C0-\u024F\u1E00-\u1EFF]") {
        throw "Vietnamese routing case '$id' must contain real Vietnamese text, not only an English prompt with a vi label."
    }
    if ([string]::IsNullOrWhiteSpace($reason)) {
        throw "Routing case '$id' is missing a reason."
    }

    $promptKey = $prompt.Trim().ToLowerInvariant()
    if ($seenPrompts.ContainsKey($promptKey)) {
        throw "Duplicate routing prompt in case '$id'."
    }
    $seenPrompts[$promptKey] = $true
    $coveredKinds[$kind] = $true
    $coveredLanguages[$language] = $true

    $expectedSkill = if ($null -eq $case.expectedSkill) { $null } else { [string]$case.expectedSkill }
    $mustNotRouteTo = @($case.mustNotRouteTo | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })

    if ($expectedSkill) {
        Assert-SkillExists -Skills $skills -Skill $expectedSkill -CaseId $id
        if ($mustNotRouteTo -contains $expectedSkill) {
            throw "Routing case '$id' both expects and excludes '$expectedSkill'."
        }

        $descriptionAny = @($case.descriptionAny | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        if ($descriptionAny.Count -eq 0) {
            throw "Routing case '$id' must declare descriptionAny terms for '$expectedSkill'."
        }
        $description = [string]$skills[$expectedSkill].Description
        $hasDescriptionTerm = $false
        $hasDeclaredPromptBridge = $false
        $promptTokens = @{}
        foreach ($promptToken in (Get-RoutingTokens -Text $prompt)) {
            $promptTokens[$promptToken] = $true
        }
        foreach ($term in $descriptionAny) {
            if ($description.IndexOf([string]$term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hasDescriptionTerm = $true
                foreach ($termToken in (Get-RoutingTokens -Text ([string]$term))) {
                    if ($promptTokens.ContainsKey($termToken)) {
                        $hasDeclaredPromptBridge = $true
                        break
                    }
                }
            }
        }
        if (-not $hasDescriptionTerm) {
            throw "Routing case '$id' is not discoverable from '$expectedSkill' description. Expected any of: $($descriptionAny -join ', ')"
        }
        if (-not $hasDeclaredPromptBridge) {
            throw "Routing case '$id' descriptionAny terms do not bridge the prompt to '$expectedSkill' metadata."
        }

        $promptOverlap = @(Get-PromptMetadataOverlap -Prompt $prompt -SkillMetadata $skills[$expectedSkill])
        if ($promptOverlap.Count -eq 0) {
            throw "Routing case '$id' prompt has no meaningful lexical bridge to '$expectedSkill' metadata."
        }
        $routeLanguageCoverage[$expectedSkill][$language] = $true
    }

    foreach ($excludedSkill in $mustNotRouteTo) {
        Assert-SkillExists -Skills $skills -Skill ([string]$excludedSkill) -CaseId $id
    }

    if ($kind -eq "positive") {
        if (-not $expectedSkill) {
            throw "Positive routing case '$id' requires expectedSkill."
        }
        if ($mustNotRouteTo.Count -gt 0) {
            throw "Positive routing case '$id' must be a clear route. Put boundary assertions in an ambiguous case instead of mustNotRouteTo."
        }
        $positiveSkills[$expectedSkill] = $true
    }
    elseif ($kind -eq "negative") {
        $focusSkill = [string]$case.focusSkill
        if ([string]::IsNullOrWhiteSpace($focusSkill)) {
            throw "Negative routing case '$id' requires focusSkill."
        }
        Assert-SkillExists -Skills $skills -Skill $focusSkill -CaseId $id
        if ($mustNotRouteTo -notcontains $focusSkill) {
            throw "Negative routing case '$id' must include focusSkill '$focusSkill' in mustNotRouteTo."
        }

        $focusOverlap = @(Get-PromptMetadataOverlap -Prompt $prompt -SkillMetadata $skills[$focusSkill])
        if ($focusOverlap.Count -eq 0) {
            throw "Negative routing case '$id' is not superficially similar to focusSkill '$focusSkill' metadata."
        }

        if ($expectedSkill) {
            $expectedOverlap = @(Get-PromptMetadataOverlap -Prompt $prompt -SkillMetadata $skills[$expectedSkill])
            if ($expectedOverlap.Count -eq 0) {
                throw "Negative routing case '$id' prompt has no meaningful lexical bridge to winner '$expectedSkill' metadata."
            }
        }

        $boundaryAny = @($case.boundaryAny | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        if ($boundaryAny.Count -eq 0) {
            throw "Negative routing case '$id' must declare boundaryAny terms that make the exclusion discoverable in metadata."
        }
        $boundaryMetadata = [string]$skills[$focusSkill].Description
        if ($expectedSkill) {
            $boundaryMetadata += " " + [string]$skills[$expectedSkill].Description
        }
        $hasBoundaryTerm = $false
        foreach ($term in $boundaryAny) {
            if ($boundaryMetadata.IndexOf([string]$term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hasBoundaryTerm = $true
                break
            }
        }
        if (-not $hasBoundaryTerm) {
            throw "Negative routing case '$id' boundary is not stated in focus/winner metadata. Expected any of: $($boundaryAny -join ', ')"
        }
    }
    elseif ($kind -eq "ambiguous") {
        if (-not $expectedSkill) {
            throw "Ambiguous routing case '$id' requires expectedSkill."
        }
        if ($mustNotRouteTo.Count -eq 0) {
            throw "Ambiguous routing case '$id' requires at least one mustNotRouteTo boundary."
        }

        foreach ($excludedSkill in $mustNotRouteTo) {
            if (@(Get-PromptMetadataOverlap -Prompt $prompt -SkillMetadata $skills[[string]$excludedSkill]).Count -eq 0) {
                throw "Ambiguous routing case '$id' prompt has no meaningful lexical bridge to excluded boundary skill '$excludedSkill'."
            }
        }

        $boundaryAny = @($case.boundaryAny | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        if ($boundaryAny.Count -eq 0) {
            throw "Ambiguous routing case '$id' must declare boundaryAny terms from the winning skill metadata."
        }
        $winnerDescription = [string]$skills[$expectedSkill].Description
        $hasBoundaryTerm = $false
        foreach ($term in $boundaryAny) {
            if ($winnerDescription.IndexOf([string]$term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hasBoundaryTerm = $true
                break
            }
        }
        if (-not $hasBoundaryTerm) {
            throw "Ambiguous routing case '$id' winner metadata does not state the expected boundary. Expected any of: $($boundaryAny -join ', ')"
        }
    }
    elseif ($kind -eq "handoff") {
        $fromSkill = [string]$case.fromSkill
        if (-not $expectedSkill -or [string]::IsNullOrWhiteSpace($fromSkill)) {
            throw "Handoff routing case '$id' requires fromSkill and expectedSkill."
        }
        Assert-SkillExists -Skills $skills -Skill $fromSkill -CaseId $id
        if ($fromSkill -eq $expectedSkill) {
            throw "Handoff routing case '$id' cannot hand off a skill to itself."
        }
        $fromOverlap = @(Get-PromptMetadataOverlap -Prompt $prompt -SkillMetadata $skills[$fromSkill])
        if ($fromOverlap.Count -eq 0) {
            throw "Handoff routing case '$id' prompt has no meaningful lexical bridge to fromSkill '$fromSkill' metadata."
        }
    }
}

foreach ($kind in $AllowedKinds) {
    if (-not $coveredKinds.ContainsKey($kind)) {
        throw "Routing suite has no '$kind' case."
    }
}
foreach ($language in $AllowedLanguages) {
    if (-not $coveredLanguages.ContainsKey($language)) {
        throw "Routing suite has no '$language' case."
    }
}

foreach ($skillName in ($skills.Keys | Sort-Object)) {
    $missingLanguages = @($AllowedLanguages | Where-Object { -not $routeLanguageCoverage[$skillName].ContainsKey($_) })
    if ($missingLanguages.Count -gt 0) {
        throw "Canonical skill '$skillName' lacks expected-route coverage for: $($missingLanguages -join ', ')."
    }
}

$missingPositive = @($skills.Keys | Where-Object { -not $positiveSkills.ContainsKey($_) } | Sort-Object)
if ($missingPositive.Count -gt 0) {
    throw "Canonical skills missing a positive routing case: $($missingPositive -join ', ')"
}

Write-Host "OK static skill routing contract preflight passed ($($cases.Count) cases, $($skills.Count) skills, explicit boundaries, per-skill EN/VI)."
