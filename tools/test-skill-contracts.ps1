[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FixtureRoot = Join-Path $Root "tests/fixtures/contracts"

if (-not (Test-Path -LiteralPath $FixtureRoot)) {
    throw "Missing skill contract fixture directory: tests/fixtures/contracts"
}

function Read-RepoText {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $fullPath = Join-Path $Root $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Skill contract fixture references missing source file: $RelativePath"
    }
    return [System.IO.File]::ReadAllText($fullPath)
}

function Get-WordCount {
    param([Parameter(Mandatory = $true)][string]$Text)

    return @([regex]::Matches($Text, "\b[\p{L}\p{N}][\p{L}\p{N}'-]*\b")).Count
}

function Get-MarkdownHeadings {
    param([Parameter(Mandatory = $true)][string]$Text)

    $headings = @()
    foreach ($line in ($Text -replace "`r`n", "`n" -split "`n")) {
        if ($line -match "^##\s+(?:\d+\.\s*)?(.+?)\s*$") {
            $headings += $Matches[1].Trim()
        }
    }
    return $headings
}

$fixtures = @(Get-ChildItem -LiteralPath $FixtureRoot -Filter "*.expected.json" -File | Sort-Object FullName)
if ($fixtures.Count -eq 0) {
    throw "No skill contract fixtures found under tests/fixtures/contracts."
}

foreach ($fixture in $fixtures) {
    $contract = Get-Content -Raw -LiteralPath $fixture.FullName | ConvertFrom-Json
    $inputPath = Join-Path $FixtureRoot $contract.input
    if (-not (Test-Path -LiteralPath $inputPath)) {
        throw "Skill contract fixture '$($contract.name)' is missing input file: $($contract.input)"
    }

    $sourceFiles = @("skills/$($contract.skill)/SKILL.md")
    if ($contract.PSObject.Properties.Name -contains "sourceFiles") {
        $sourceFiles += @($contract.sourceFiles)
    }

    $corpus = ($sourceFiles | ForEach-Object { Read-RepoText $_ }) -join "`n"
    foreach ($term in $contract.requiredTerms) {
        if ($corpus.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            throw "Skill contract fixture '$($contract.name)' failed: missing required term '$term'."
        }
    }

    if ($contract.PSObject.Properties.Name -contains "prohibitedTerms") {
        foreach ($term in $contract.prohibitedTerms) {
            if ($corpus.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                throw "Skill contract fixture '$($contract.name)' failed: prohibited term '$term' found."
            }
        }
    }

    if ($contract.PSObject.Properties.Name -contains "fileAssertions") {
        foreach ($assertion in @($contract.fileAssertions)) {
            $assertionText = Read-RepoText $assertion.path
            foreach ($term in @($assertion.requiredTerms)) {
                if ($assertionText.IndexOf([string]$term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                    throw "Skill contract fixture '$($contract.name)' failed: '$($assertion.path)' is missing required term '$term'."
                }
            }

            if ($assertion.PSObject.Properties.Name -contains "prohibitedTerms") {
                foreach ($term in @($assertion.prohibitedTerms)) {
                    if ($assertionText.IndexOf([string]$term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                        throw "Skill contract fixture '$($contract.name)' failed: '$($assertion.path)' contains prohibited term '$term'."
                    }
                }
            }
        }
    }

    if ($contract.PSObject.Properties.Name -contains "requiredHeadings") {
        $headingSource = if ($contract.PSObject.Properties.Name -contains "headingSource") {
            $contract.headingSource
        }
        elseif ($contract.PSObject.Properties.Name -contains "sourceFiles" -and @($contract.sourceFiles).Count -gt 0) {
            @($contract.sourceFiles)[0]
        }
        else {
            "skills/$($contract.skill)/SKILL.md"
        }

        $actualHeadings = @(Get-MarkdownHeadings -Text (Read-RepoText $headingSource))
        $expectedHeadings = @($contract.requiredHeadings)
        $actualText = $actualHeadings -join "|"
        $expectedText = $expectedHeadings -join "|"
        if ($actualText -ne $expectedText) {
            throw "Skill contract fixture '$($contract.name)' failed heading contract. Expected '$expectedText' but got '$actualText'."
        }
    }

    if ($contract.PSObject.Properties.Name -contains "maxWords") {
        $wordCountSource = if ($contract.PSObject.Properties.Name -contains "wordCountSource") {
            $contract.wordCountSource
        }
        elseif ($contract.PSObject.Properties.Name -contains "sourceFiles" -and @($contract.sourceFiles).Count -gt 0) {
            @($contract.sourceFiles)[0]
        }
        else {
            "skills/$($contract.skill)/SKILL.md"
        }

        $wordCount = Get-WordCount -Text (Read-RepoText $wordCountSource)
        if ($wordCount -gt [int]$contract.maxWords) {
            throw "Skill contract fixture '$($contract.name)' failed word cap: $wordCount > $($contract.maxWords)."
        }
    }
}

Write-Host "OK skill contract fixtures passed ($($fixtures.Count) fixture(s))."
