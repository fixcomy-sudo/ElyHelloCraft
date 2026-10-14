# Closes everything Play.bat started, the same clean way a Play.bat session ends when Hello Neighbor is closed:
# Hello Neighbor first, then Minecraft with its quit flag (a clean exit, so the launcher shows no "crashed"
# window), then the bridge and the launcher. Safe to run twice; harmless when nothing is running.
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "hn-common.ps1")

$settings = Read-Settings (Join-Path $root "settings.ini")
if ($settings.Count -eq 0) { Write-Output "settings.ini not found next to the scripts folder: run Install.bat first"; exit 1 }
$instance = $settings["Instance"]
$launcher = Get-LauncherFromSettings $settings
$exeName = [IO.Path]::GetFileNameWithoutExtension($launcher["Exe"])
$mcProcess = "*instances*$instance*"   # the launcher passes relative paths: no backslash before "instances"

function Stop-AndWait($names) {
    $p = Get-Process $names -ErrorAction SilentlyContinue
    if (-not $p) { return }
    $p | Stop-Process -Force -ErrorAction SilentlyContinue
    $p | ForEach-Object { try { $_.WaitForExit(15000) | Out-Null } catch {} }
}

# This instance's Minecraft only; other Java programs stay open.
function Get-OwnJava { Get-CimInstance Win32_Process -Filter "Name = 'java.exe' OR Name = 'javaw.exe'" | Where-Object { $_.CommandLine -like $mcProcess } }

Write-Output "closing Hello Neighbor"
Stop-AndWait @("HelloNeighbor-Win64-Shipping", "HelloNeighbor")

if (@(Get-OwnJava).Count -gt 0) {
    Write-Output "closing Minecraft (clean exit)"
    $flag = Join-Path ($launcher["Data"]) "instances\$instance\minecraft\hnmc-quit.flag"
    Set-Content $flag "quit"
    $until = (Get-Date).AddSeconds(30)
    while ((Get-Date) -lt $until -and @(Get-OwnJava).Count -gt 0) { Start-Sleep -Seconds 1 }
    foreach ($p in @(Get-OwnJava)) { Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue }
    Remove-Item $flag -Force -ErrorAction SilentlyContinue
}

Write-Output "closing the bridge and the launcher"
Stop-AndWait @("hn_bridge")
Stop-AndWait @($exeName)
Write-Output "everything is closed"
exit 0
