@echo off
rem Closes everything Play.bat started, the clean way: Hello Neighbor, then Minecraft (a clean exit, no
rem "crashed" window in the launcher), then the bridge and the launcher. Double-click to stop playing.
title Stop HelloCraft
if not exist "%~dp0settings.ini" echo Run Install.bat first. & pause & exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\stop_mod.ps1"
pause
