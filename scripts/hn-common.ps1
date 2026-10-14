# Shared by start_mod.ps1, install.ps1 and uninstall.ps1 (dot-sourced): finding Hello Neighbor and the launcher
# (ElyPrism / PineconeMC, with Prism Launcher as a fallback).

# Hello Neighbor's folder: every Steam library listed in steamapps\libraryfolders.vdf, looking for "Hello Neighbor".
function Find-HelloNeighbor {
    $steam = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if (-not $steam) { return $null }
    $libs = @($steam)
    $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) {
        foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += $m.Groups[1].Value -replace '\\\\', '\' }
    }
    foreach ($l in $libs) {
        $d = Join-Path $l "steamapps\common\Hello Neighbor"
        if (Test-Path (Join-Path $d "HelloNeighbor\Binaries\Win64")) { return $d }
    }
    return $null
}

# The launcher's exe (ElyPrism first, then Prism Launcher): the default install folder, the uninstall registry
# entries, Program Files.
function Find-Launcher {
    $cands = @(
        (Join-Path $env:LOCALAPPDATA "Programs\ElyPrismLauncher\elyprismlauncher.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\PrismLauncher\prismlauncher.exe")
    )
    foreach ($key in "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*") {
        foreach ($e in Get-ItemProperty $key -ErrorAction SilentlyContinue) {
            if ($e.DisplayName -like "ElyPrism*" -and $e.InstallLocation) { $cands += Join-Path $e.InstallLocation "elyprismlauncher.exe" }
            elseif ($e.DisplayName -like "Prism Launcher*" -and $e.InstallLocation) { $cands += Join-Path $e.InstallLocation "prismlauncher.exe" }
        }
    }
    $cands += "C:\Program Files\ElyPrismLauncher\elyprismlauncher.exe"
    $cands += "C:\Program Files\PrismLauncher\prismlauncher.exe"
    foreach ($c in $cands) { if (Test-Path $c) { return $c } }
    return $null
}

# Where the launcher keeps its instances: next to the program for a portable install, else %APPDATA%\<folder name>
# (ElyPrismLauncher for ElyPrism, PrismLauncher for Prism).
function Get-LauncherData($launcherExe) {
    $dir = Split-Path -Parent $launcherExe
    if (Test-Path (Join-Path $dir "portable.txt")) { return $dir }
    $n = [IO.Path]::GetFileNameWithoutExtension($launcherExe)
    $name = if ($n -eq "elyprismlauncher") { "ElyPrismLauncher" } else { "PrismLauncher" }
    return Join-Path $env:APPDATA $name
}

# The launcher exe and its data folder from settings.ini (LauncherExe/LauncherData; the older PrismExe/PrismData
# keys are still read for settings files written by earlier installs).
function Get-LauncherFromSettings($s) {
    $exe = $s["LauncherExe"]; if (-not $exe) { $exe = $s["PrismExe"] }
    $data = $s["LauncherData"]; if (-not $data) { $data = $s["PrismData"] }
    return @{ Exe = $exe; Data = $data }
}

# settings.ini written by install.ps1: one "key=value" per line.
function Read-Settings($file) {
    $s = @{}
    if (Test-Path $file) {
        foreach ($l in Get-Content $file) { if ($l -match '^\s*([^#;=\s][^=]*?)\s*=\s*(.*?)\s*$') { $s[$Matches[1]] = $Matches[2] } }
    }
    return $s
}
