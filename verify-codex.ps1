# PowerShell script to verify Codex is running from local installation
# Run: powershell -ExecutionPolicy Bypass -File verify-codex.ps1

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Codex Environment Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$PROJECT_ROOT = Split-Path -Parent $PSCommandPath
$CODEX_DIR = Join-Path $PROJECT_ROOT ".codex"
$CODEX_BIN_DIR = Join-Path $CODEX_DIR "node_modules\.bin"
$CODEX_BIN = Join-Path $CODEX_BIN_DIR "codex.cmd"
$CODEX_BIN_ALT = Join-Path $CODEX_BIN_DIR "codex"
$CODEX_HOME = Join-Path $CODEX_DIR "home"
$CONFIG_FILE = Join-Path $CODEX_HOME "config.toml"
$CENTRAL_CONFIG = Join-Path $CODEX_DIR "config.json"

Write-Host "Checking local installation..." -ForegroundColor Yellow
Write-Host ""

# Check if local binary exists (try both .cmd and no extension)
$codexBinary = $null
if (Test-Path $CODEX_BIN) {
    $codexBinary = $CODEX_BIN
} elseif (Test-Path $CODEX_BIN_ALT) {
    $codexBinary = $CODEX_BIN_ALT
}

if ($codexBinary) {
    Write-Host "[OK] Local Codex binary found" -ForegroundColor Green
    Write-Host "    Location: $codexBinary" -ForegroundColor Gray
} else {
    Write-Host "[X] Local Codex binary NOT found" -ForegroundColor Red
    Write-Host "    Expected: $CODEX_BIN or $CODEX_BIN_ALT" -ForegroundColor Yellow
    Write-Host "    Run: cd .codex; npm install" -ForegroundColor Yellow
}

Write-Host ""

# Check centralized config
if (Test-Path $CENTRAL_CONFIG) {
    Write-Host "[OK] Centralized config found" -ForegroundColor Green
    Write-Host "    Location: $CENTRAL_CONFIG" -ForegroundColor Gray
} else {
    Write-Host "[!] Centralized config not found (optional)" -ForegroundColor Yellow
    Write-Host "    Location: $CENTRAL_CONFIG" -ForegroundColor Gray
}

Write-Host ""

# Check config file
if (Test-Path $CONFIG_FILE) {
    Write-Host "[OK] Local config file found" -ForegroundColor Green
    Write-Host "    Location: $CONFIG_FILE" -ForegroundColor Gray
    
    # Read and show key config
    $configContent = Get-Content $CONFIG_FILE -Raw
    $modelMatch = $configContent -match 'model\s*=\s*"([^"]+)"'
    if ($modelMatch) {
        Write-Host "    Model: $($matches[1])" -ForegroundColor Gray
    }
    $providerMatch = $configContent -match 'model_provider\s*=\s*"([^"]+)"'
    if ($providerMatch) {
        Write-Host "    Provider: $($matches[1])" -ForegroundColor Gray
    }
} else {
    Write-Host "[X] Local config file NOT found" -ForegroundColor Red
    Write-Host "    Expected: $CONFIG_FILE" -ForegroundColor Yellow
}

Write-Host ""

# Check for global installation
Write-Host "Checking for global installation..." -ForegroundColor Yellow
$globalCodex = Get-Command codex -ErrorAction SilentlyContinue
if ($globalCodex) {
    Write-Host "[!] Global Codex installation detected" -ForegroundColor Yellow
    Write-Host "    Location: $($globalCodex.Source)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    To use LOCAL Codex, run: .\codex" -ForegroundColor Cyan
    Write-Host "    NOT: codex (this uses global)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] No global Codex installation found" -ForegroundColor Green
    Write-Host "    (This is fine - you will only use local)" -ForegroundColor Gray
}

Write-Host ""

# Check environment variables (if Codex is running)
Write-Host "Environment Variables (if Codex is running):" -ForegroundColor Yellow
$codexHome = [Environment]::GetEnvironmentVariable("CODEX_HOME")
if ($codexHome) {
    if ($codexHome -eq $CODEX_HOME) {
        Write-Host "[OK] CODEX_HOME is set to LOCAL path" -ForegroundColor Green
        Write-Host "    Value: $codexHome" -ForegroundColor Gray
    } else {
        Write-Host "[!] CODEX_HOME is set but points to different location" -ForegroundColor Yellow
        Write-Host "    Current: $codexHome" -ForegroundColor Gray
        Write-Host "    Expected: $CODEX_HOME" -ForegroundColor Gray
    }
} else {
    Write-Host "[!] CODEX_HOME not set (Codex may not be running)" -ForegroundColor Yellow
}

$xdgConfig = [Environment]::GetEnvironmentVariable("XDG_CONFIG_HOME")
if ($xdgConfig) {
    Write-Host "[OK] XDG_CONFIG_HOME is set" -ForegroundColor Green
    Write-Host "    Value: $xdgConfig" -ForegroundColor Gray
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true
if (-not $codexBinary) { $allGood = $false }
if (-not (Test-Path $CONFIG_FILE)) { $allGood = $false }

if ($allGood) {
    Write-Host "[OK] Local Codex installation is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To use local Codex, run:" -ForegroundColor Cyan
    Write-Host "  .\codex" -ForegroundColor White
    Write-Host "  or" -ForegroundColor Gray
    Write-Host "  .\codex --info" -ForegroundColor White
    Write-Host "    (to see local environment info)" -ForegroundColor Gray
} else {
    Write-Host "[X] Local Codex installation is incomplete" -ForegroundColor Red
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    if (-not $codexBinary) {
        Write-Host "  1. Install dependencies: cd .codex; npm install" -ForegroundColor Yellow
    }
    if (-not (Test-Path $CONFIG_FILE)) {
        Write-Host "  2. Run setup: .\.codex\setup.sh" -ForegroundColor Yellow
    }
}

Write-Host ""
