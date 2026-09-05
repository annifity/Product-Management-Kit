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
    contextId = "mock-candidate-$($task.runId)"
    freshContext = $true
    additionalContextUsed = $false
    sourceHashes = $task.sourceHashes
    output = @"
# OFF-004@1.0 - Offboarding

Keep one story named Offboarding for People Operations. Refine wording without
changing the accepted scope.
"@
}
[System.IO.File]::WriteAllText(
    $ResultPath,
    (($result | ConvertTo-Json -Depth 12) + "`n"),
    $Utf8NoBom
)
