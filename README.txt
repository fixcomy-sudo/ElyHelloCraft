Minecraft in Hello Neighbor
===========================

Play Hello Neighbor as a Minecraft player. Unofficial fan project; not affiliated with tinyBuild, Dynamic Pixels,
Mojang or Microsoft. You need your own copies of Hello Neighbor (Steam) and Minecraft: Java Edition.

Before you start
  1. Install ElyPrism Launcher (https://elyprismlauncher.github.io/), open it, sign in with your Microsoft account,
     then close it. (Prism Launcher also works if you do not have ElyPrism.)
  2. Hello Neighbor must be installed through Steam. Close it if it is running.

Install
  Double-click Install.bat. It finds Hello Neighbor and the launcher by itself and sets everything up.
  (Windows may warn about running a script or a program from the internet: choose "More info" > "Run anyway".)
  The first start downloads Minecraft and Java through the launcher, so it takes a few minutes and needs internet.

Play
  Double-click Play.bat and wait. Minecraft starts hidden, then Hello Neighbor opens. Load a level and play.
  Keep the Play.bat window open; close Hello Neighbor when you are done and everything shuts down by itself.

Controls
  Mouse, W A S D, Space, Shift, Ctrl, 1-9, E, Q, F5, T ... : as in Minecraft
  R (hold): pick up / interact      G: use the held item      X: throw the held item
  Right-click: doors, switches...   Space: also Hello Neighbor's "press Space" moments
  F: also sent to Hello Neighbor (you know where we need this 🥁🥁🥁)
  Esc: Hello Neighbor's menu        F4: Minecraft movement on / off      F6: redraw Minecraft's blocks
  /hnreset (in the chat): remove your blocks, mobs and dropped items and get the starting kit back

Your name
  The name in chat and death messages is your Minecraft account name. To use another one, set playerName in
  <launcher data>\instances\HelloCraft\minecraft\config\hnmc.properties (usually
  %APPDATA%\ElyPrismLauncher\instances\HelloCraft\minecraft\config\hnmc.properties).

Safety
  - The mod runs on your PC only: it has no network code and never touches your Minecraft login (the launcher handles
    that). Minecraft runs a private single-player world that is not open to LAN or the internet.
  - It does change Hello Neighbor's folder (UE4SS, two mods, and a few small files it writes there) and adds one
    launcher instance. Nothing else on your PC is touched. Files it replaces are kept as *.before-hnmc;
    Uninstall.bat removes it.
  - Antivirus programs or Windows SmartScreen may warn: the mod hooks the game's graphics, and UE4SS loads as a
    dwmapi.dll next to the game. The source code is public, and the release page lists the zip's SHA-256 checksum so
    you can check your download (PowerShell: Get-FileHash the zip).
  - Only use it in single-player. Do not use it with an online or multiplayer game.

Problems
  The logs folder next to Play.bat has the bridge's output. Hello Neighbor's own logs are in
  <Hello Neighbor>\HelloNeighbor\Binaries\Win64 (hn_gfx.log, ue4ss\UE4SS.log). Please attach them to a bug report.
  Uninstall.bat removes everything the installer added to Hello Neighbor and the launcher, including UE4SS if the
  installer put it there (a UE4SS you had before stays, with its replaced files put back).

Licences: see LICENSE and THIRD-PARTY-NOTICES.txt. Source: see the project page on GitHub.
