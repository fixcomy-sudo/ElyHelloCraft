# Removes the mod: everything the installer added to Hello Neighbor (listed in installed.txt), so a UE4SS that the
# installer put there goes too, while a UE4SS that was there before stays (with any file the installer replaced
# restored from its *.before-hnmc copy), and the launcher instance.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "hn-common.ps1")
$s = Read-Settings (Join-Path $root "settings.ini")
if ($s.Count -eq 0) { throw "Nothing to remove: settings.ini (written by the installer) is missing." }
$win64 = Join-Path $s["HnDir"] "HelloNeighbor\Binaries\Win64"
if (Get-Process HelloNeighbor-Win64-Shipping -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$win64*" }) { throw "Hello Neighbor is running. Close it and run this again." }
$ue = Join-Path $win64 "ue4ss"

# Our two mods and their lines in mods.txt (other mods' lines stay).
foreach ($m in "HnLink", "HnGfx") { Remove-Item (Join-Path $ue "Mods\$m") -Recurse -Force -ErrorAction SilentlyContinue }
$modsTxt = Join-Path $ue "Mods\mods.txt"
if (Test-Path $modsTxt) { Set-Content $modsTxt @(Get-Content $modsTxt | Where-Object { $_ -notmatch '^\s*(HnLink|HnGfx)\s*:' }) }
Remove-Item "$modsTxt.before-hnmc" -Force -ErrorAction SilentlyContinue

# Files the installer replaced: put the earlier ones back.
foreach ($f in "dwmapi.dll", "ue4ss\UE4SS.dll", "ue4ss\UE4SS-settings.ini") {
    $p = Join-Path $win64 $f
    if (Test-Path "$p.before-hnmc") { Move-Item "$p.before-hnmc" $p -Force }
}

# Everything the installer added, newest first; only paths inside Win64 (installed.txt is a plain text file).
$addedFile = Join-Path $root "installed.txt"
$added = if (Test-Path $addedFile) { @(Get-Content $addedFile | Where-Object { $_ }) } else { @() }
[array]::Reverse($added)
$fresh = $added -contains "ue4ss"
foreach ($rel in $added) {
    if ($rel -match '\.\.|^[\\/]|:') { continue }
    $p = Join-Path $win64 $rel
    if ($rel -in "ue4ss", "ue4ss\Mods") { continue }   # folders: below, and only if nothing else is left in them
    Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
}
if ($fresh) {
    # UE4SS came with this mod: its own logs and leftovers go too, then the folders if they are empty now.
    foreach ($f in "UE4SS.log", "imgui.ini") { Remove-Item (Join-Path $ue $f) -Force -ErrorAction SilentlyContinue }
    Get-ChildItem $ue -Filter "crash_*.dmp" -ErrorAction SilentlyContinue | Remove-Item -Force
    foreach ($d in (Join-Path $ue "Mods"), $ue) {
        if ((Test-Path $d) -and -not (Get-ChildItem $d -Force)) { Remove-Item $d -Force }
    }
}

# Files the mod itself writes next to the game.
foreach ($f in "hn_camera.txt", "hn_keys.txt", "hn_world_status.txt", "hn_respawn.txt", "hn_gfx.log",
               "hnlink_trace_breadcrumb.txt", "hnlink_trace_broken.txt") {
    Remove-Item (Join-Path $win64 $f) -Force -ErrorAction SilentlyContinue
}

# Only our own instance, by its fixed name and only if it holds our jar (settings.ini is a plain text file anyone can edit).
$data = (Get-LauncherFromSettings $s)["Data"]
$inst = Join-Path $data "instances\HelloCraft"
if (Test-Path (Join-Path $inst "minecraft\mods\hnmc-*.jar")) {
    Remove-Item $inst -Recurse -Force -ErrorAction SilentlyContinue
}
Remove-Item (Join-Path $root "settings.ini"), $addedFile -Force -ErrorAction SilentlyContinue
if ($fresh) { Write-Output "Removed the mod and UE4SS. You can delete this folder now." }
else { Write-Output "Removed the mod. UE4SS was installed before, so it stays. You can delete this folder now." }
