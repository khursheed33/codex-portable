@echo off
REM Verify Codex is using local installation

echo.
echo ========================================
echo   Codex Environment Verification
echo ========================================
echo.

powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0verify-codex.ps1"

pause
