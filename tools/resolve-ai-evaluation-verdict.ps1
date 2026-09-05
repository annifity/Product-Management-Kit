[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$SuitePath,
    [string]$OutputPath,
    [switch]$AsJson
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$reasons = [System.Collections.Generic.List[string]]::new()

function Add-Reason {
    param([Parameter(Mandatory = $true)][string]$Code)
    if (-not $reasons.Contains($Code)) {
        $reasons.Add($Code)
    }
}

function Get-RequiredProperty {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )
    if ($null -eq $Object -or
        $null -eq $Object.PSObject.Properties[$Name]) {
        throw "$Context is missing '$Name'."
    }
    return $Object.$Name
}

function Get-RequiredText {
    param($Object, [string]$Name, [string]$Context)
    $value = [string](Get-RequiredProperty -Object $Object -Name $Name -Context $Context)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "$Context '$Name' must be non-empty."
    }
    return $value
}

function Get-RequiredNumber {
    param($Object, [string]$Name, [string]$Context)
    $value = Get-RequiredProperty -Object $Object -Name $Name -Context $Context
    if ($value -isnot [ValueType] -or $value -is [bool]) {
        throw "$Context '$Name' must be numeric."
    }
    return [double]$value
}

function Test-Rule {
    param([double]$Actual, [string]$Operator, [double]$Expected)
    switch ($Operator) {
        ">"  { return $Actual -gt $Expected }
        ">=" { return $Actual -ge $Expected }
        "<"  { return $Actual -lt $Expected }
        "<=" { return $Actual -le $Expected }
        "==" { return $Actual -eq $Expected }
        "!=" { return $Actual -ne $Expected }
        default { throw "Unsupported comparison operator '$Operator'." }
    }
}

function Test-MetricRule {
    param(
        $Metrics,
        $Rule,
        [string]$FailureCode,
        [string]$Context
    )
    $metric = Get-RequiredText -Object $Rule -Name "metric" -Context $Context
    $operator = Get-RequiredText -Object $Rule -Name "operator" -Context $Context
    $expected = Get-RequiredNumber -Object $Rule -Name "value" -Context $Context
    $actual = Get-RequiredNumber -Object $Metrics -Name $metric -Context "$Context metrics"
    if (-not (Test-Rule -Actual $actual -Operator $operator -Expected $expected)) {
        Add-Reason -Code $FailureCode
    }
}

try {
    $resolvedSuitePath = (Resolve-Path -LiteralPath $SuitePath).Path
    $suite = [System.IO.File]::ReadAllText($resolvedSuitePath) | ConvertFrom-Json
    if ([string](Get-RequiredProperty $suite "schemaVersion" "suite") -cne "1.0") {
        throw "suite schemaVersion must be '1.0'."
    }
    $suiteVersion = Get-RequiredText $suite "suiteVersion" "suite"
    $dataset = Get-RequiredProperty $suite "dataset" "suite"
    $datasetVersion = Get-RequiredText $dataset "version" "dataset"
    $sliceIds = @(
        Get-RequiredProperty $dataset "slices" "dataset" |
            ForEach-Object { [string]$_ }
    )
    if ($sliceIds.Count -eq 0 -or
        @($sliceIds | Sort-Object -Unique).Count -ne $sliceIds.Count) {
        throw "dataset slices must be non-empty and unique."
    }

    $graders = @(Get-RequiredProperty $suite "graders" "suite")
    $graderIds = @(
        $graders | ForEach-Object {
            Get-RequiredText $_ "graderId" "grader"
        }
    )
    if ($graderIds.Count -eq 0 -or
        @($graderIds | Sort-Object -Unique).Count -ne $graderIds.Count) {
        throw "grader IDs must be non-empty and unique."
    }

    $caseIds = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($case in @(Get-RequiredProperty $suite "cases" "suite")) {
        $caseId = Get-RequiredText $case "caseId" "case"
        if (-not $caseIds.Add($caseId)) {
            throw "duplicate case ID '$caseId'."
        }
        foreach ($sliceId in @(Get-RequiredProperty $case "sliceIds" "case '$caseId'")) {
            if ($sliceIds -cnotcontains [string]$sliceId) {
                throw "case '$caseId' references undeclared slice '$sliceId'."
            }
        }
        foreach ($graderId in @(Get-RequiredProperty $case "graderIds" "case '$caseId'")) {
            if ($graderIds -cnotcontains [string]$graderId) {
                throw "case '$caseId' references undeclared grader '$graderId'."
            }
        }
    }
    if ($caseIds.Count -eq 0) {
        throw "suite cases must be non-empty."
    }

    $thresholds = Get-RequiredProperty $suite "thresholds" "suite"
    $sliceRules = @(Get-RequiredProperty $thresholds "sliceRules" "thresholds")
    $ruledSlices = @($sliceRules | ForEach-Object {
        Get-RequiredText $_ "sliceId" "slice rule"
    })
    foreach ($sliceId in $sliceIds) {
        if ($ruledSlices -cnotcontains $sliceId) {
            throw "material slice '$sliceId' has no executable pass rule."
        }
    }

    $results = @(Get-RequiredProperty $suite "results" "suite")
    $baselineResults = @($results | Where-Object { [string]$_.role -ceq "baseline" })
    $candidateResults = @($results | Where-Object { [string]$_.role -ceq "candidate" })
    if ($baselineResults.Count -ne 1 -or $candidateResults.Count -ne 1) {
        throw "suite must contain exactly one baseline and one candidate result."
    }
    $baseline = $baselineResults[0]
    $candidate = $candidateResults[0]

    foreach ($result in @($baseline, $candidate)) {
        $role = Get-RequiredText $result "role" "result"
        foreach ($identity in @("suiteVersion", "datasetVersion", "environmentFingerprint")) {
            [void](Get-RequiredText $result $identity "$role result")
        }
        [void](Get-RequiredProperty $result "graderVersions" "$role result")
        [void](Get-RequiredProperty $result "metrics" "$role result")
        [void](Get-RequiredProperty $result "sliceMetrics" "$role result")
        [void](Get-RequiredProperty $result "hardBlockerFailures" "$role result")
    }

    $comparable = (
        [string]$baseline.suiteVersion -ceq $suiteVersion -and
        [string]$candidate.suiteVersion -ceq $suiteVersion -and
        [string]$baseline.datasetVersion -ceq $datasetVersion -and
        [string]$candidate.datasetVersion -ceq $datasetVersion -and
        [string]$baseline.environmentFingerprint -ceq
            [string]$candidate.environmentFingerprint -and
        (@($baseline.graderVersions) -join "`n") -ceq
            (@($candidate.graderVersions) -join "`n")
    )
    if (-not $comparable) {
        Add-Reason -Code "comparison-invalid"
    }

    foreach ($rule in @(Get-RequiredProperty $thresholds "overallRules" "thresholds")) {
        Test-MetricRule -Metrics $candidate.metrics -Rule $rule `
            -FailureCode "overall-threshold-failed" -Context "overall rule"
    }
    foreach ($rule in $sliceRules) {
        $sliceId = Get-RequiredText $rule "sliceId" "slice rule"
        $sliceProperty = $candidate.sliceMetrics.PSObject.Properties[$sliceId]
        if ($null -eq $sliceProperty) {
            throw "candidate result is missing slice '$sliceId'."
        }
        Test-MetricRule -Metrics $sliceProperty.Value -Rule $rule `
            -FailureCode "slice-threshold-failed" -Context "slice '$sliceId' rule"
    }
    foreach ($rule in @(
        Get-RequiredProperty $thresholds "nonRegressionRules" "thresholds"
    )) {
        $metric = Get-RequiredText $rule "metric" "non-regression rule"
        $maxDecline = Get-RequiredNumber $rule "maxDecline" "non-regression rule"
        $baselineValue = Get-RequiredNumber $baseline.metrics $metric "baseline metrics"
        $candidateValue = Get-RequiredNumber $candidate.metrics $metric "candidate metrics"
        if (($baselineValue - $candidateValue) -gt $maxDecline) {
            Add-Reason -Code "non-regression-failed"
        }
    }
    if (@($candidate.hardBlockerFailures).Count -gt 0) {
        Add-Reason -Code "hard-blocker-failed"
    }
    foreach ($budgetName in @("latencyBudget", "costBudget")) {
        if ($null -ne $thresholds.PSObject.Properties[$budgetName] -and
            $null -ne $thresholds.$budgetName) {
            Test-MetricRule -Metrics $candidate.metrics -Rule $thresholds.$budgetName `
                -FailureCode "$($budgetName.ToLowerInvariant())-failed" `
                -Context $budgetName
        }
    }
}
catch {
    Add-Reason -Code "suite-invalid"
    $diagnostic = $_.Exception.Message
}

$verdict = if ($reasons.Count -eq 0) { "ready" } else { "blocked" }
$output = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    verdict = $verdict
    reasonCodes = @($reasons)
    diagnostic = if ($null -ne (Get-Variable diagnostic -ErrorAction SilentlyContinue)) {
        $diagnostic
    } else {
        $null
    }
}
$json = $output | ConvertTo-Json -Depth 10
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path -Parent $OutputPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($OutputPath, "$json`n", $Utf8NoBom)
}
if ($AsJson) {
    Write-Output $json
} else {
    Write-Host "AI evaluation verdict: $verdict"
    if ($reasons.Count -gt 0) {
        Write-Host "Reasons: $($reasons -join ', ')"
    }
}
if ($verdict -ne "ready") {
    exit 2
}
