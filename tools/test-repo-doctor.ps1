[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Doctor = Join-Path $Root "tools/invoke-repo-doctor.ps1"
$ManifestPath = Join-Path $Root "tools/repo-root-manifest.json"
$SchemaPath = Join-Path $Root "tools/repo-root-manifest.schema.json"
$FixturePath = Join-Path $Root "tests/fixtures/repo-doctor/cases.json"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Write-Text {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text
    )

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        [void](New-Item -ItemType Directory -Path $parent)
    }
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Get-WorkspaceSnapshot {
    param([Parameter(Mandatory = $true)][string]$Workspace)

    $snapshot = [ordered]@{}
    foreach ($file in @(
        Get-ChildItem -LiteralPath $Workspace -Force -Recurse -File |
            Where-Object {
                $_.FullName -notlike (Join-Path $Workspace ".git\*")
            } |
            Sort-Object FullName
    )) {
        $relative = $file.FullName.Substring($Workspace.Length).
            TrimStart([char[]]"\/").
            Replace("\", "/")
        $snapshot[$relative] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
    }
    return $snapshot
}

function Assert-SnapshotEqual {
    param(
        [Parameter(Mandatory = $true)]$Before,
        [Parameter(Mandatory = $true)]$After,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $beforeJson = $Before | ConvertTo-Json -Depth 10 -Compress
    $afterJson = $After | ConvertTo-Json -Depth 10 -Compress
    if ($beforeJson -cne $afterJson) {
        throw "$Context changed files while running a read-only repository doctor."
    }
}

function New-FixtureRepository {
    param(
        [Parameter(Mandatory = $true)][string]$Workspace,
        [Parameter(Mandatory = $true)]$Manifest,
        [Parameter(Mandatory = $true)]$Case
    )

    [void](New-Item -ItemType Directory -Path $Workspace)
    & git -C $Workspace init -q
    if ($LASTEXITCODE -ne 0) {
        throw "Could not initialize isolated Git repository for repo-doctor tests."
    }
    $global:LASTEXITCODE = 0
    & git -C $Workspace config core.autocrlf false
    if ($LASTEXITCODE -ne 0) {
        throw "Could not configure isolated repo-doctor fixture line endings."
    }
    $global:LASTEXITCODE = 0

    $ignoreRules = [System.Collections.Generic.List[string]]::new()
    foreach ($rootEntry in @($Manifest.allowedRoots)) {
        $relativePath = [string]$rootEntry.path
        if ($rootEntry.gitPolicy -eq "internal") {
            continue
        }
        if ($rootEntry.gitPolicy -eq "ignored") {
            $ignoreRules.Add("$relativePath/")
            Write-Text `
                -Path (Join-Path $Workspace "$relativePath/runtime.fixture") `
                -Text "ignored runtime fixture`n"
            continue
        }
        if ($rootEntry.gitPolicy -eq "runtime-local") {
            if ([bool]$rootEntry.required) {
                Write-Text `
                    -Path (Join-Path $Workspace "$relativePath/runtime.fixture") `
                    -Text "local runtime fixture`n"
            }
            continue
        }
        if ([bool]$rootEntry.required) {
            Write-Text `
                -Path (Join-Path $Workspace "$relativePath/canonical.fixture") `
                -Text "tracked fixture for $relativePath`n"
        }
    }

    Write-Text `
        -Path (Join-Path $Workspace ".gitignore") `
        -Text (($ignoreRules -join "`n") + "`n")

    & git -C $Workspace add -- .gitignore 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Could not stage isolated repo-doctor fixture .gitignore."
    }
    $global:LASTEXITCODE = 0
    foreach ($rootEntry in @(
        $Manifest.allowedRoots |
            Where-Object { $_.gitPolicy -eq "tracked" -and [bool]$_.required }
    )) {
        & git -C $Workspace add -- ([string]$rootEntry.path) 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Could not stage fixture root '$($rootEntry.path)'."
        }
        $global:LASTEXITCODE = 0
    }

    if (@($Case.appendIgnoreRules).Count -gt 0) {
        foreach ($extraRule in @($Case.appendIgnoreRules)) {
            $ignoreRules.Add([string]$extraRule)
        }
        Write-Text `
            -Path (Join-Path $Workspace ".gitignore") `
            -Text (($ignoreRules -join "`n") + "`n")
    }

    foreach ($addition in @($Case.additions)) {
        $relativePath = ([string]$addition).Replace("\", "/")
        if ([System.IO.Path]::IsPathRooted($relativePath) -or
            $relativePath -match "(^|/)\.\.($|/)") {
            throw "Repo-doctor fixture addition escapes its workspace: $relativePath"
        }
        Write-Text `
            -Path (Join-Path $Workspace ($relativePath.Replace(
                "/",
                [System.IO.Path]::DirectorySeparatorChar
            ))) `
            -Text "case addition`n"
    }
}

foreach ($requiredPath in @($Doctor, $ManifestPath, $SchemaPath, $FixturePath)) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Repo-doctor test is missing required path: $requiredPath"
    }
}

$manifest = Get-Content -Raw -LiteralPath $ManifestPath -Encoding UTF8 |
    ConvertFrom-Json
$schema = Get-Content -Raw -LiteralPath $SchemaPath -Encoding UTF8 |
    ConvertFrom-Json
$fixture = Get-Content -Raw -LiteralPath $FixturePath -Encoding UTF8 |
    ConvertFrom-Json
Assert-True `
    -Condition ([string]$manifest.'$schema' -eq "./repo-root-manifest.schema.json") `
    -Message "Root manifest must point to its explicit JSON schema."
Assert-True `
    -Condition ([string]$schema.'$id' -eq "urn:annifity:repo-root-manifest:1.0") `
    -Message "Root manifest schema must expose its stable ID."
Assert-True `
    -Condition ([string]$fixture.schemaVersion -eq "1.0") `
    -Message "Repo-doctor fixture schemaVersion must be 1.0."

$fixtureHashBefore = (Get-FileHash -LiteralPath $FixturePath -Algorithm SHA256).Hash
$tempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).
    TrimEnd([char[]]"\/")
$tempRoot = Join-Path $tempBase (
    "annifity-repo-doctor-{0}" -f [guid]::NewGuid().ToString("N")
)
[void](New-Item -ItemType Directory -Path $tempRoot)

try {
    $caseIndex = 0
    foreach ($case in @($fixture.cases)) {
        $caseIndex++
        $workspace = Join-Path $tempRoot ("case-{0}" -f $caseIndex)
        New-FixtureRepository `
            -Workspace $workspace `
            -Manifest $manifest `
            -Case $case

        $statusBefore = (& git -C $workspace status --porcelain=v1 --untracked-files=all) -join "`n"
        $snapshotBefore = Get-WorkspaceSnapshot -Workspace $workspace
        $reportText = (& $Doctor `
            -RootPath $workspace `
            -ManifestPath $ManifestPath) -join "`n"
        $report = $reportText | ConvertFrom-Json
        $snapshotAfter = Get-WorkspaceSnapshot -Workspace $workspace
        $statusAfter = (& git -C $workspace status --porcelain=v1 --untracked-files=all) -join "`n"

        Assert-SnapshotEqual `
            -Before $snapshotBefore `
            -After $snapshotAfter `
            -Context "Case '$($case.name)'"
        Assert-True `
            -Condition ($statusBefore -ceq $statusAfter) `
            -Message "Case '$($case.name)' changed Git status while running the doctor."
        Assert-True `
            -Condition ([string]$report.status -eq [string]$case.expectedStatus) `
            -Message "Case '$($case.name)' expected status '$($case.expectedStatus)' but got '$($report.status)'."

        $actualCodes = @($report.findings | ForEach-Object { [string]$_.code } | Sort-Object)
        $expectedCodes = @($case.expectedFindingCodes | ForEach-Object { [string]$_ } | Sort-Object)
        Assert-True `
            -Condition (($actualCodes -join "`n") -ceq ($expectedCodes -join "`n")) `
            -Message "Case '$($case.name)' finding codes differ. Expected $($expectedCodes -join ', '); got $($actualCodes -join ', ')."

        if ($caseIndex -eq 1) {
            $repeatText = (& $Doctor `
                -RootPath $workspace `
                -ManifestPath $ManifestPath) -join "`n"
            Assert-True `
                -Condition ($reportText -ceq $repeatText) `
                -Message "Identical repository state must produce byte-identical doctor output."

            foreach ($canonicalPath in @("docs", "tests")) {
                $entry = @(
                    $report.roots |
                        Where-Object { $_.path -eq $canonicalPath }
                )
                Assert-True `
                    -Condition ($entry.Count -eq 1) `
                    -Message "Doctor report is missing canonical root '$canonicalPath'."
                Assert-True `
                    -Condition (
                        $entry[0].expectedGitState -eq "tracked" -and
                        $entry[0].actualGitState -eq "tracked" -and
                        [string]$entry[0].explanation -match "tracked"
                    ) `
                    -Message "Doctor must explain tracked-vs-ignored status for '$canonicalPath'."
            }
        }
    }

    $liveReport = ((& $Doctor `
        -RootPath $Root `
        -ManifestPath $ManifestPath) -join "`n") |
        ConvertFrom-Json
    Assert-True `
        -Condition ([string]$liveReport.status -eq "pass") `
        -Message "Current Annifity root must satisfy the explicit repository manifest."
}
finally {
    $fixtureHashAfter = (Get-FileHash -LiteralPath $FixturePath -Algorithm SHA256).Hash
    if ($fixtureHashBefore -ne $fixtureHashAfter) {
        throw "Repo-doctor tests modified their canonical fixture."
    }

    if (Test-Path -LiteralPath $tempRoot -PathType Container) {
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        $tempPrefix = $tempBase + [System.IO.Path]::DirectorySeparatorChar
        if (-not $resolvedTempRoot.StartsWith(
            $tempPrefix,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            throw "Refusing to remove repo-doctor test data outside the system temp root."
        }
        Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
    }
}

Write-Host "OK repository doctor tests passed ($(@($fixture.cases).Count) case(s))."
