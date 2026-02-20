# Setup script to copy example config files if they don't exist
# Run: powershell -ExecutionPolicy Bypass -File .codex\setup-config.ps1

$PROJECT_ROOT = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$CONFIG_JSON = Join-Path $PROJECT_ROOT "config.json"
$CONFIG_JSON_EXAMPLE = Join-Path $PROJECT_ROOT "config.json.example"
$CODEX_TOML = Join-Path $PROJECT_ROOT "codex.toml"
$CODEX_TOML_EXAMPLE = Join-Path $PROJECT_ROOT "codex.toml.example"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Codex Configuration Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Copy config.json if it doesn't exist
if (-not (Test-Path $CONFIG_JSON)) {
    if (Test-Path $CONFIG_JSON_EXAMPLE) {
        Copy-Item $CONFIG_JSON_EXAMPLE $CONFIG_JSON
        Write-Host "[OK] Created config.json from example" -ForegroundColor Green
        Write-Host "     Edit config.json and update with your values" -ForegroundColor Yellow
    } else {
        Write-Host "[!] config.json.example not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] config.json already exists" -ForegroundColor Green
}

# Copy codex.toml if it doesn't exist
if (-not (Test-Path $CODEX_TOML)) {
    if (Test-Path $CODEX_TOML_EXAMPLE) {
        Copy-Item $CODEX_TOML_EXAMPLE $CODEX_TOML
        Write-Host "[OK] Created codex.toml from example" -ForegroundColor Green
        Write-Host "     Edit codex.toml and update with your values" -ForegroundColor Yellow
    } else {
        Write-Host "[!] codex.toml.example not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] codex.toml already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Edit config.json and update:" -ForegroundColor White
Write-Host "     - base_url: Your Azure deployment URL" -ForegroundColor Gray
Write-Host "     - model: Your deployment name" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Edit codex.toml and update:" -ForegroundColor White
Write-Host "     - base_url: Your Azure deployment URL" -ForegroundColor Gray
Write-Host "     - model: Your deployment name" -ForegroundColor Gray
Write-Host "     - Project paths: Update to match your project" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Set your API key in .env (root directory):" -ForegroundColor White
Write-Host "     AZURE_OPENAI_API_KEY=your-key-here" -ForegroundColor Gray
Write-Host ""
