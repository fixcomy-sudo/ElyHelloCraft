# Installs the mod: UE4SS + the two Hello Neighbor mods into the game, and a launcher instance (ElyPrism / Prism)
# for the Minecraft part. Run through Install.bat. Safe to run again (it also updates an earlier install).
#   -HnDir / -LauncherExe / -LauncherData: only needed when they are not found by themselves (or for testing)
param([string]$HnDir, [string]$LauncherExe, [string]$LauncherData)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "hn-common.ps1")
$files = Join-Path $root "files"
$id = "HelloCraft"

function Ask($what) { $a = (Read-Host $what).Trim().Trim('"'); if (-not $a) { throw "Cancelled." }; $a }
function Same($a, $b) { (Test-Path $b) -and ((Get-FileHash $a).Hash -eq (Get-FileHash $b).Hash) }

# ---- Hello Neighbor ----
if (-not $HnDir) { $HnDir = Find-HelloNeighbor }
if (-not $HnDir) {
    Write-Output "Hello Neighbor was not found through Steam."
    $HnDir = Ask "Paste the folder of Hello Neighbor (the one that contains 'HelloNeighbor')"
}
$win64 = Join-Path $HnDir "HelloNeighbor\Binaries\Win64"
if (-not (Test-Path (Join-Path $win64 "HelloNeighbor-Win64-Shipping.exe"))) { throw "Not a Hello Neighbor folder: $HnDir" }
if (Get-Process HelloNeighbor-Win64-Shipping -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "$win64*" }) { throw "Hello Neighbor is running. Close it and run the installer again." }
Write-Output "Hello Neighbor: $HnDir"

# ---- the launcher (ElyPrism, or Prism Launcher) ----
if (-not $LauncherExe) { $LauncherExe = Find-Launcher }
if (-not $LauncherExe) {
    Write-Output "ElyPrism / Prism Launcher was not found. Install ElyPrism (sign in with your Microsoft account once), or paste its elyprismlauncher.exe."
    $LauncherExe = Ask "Path to elyprismlauncher.exe"
}
if (-not (Test-Path $LauncherExe)) { throw "Not found: $LauncherExe" }
if (-not $LauncherData) { $LauncherData = Get-LauncherData $LauncherExe }
if (-not (Test-Path (Join-Path $LauncherData "instances"))) { throw "The launcher has not been started yet (no instances folder in $LauncherData). Open it once, sign in, close it, and run the installer again." }
Write-Output "Launcher: $LauncherExe"

# ---- UE4SS and the two mods, into Hello Neighbor ----
$game = Join-Path $files "game"
$ue = Join-Path $win64 "ue4ss"
# What this install added (paths relative to Win64), so Uninstall.bat removes exactly that. Kept across re-installs.
$addedFile = Join-Path $root "installed.txt"
$added = [System.Collections.Generic.List[string]]::new()
if (Test-Path $addedFile) { foreach ($l in Get-Content $addedFile) { if ($l) { $added.Add($l) } } }
function Track($rel) { if (-not (Test-Path (Join-Path $win64 $rel)) -and -not $added.Contains($rel)) { $added.Add($rel) } }
Track "ue4ss"; Track "ue4ss\Mods"
New-Item -ItemType Directory -Force (Join-Path $ue "Mods") | Out-Null

# UE4SS itself. This exact build is the one the mod was tested with; a different one already installed is kept as a backup.
foreach ($f in "dwmapi.dll", "ue4ss\UE4SS.dll") {
    $from = Join-Path $game $f; $to = Join-Path $win64 $f
    if (Same $from $to) { continue }
    if ((Test-Path $to) -and -not (Test-Path "$to.before-hnmc")) { Copy-Item $to "$to.before-hnmc" }
    Track $f
    Copy-Item $from $to -Force
}
foreach ($f in "ue4ss\LICENSE", "ue4ss\UE4SS_SDK_Backends") { Track $f; Copy-Item (Join-Path $game $f) (Split-Path -Parent (Join-Path $win64 $f)) -Recurse -Force }

# Settings: keep an existing file, only turn hot reload off (a hot reload while the mod runs freezes the game)...
$ini = Join-Path $ue "UE4SS-settings.ini"
if (Test-Path $ini) {
    $t = Get-Content $ini -Raw
    # ...and its console window off: it opens with every Hello Neighbor start, with or without Minecraft (the same
    # lines still go to ue4ss\UE4SS.log).
    $n = $t -replace '(?m)^(\s*EnableHotReloadSystem\s*=\s*)1\b', '${1}0'
    $n = $n -replace '(?m)^(\s*(ConsoleEnabled|GuiConsoleEnabled|GuiConsoleVisible)\s*=\s*)1\b', '${1}0'
    if ($n -ne $t) {
        if (-not (Test-Path "$ini.before-hnmc")) { Copy-Item $ini "$ini.before-hnmc" }
        Set-Content $ini $n -NoNewline; Write-Output "UE4SS: hot reload and the console window switched off"
    }
} else {
    Track "ue4ss\UE4SS-settings.ini"
    Copy-Item (Join-Path $game "ue4ss\UE4SS-settings.ini") $ini
}

# UE4SS's standard mods: only the ones that are missing. Ours always replace the old ones.
foreach ($m in Get-ChildItem (Join-Path $game "ue4ss\Mods") -Directory) {
    $rel = "ue4ss\Mods\$($m.Name)"
    if ($m.Name -in "HnLink", "HnGfx") { Track $rel; Copy-Item $m.FullName (Join-Path $ue "Mods") -Recurse -Force }
    elseif (-not (Test-Path (Join-Path $win64 $rel))) { Track $rel; Copy-Item $m.FullName (Join-Path $ue "Mods") -Recurse }
}
$modsJson = Join-Path $ue "Mods\mods.json"
if (-not (Test-Path $modsJson)) { Track "ue4ss\Mods\mods.json"; Copy-Item (Join-Path $game "ue4ss\Mods\mods.json") $modsJson }

# mods.txt: our two lines go above the built-in "Keybinds" line. (BPModLoaderMod is for blueprint mods and only logs an
# error on this game, which has no Content\Paks folder, so a new UE4SS install leaves it off.)
$modsTxt = Join-Path $ue "Mods\mods.txt"
if ((Test-Path $modsTxt) -and -not (Test-Path "$modsTxt.before-hnmc")) { Copy-Item $modsTxt "$modsTxt.before-hnmc" }
Track "ue4ss\Mods\mods.txt"
$lines = if (Test-Path $modsTxt) { @(Get-Content $modsTxt) } else {
    @("CheatManagerEnablerMod : 1", "ConsoleCommandsMod : 1", "ConsoleEnablerMod : 1", "BPML_GenericFunctions : 1", "BPModLoaderMod : 0", "", "; Built-in keybinds, do not move up!", "Keybinds : 1")
}
$list = [System.Collections.Generic.List[string]]::new()
foreach ($l in $lines) { if ($l -notmatch '^\s*(HnLink|HnGfx)\s*:') { $list.Add($l) } }
$k = $list.FindIndex([Predicate[string]] { param($l) $l -match '^\s*Keybinds\s*:' })
if ($k -lt 0) { $k = $list.Count }
if ($k -gt 0 -and $list[$k - 1] -match '^\s*;') { $k-- }   # keep the comment that belongs to the Keybinds line below ours
$list.InsertRange($k, [string[]]@("HnLink : 1", "HnGfx : 1"))
Set-Content $modsTxt $list
Set-Content $addedFile $added
Write-Output "Hello Neighbor: mod files installed"

# ---- the launcher instance ----
$tpl = Join-Path $files "instance"
$inst = Join-Path $LauncherData "instances\$id"
$mods = Join-Path $inst "minecraft\mods"
if (-not (Test-Path $inst)) {
    New-Item -ItemType Directory -Force $inst | Out-Null
    Copy-Item (Join-Path $tpl "instance.cfg"), (Join-Path $tpl "mmc-pack.json") $inst
    Copy-Item (Join-Path $tpl "minecraft") $inst -Recurse
} else {
    # An earlier install: the launcher adds its own lines to instance.cfg (play time, Java found), so only our Java
    # arguments are brought up to date.
    $cfg = Join-Path $inst "instance.cfg"
    $want = @(Get-Content (Join-Path $tpl "instance.cfg") | Where-Object { $_ -match '^(OverrideJavaArgs|JvmArgs)=' })
    $have = @(Get-Content $cfg | Where-Object { $_ -notmatch '^(OverrideJavaArgs|JvmArgs)=' })
    $g = [array]::IndexOf($have, "[General]")
    if ($g -lt 0) { $have = @("[General]") + $have; $g = 0 }
    Set-Content $cfg @($have[0..$g] + $want + $(if ($g + 1 -lt $have.Count) { $have[($g + 1)..($have.Count - 1)] } else { @() }))
}
New-Item -ItemType Directory -Force $mods | Out-Null
Get-ChildItem $mods -Filter "*.jar" | Where-Object { $_.Name -like "hnmc-*" -or $_.Name -like "fabric-api-*" } | Remove-Item -Force
Copy-Item (Join-Path $tpl "minecraft\mods\*.jar") $mods
Write-Output "Launcher: instance 'HelloCraft' installed"

# ---- remembered for Play.bat ----
Set-Content (Join-Path $root "settings.ini") @("# written by the installer; delete this file and run Install.bat again to change it",
    "HnDir=$HnDir", "LauncherExe=$LauncherExe", "LauncherData=$LauncherData", "Instance=$id")
Write-Output ""
Write-Output "Done. Start the game with Play.bat."
