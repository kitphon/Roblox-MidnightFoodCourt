[CmdletBinding()]
param([switch]$Restart)
$ErrorActionPreference="Stop"
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Push-Location $repoRoot
try {
    python tools/setup_sync.py
    if ($LASTEXITCODE -ne 0) { throw "Sync setup failed" }
    try {
        $existing=Invoke-RestMethod 'http://127.0.0.1:34875/status' -TimeoutSec 2
        if ($existing.state -and -not $Restart) { Write-Host "Sync server already running on 34875"; return }
        if ($existing.state -and $Restart) {
            python tools/sync_bridge.py stop
            if ($LASTEXITCODE -ne 0) { throw "Could not stop existing sync server" }
            Start-Sleep -Milliseconds 750
        }
    } catch { }
    $logRoot=Join-Path $repoRoot ".sync"
    $pythonExe=(Get-Command python).Source
    Start-Process -FilePath $pythonExe -ArgumentList @("-u","tools/sync_bridge.py","serve") -WorkingDirectory $repoRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $logRoot "server.log") -RedirectStandardError (Join-Path $logRoot "server-error.log")
    Write-Host "Started Midnight two-way script sync. Status: http://127.0.0.1:34875/status"
} finally { Pop-Location }
