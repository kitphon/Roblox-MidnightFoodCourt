[CmdletBinding()]
param(
    [ValidateRange(1, 65535)]
    [int]$Port = 34872,
    [switch]$RequireBaseline
)

$ErrorActionPreference = "Stop"
$bridgeStatusPath = Join-Path $PSScriptRoot "..\.sync\status.json"
if (Test-Path -LiteralPath $bridgeStatusPath) {
    throw "This repo uses the two-way Midnight bridge. Run tools/start_sync.ps1; do not run competing Rojo live writers."
}
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$project = Join-Path $root "default.project.json"
$rojo = Join-Path $root ".tools\rojo.exe"
$verifier = Join-Path $root "tools\verify_repository.py"
$safeRoot = $root.Replace("\", "/")

Push-Location $root
try {
    if (-not (Test-Path -LiteralPath $rojo -PathType Leaf)) {
        throw "Pinned Rojo is missing. Run: python tools/bootstrap_rojo.py"
    }

    $unmerged = @(git -c "safe.directory=$safeRoot" ls-files -u)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to inspect Git conflict state."
    }
    if ($unmerged.Count -gt 0) {
        throw "Git has unresolved merge conflicts. Rojo sync was not started."
    }

    $markerFiles = @(
        Get-ChildItem -Path "src", "docs", "tools" -Recurse -File |
            Select-String -Pattern '^(<<<<<<<|=======|>>>>>>>)' -List |
            Select-Object -ExpandProperty Path
    )
    if ($markerFiles.Count -gt 0) {
        throw "Conflict markers found. Rojo sync was not started:`n$($markerFiles -join "`n")"
    }

    $verifyArgs = @($verifier)
    if ($RequireBaseline) {
        $verifyArgs += "--baseline"
    }
    & python @verifyArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Repository verification failed. Rojo sync was not started."
    }

    $version = (& $rojo --version).Trim()
    if ($version -ne "Rojo 7.7.1") {
        throw "Expected Rojo 7.7.1, found '$version'."
    }

    Write-Host "Preflight passed. Starting Rojo at localhost:$Port"
    Write-Host "Review the Studio plugin change preview before connecting. Press Ctrl+C to stop."
    & $rojo serve $project --port $Port
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
