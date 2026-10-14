@echo off
rem Opens the HelloCraft GUI. Uses python.exe (NOT pythonw): without a console
rem WebView2 draws a blank window. HelloCraft.py hides its own console on start.
title HelloCraft GUI
if exist "%LocalAppData%\Programs\Python\Python311\python.exe" (
    start "" "%LocalAppData%\Programs\Python\Python311\python.exe" "%~dp0HelloCraft.py"
    exit /b 0
)
where py >nul 2>nul
if not errorlevel 1 (
    start "" py "%~dp0HelloCraft.py"
    exit /b 0
)
start "" python "%~dp0HelloCraft.py"
