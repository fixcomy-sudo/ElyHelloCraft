@echo off
rem Installs Minecraft in Hello Neighbor (Hello Neighbor is found through Steam).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1"
if errorlevel 1 echo. & echo The installation did not finish; see the message above.
echo.
pause
