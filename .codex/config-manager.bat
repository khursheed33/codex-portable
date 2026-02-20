@echo off
REM Codex Configuration Manager - Batch wrapper

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0config-manager.ps1" %*
