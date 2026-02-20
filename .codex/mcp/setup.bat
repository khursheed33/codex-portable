@echo off
chcp 65001 >nul 2>&1
REM MCP Servers Setup - Batch file wrapper

echo.
echo ========================================
echo   MCP Servers Setup
echo ========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%setup.ps1"

if not exist "%PS_SCRIPT%" (
    echo ERROR: setup.ps1 not found
    pause
    exit /b 1
)

echo Running setup script...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Setup failed with error code %ERRORLEVEL%
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Setup completed!
pause
