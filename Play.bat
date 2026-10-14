@echo off
rem Starts Minecraft (hidden, through ElyPrism/Prism), then Hello Neighbor. Leave this window open while you play.
title Minecraft in Hello Neighbor
if not exist "%~dp0settings.ini" echo Run Install.bat first. & pause & exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start_mod.ps1"
if errorlevel 1 echo. & echo It did not start; see the message above and the logs folder. & pause
