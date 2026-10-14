@echo off
rem Removes Minecraft in Hello Neighbor from Hello Neighbor and from the launcher (ElyPrism/Prism).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\uninstall.ps1"
echo.
pause
