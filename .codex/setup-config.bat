@echo off
REM Setup script to copy example config files

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0setup-config.ps1"

pause
