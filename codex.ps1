# PowerShell launcher for local Codex installation
# Run: powershell -ExecutionPolicy Bypass -File codex.ps1

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $PSCommandPath
$CODEX_DIR = Join-Path $SCRIPT_DIR ".codex"
$CODEX_BIN = Join-Path $CODEX_DIR "node_modules\.bin\codex.cmd"
$CODEX_BIN_ALT = Join-Path $CODEX_DIR "node_modules\.bin\codex"
$CODEX_HOME = Join-Path $CODEX_DIR "home"
# All config files are centralized in root directory
$CONFIG_JSON = Join-Path $SCRIPT_DIR "config.json"
$CONFIG_TOML = Join-Path $SCRIPT_DIR "codex.toml"
$ENV_FILE = Join-Path $SCRIPT_DIR ".env"

# Check if binary exists
$codexBinary = $null
if (Test-Path $CODEX_BIN) {
    $codexBinary = $CODEX_BIN
} elseif (Test-Path $CODEX_BIN_ALT) {
    $codexBinary = $CODEX_BIN_ALT
}

if (-not $codexBinary) {
    Write-Host "ERROR: Codex not installed. Run: cd .codex; npm install" -ForegroundColor Red
    exit 1
}

# Unset global environment variables
[Environment]::SetEnvironmentVariable("CODEX_HOME", $null, "Process")
[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $null, "Process")

# Load centralized config
$PROVIDER_TYPE = "azure"
$API_KEY_ENV = "AZURE_OPENAI_API_KEY"
$MODEL = "gpt-5.1-codex-mini"

if (Test-Path $CONFIG_JSON) {
    try {
        $config = Get-Content $CONFIG_JSON | ConvertFrom-Json
        if ($config.provider) {
            $PROVIDER_TYPE = $config.provider.type
            $API_KEY_ENV = $config.provider.api_key_env
            $MODEL = $config.provider.model
        }
    } catch {
        Write-Host "Warning: Could not parse config.json, using defaults" -ForegroundColor Yellow
    }
}

# Unset global API keys
[Environment]::SetEnvironmentVariable("AZURE_OPENAI_API_KEY", $null, "Process")
[Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $null, "Process")
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $null, "Process")

# Load .env file from root (centralized)
if (Test-Path $ENV_FILE) {
    Get-Content $ENV_FILE | ForEach-Object {
        if ($_ -match '^\s*([^#=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            if ($key -and $value) {
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }
}

# Check for API key
$apiKey = [Environment]::GetEnvironmentVariable($API_KEY_ENV, "Process")
if (-not $apiKey -or $apiKey -match "your-.*-key-here") {
    $fallbackKey = [Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "Process")
    if (-not $fallbackKey -or $fallbackKey -match "sk-your-key-here") {
        Write-Host "ERROR: Set $API_KEY_ENV or OPENAI_API_KEY in .env (root directory)" -ForegroundColor Red
        Write-Host "  Current provider: $PROVIDER_TYPE" -ForegroundColor Yellow
        Write-Host "  Expected env var: $API_KEY_ENV" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Make sure you're using: .\codex.ps1 (not just 'codex')" -ForegroundColor Yellow
        exit 1
    }
}

# Set Codex environment variables
[Environment]::SetEnvironmentVariable("CODEX_HOME", $CODEX_HOME, "Process")
[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $CODEX_DIR, "Process")
[Environment]::SetEnvironmentVariable("XDG_DATA_HOME", $CODEX_DIR, "Process")
[Environment]::SetEnvironmentVariable("CODEX_LOCAL_PROJECT", $SCRIPT_DIR, "Process")
# Always copy/link root codex.toml to where Codex expects it (at runtime)
# This ensures we always use the centralized config
if (Test-Path $CONFIG_TOML) {
    # Ensure .codex/home directory exists
    if (-not (Test-Path $CODEX_HOME)) {
        New-Item -ItemType Directory -Path $CODEX_HOME -Force | Out-Null
    }
    # Try symlink first (better), fallback to copy (works on Windows)
    try {
        New-Item -ItemType SymbolicLink -Path (Join-Path $CODEX_HOME "config.toml") -Target $CONFIG_TOML -Force | Out-Null
    } catch {
        Copy-Item $CONFIG_TOML (Join-Path $CODEX_HOME "config.toml") -Force | Out-Null
    }
} else {
    Write-Host "ERROR: Config file not found: $CONFIG_TOML" -ForegroundColor Red
    Write-Host "  Run: cd .codex; bash setup-config.sh" -ForegroundColor Yellow
    exit 1
}

[Environment]::SetEnvironmentVariable("CODEX_LOCAL_CONFIG", $CONFIG_TOML, "Process")

# Handle --info flag
if ($args -contains "--info" -or $args -contains "--local-info") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Codex Local Environment Information" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[OK] Running from LOCAL project installation" -ForegroundColor Green
    Write-Host ""
    Write-Host "Project Root:    $SCRIPT_DIR"
    Write-Host "Codex Binary:    $codexBinary"
    Write-Host "Config File:     $CONFIG_TOML (root)"
    Write-Host "Config Link:     $(Join-Path $CODEX_HOME 'config.toml')"
    Write-Host "Central Config:  $CONFIG_JSON (root)"
    Write-Host "Skills Dir:      $(Join-Path $CODEX_HOME 'skills')"
    Write-Host ""
    Write-Host "Provider Configuration:"
    Write-Host "  Type:           $PROVIDER_TYPE"
    Write-Host "  Model:          $MODEL"
    Write-Host "  API Key Env:    $API_KEY_ENV"
    $keyValue = [Environment]::GetEnvironmentVariable($API_KEY_ENV, "Process")
    if ($keyValue) {
        Write-Host "  API Key:        $($keyValue.Substring(0, [Math]::Min(10, $keyValue.Length)))... (set)"
    } else {
        Write-Host "  API Key:        (not set)"
    }
    Write-Host ""
    Write-Host "Environment Variables:"
    Write-Host "  CODEX_HOME:        $CODEX_HOME"
    Write-Host "  XDG_CONFIG_HOME:   $CODEX_DIR"
    Write-Host ""
    Write-Host "IMPORTANT: Always use '.\codex.ps1' or 'codex.bat' not 'codex'" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# Run Codex
& $codexBinary $args
