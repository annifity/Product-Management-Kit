[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$TaskPath,
    [Parameter(Mandatory = $true)][string]$ResultPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$task = [System.IO.File]::ReadAllText(
    (Resolve-Path -LiteralPath $TaskPath).Path
) | ConvertFrom-Json
$result = [pscustomobject][ordered]@{
    schemaVersion = "1.0"
    caseId = [string]$task.caseId
    runId = [string]$task.runId
    contextId = "mock-evaluator-$($task.runId)"
    independentContext = $true
    sawExpectedAnswer = $false
    usabilityScore = 4
    usabilityReason = "Clear and directly actionable."
}
[System.IO.File]::WriteAllText(
    $ResultPath,
    (($result | ConvertTo-Json -Depth 10) + "`n"),
    $Utf8NoBom
)
