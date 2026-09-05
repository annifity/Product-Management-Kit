[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Resolver = Join-Path $PSScriptRoot "resolve-ai-evaluation-verdict.ps1"
$PowerShell = (Get-Process -Id $PID).Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) (
    "annifity-ai-verdict-{0}" -f [guid]::NewGuid().ToString("N")
)

function Write-Suite {
    param([string]$Path, $Suite)
    [System.IO.File]::WriteAllText(
        $Path,
        (($Suite | ConvertTo-Json -Depth 30) + "`n"),
        $Utf8NoBom
    )
}

function Invoke-Resolver {
    param([string]$Path)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $text = @(
            & $PowerShell -NoProfile -ExecutionPolicy Bypass -File $Resolver `
                -SuitePath $Path -AsJson 2>&1
        ) -join [Environment]::NewLine
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
        $global:LASTEXITCODE = 0
    }
    return [pscustomobject]@{ code = $code; result = ($text | ConvertFrom-Json) }
}

try {
    New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
    $suitePath = Join-Path $TempRoot "suite.json"
    $suite = [pscustomobject][ordered]@{
        schemaVersion = "1.0"
        suiteId = "support-quality"
        suiteVersion = "1.0.0"
        productUseCase = "Draft cited support answers"
        decision = "Limited rollout"
        evaluationOwner = "AI Quality"
        decisionOwner = "Product"
        riskTier = "medium"
        deploymentContext = [pscustomobject]@{}
        sourceBaselines = @("AI-BEHAVIOR-01@1.0")
        dataset = [pscustomobject][ordered]@{
            datasetId = "support-golden"
            version = "1.0"
            slices = @("common", "vi")
        }
        cases = @(
            [pscustomobject]@{
                caseId = "C-01"; sliceIds = @("common"); graderIds = @("quality")
            },
            [pscustomobject]@{
                caseId = "C-02"; sliceIds = @("vi"); graderIds = @("quality")
            }
        )
        graders = @([pscustomobject]@{ graderId = "quality" })
        thresholds = [pscustomobject][ordered]@{
            overallRules = @(
                [pscustomobject]@{ metric = "quality"; operator = ">="; value = 0.85 }
            )
            sliceRules = @(
                [pscustomobject]@{ sliceId = "common"; metric = "quality"; operator = ">="; value = 0.80 },
                [pscustomobject]@{ sliceId = "vi"; metric = "quality"; operator = ">="; value = 0.80 }
            )
            hardBlockers = @("critical-privacy")
            nonRegressionRules = @(
                [pscustomobject]@{ metric = "quality"; maxDecline = 0.02 }
            )
            latencyBudget = [pscustomobject]@{
                metric = "p95LatencyMs"; operator = "<="; value = 2500
            }
            costBudget = [pscustomobject]@{
                metric = "costPerRun"; operator = "<="; value = 0.05
            }
        }
        runPolicy = [pscustomobject]@{}
        results = @(
            [pscustomobject]@{
                role = "baseline"; suiteVersion = "1.0.0"; datasetVersion = "1.0"
                environmentFingerprint = "env-1"; graderVersions = @("quality@1")
                metrics = [pscustomobject]@{
                    quality = 0.86; p95LatencyMs = 2200; costPerRun = 0.04
                }
                sliceMetrics = [pscustomobject]@{
                    common = [pscustomobject]@{ quality = 0.87 }
                    vi = [pscustomobject]@{ quality = 0.84 }
                }
                hardBlockerFailures = @()
            },
            [pscustomobject]@{
                role = "candidate"; suiteVersion = "1.0.0"; datasetVersion = "1.0"
                environmentFingerprint = "env-1"; graderVersions = @("quality@1")
                metrics = [pscustomobject]@{
                    quality = 0.90; p95LatencyMs = 2300; costPerRun = 0.045
                }
                sliceMetrics = [pscustomobject]@{
                    common = [pscustomobject]@{ quality = 0.91 }
                    vi = [pscustomobject]@{ quality = 0.85 }
                }
                hardBlockerFailures = @()
            }
        )
        verdict = $null
    }

    Write-Suite $suitePath $suite
    $ready = Invoke-Resolver $suitePath
    if ($ready.code -ne 0 -or $ready.result.verdict -cne "ready") {
        throw "Valid comparable suite did not return ready."
    }

    $suite.results[1].sliceMetrics.vi.quality = 0.70
    Write-Suite $suitePath $suite
    $blocked = Invoke-Resolver $suitePath
    if ($blocked.code -ne 2 -or
        @($blocked.result.reasonCodes) -cnotcontains "slice-threshold-failed") {
        throw "Critical slice regression did not block."
    }

    $suite.results[1].sliceMetrics.vi.quality = 0.85
    $suite.results[1].environmentFingerprint = "env-2"
    Write-Suite $suitePath $suite
    $invalidComparison = Invoke-Resolver $suitePath
    if ($invalidComparison.code -ne 2 -or
        @($invalidComparison.result.reasonCodes) -cnotcontains "comparison-invalid") {
        throw "Incomparable environment did not block."
    }

    $suite.results[1].environmentFingerprint = "env-1"
    $suite.cases[0].sliceIds = @("undeclared")
    Write-Suite $suitePath $suite
    $invalidSuite = Invoke-Resolver $suitePath
    if ($invalidSuite.code -ne 2 -or
        @($invalidSuite.result.reasonCodes) -cnotcontains "suite-invalid") {
        throw "Invalid case reference did not fail closed."
    }

    Write-Host "OK executable AI evaluation verdict gate."
}
finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}
