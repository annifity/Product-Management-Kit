[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

Push-Location $Root
try {
    if (Get-Command npx -ErrorAction SilentlyContinue) {
        npx lefthook install
        Write-Host "Configured Lefthook."
    }
    else {
        git -C $Root config core.hooksPath .githooks
        Write-Host "npx not found. Configured fallback git hooks path: .githooks"
    }
}
finally {
    Pop-Location
}
