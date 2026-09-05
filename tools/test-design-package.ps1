[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "file-hash-compat.ps1")

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PowerShell = (Get-Process -Id $PID).Path
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("annifity-design-{0}" -f [guid]::NewGuid().ToString("N"))

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null
    $sourcePath = Join-Path $testRoot "accepted-spec.md"
    [System.IO.File]::WriteAllText(
        $sourcePath,
        "# OPS-SPEC-013@1.0`n`nREQ-101: A supervisor can view returned requests.`n",
        $Utf8NoBom
    )
    $sourceHash = "sha256:" + (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $contractFingerprint = "sha256:" + ("b" * 64)

    & (Join-Path $Root "tools/new-design-package.ps1") `
        -WorkspaceRoot $testRoot `
        -DesignId "OPS-DES-013" `
        -Title "Returned request review" `
        -SourceArtifactId "OPS-SPEC-013" `
        -SourceVersion "1.0" `
        -SourcePath "accepted-spec.md" `
        -SourceSha256 $sourceHash `
        -ContractFingerprint $contractFingerprint `
        -Mode "interactive-html" `
        -DesignAuthorityMode "free-design" `
        -DesignAuthoritySource "explicit:no-authoritative-design-system" `
        -DecisionOwner "role:product-owner" `
        -Destination "design-package" | Out-Null

    & (Join-Path $Root "tools/validate-design-package.ps1") `
        -WorkspaceRoot $testRoot `
        -PackagePath "design-package" | Out-Null

    $previewPath = Join-Path $testRoot "design-package/preview/index.html"
    $previewText = [System.IO.File]::ReadAllText($previewPath)
    [System.IO.File]::WriteAllText(
        $previewPath,
        ($previewText + "`n<script src=`"https://example.invalid/remote.js`"></script>`n"),
        $Utf8NoBom
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & $PowerShell `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File (Join-Path $Root "tools/validate-design-package.ps1") `
        -WorkspaceRoot $testRoot `
        -PackagePath "design-package" 1>$null 2>$null
    $invalidExitCode = $LASTEXITCODE
    $ErrorActionPreference = $previousErrorActionPreference
    $global:LASTEXITCODE = 0

    if ($invalidExitCode -eq 0) {
        throw "Design package validator must reject remote dependencies."
    }

    Write-Host "OK design package creation and validation tests passed."
}
finally {
    $tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd([char[]]"\/") +
        [System.IO.Path]::DirectorySeparatorChar
    $resolvedTestRoot = [System.IO.Path]::GetFullPath($testRoot)
    if (-not $resolvedTestRoot.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a test path outside the system temp directory."
    }
    if (Test-Path -LiteralPath $resolvedTestRoot) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
