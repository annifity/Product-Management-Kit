function Get-FileHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$LiteralPath,

        [Parameter()]
        [ValidateSet("SHA256")]
        [string]$Algorithm = "SHA256"
    )

    process {
        foreach ($path in $LiteralPath) {
            $resolvedPath = (Resolve-Path -LiteralPath $path -ErrorAction Stop).ProviderPath
            $stream = [System.IO.File]::OpenRead($resolvedPath)
            $hasher = [System.Security.Cryptography.SHA256]::Create()
            try {
                $hashBytes = $hasher.ComputeHash($stream)
            }
            finally {
                $hasher.Dispose()
                $stream.Dispose()
            }

            [pscustomobject]@{
                Algorithm = $Algorithm
                Hash = ([System.BitConverter]::ToString($hashBytes) -replace "-", "")
                Path = $resolvedPath
            }
        }
    }
}
