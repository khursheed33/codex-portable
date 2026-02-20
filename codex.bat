@echo off
REM Windows batch file wrapper for local Codex installation
REM This ensures Windows users can run codex easily

echo.
echo ========================================
echo   Using LOCAL Codex Installation
echo ========================================
echo.

REM Try PowerShell first (most reliable on Windows)
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0codex.ps1" %* 2>nul
if %ERRORLEVEL% EQU 0 exit /b 0

REM Fallback: Try to find bash (Git Bash or WSL)
where bash >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Running via bash...
    bash "%~dp0codex" %*
    exit /b %ERRORLEVEL%
)

REM If neither works, show error
echo ERROR: Could not find PowerShell or bash
echo.
echo Please use one of these:
echo   1. PowerShell: powershell -ExecutionPolicy Bypass -File codex.ps1
echo   2. Git Bash: bash codex
echo   3. Install Git for Windows: https://git-scm.com/download/win
echo.
pause
exit /b 1
