# Codex Configuration Manager
# Manages centralized configuration for Codex

param(
    [Parameter(Position=0)]
    [string]$Action = "show",
    
    [Parameter()]
    [string]$Provider,
    
    [Parameter()]
    [string]$ApiKey,
    
    [Parameter()]
    [string]$Model,
    
    [Parameter()]
    [string]$McpServer,
    
    [Parameter()]
    [switch]$Enable,
    
    [Parameter()]
    [switch]$Disable
)

$CONFIG_FILE = Join-Path $PSScriptRoot "config.json"
$ENV_FILE = Join-Path $PSScriptRoot ".env"

function Show-Config {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Codex Configuration" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Test-Path $CONFIG_FILE)) {
        Write-Host "Config file not found. Creating default..." -ForegroundColor Yellow
        Initialize-Config
    }
    
    $config = Get-Content $CONFIG_FILE | ConvertFrom-Json
    
    Write-Host "Provider:" -ForegroundColor Yellow
    Write-Host "  Type: $($config.provider.type)" -ForegroundColor White
    Write-Host "  Model: $($config.provider.model)" -ForegroundColor White
    Write-Host "  API Key Env: $($config.provider.api_key_env)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "MCP Servers:" -ForegroundColor Yellow
    foreach ($server in $config.mcp_servers.enabled) {
        $status = if ($config.mcp_servers.$server.enabled) { "Enabled" } else { "Disabled" }
        Write-Host "  $server : $status" -ForegroundColor White
    }
    Write-Host ""
    
    Write-Host "Features:" -ForegroundColor Yellow
    foreach ($feature in $config.features.PSObject.Properties) {
        $status = if ($feature.Value) { "Enabled" } else { "Disabled" }
        Write-Host "  $($feature.Name) : $status" -ForegroundColor White
    }
    Write-Host ""
}

function Initialize-Config {
    $defaultConfig = @{
        provider = @{
            type = "azure"
            api_key_env = "AZURE_OPENAI_API_KEY"
            model = "gpt-5.1-codex-mini"
            base_url = "https://asimovgenai.openai.azure.com/openai"
            api_version = "2025-04-01-preview"
        }
        overrides = @{
            model = $null
            model_provider = $null
            approval_policy = $null
            sandbox_mode = $null
        }
        mcp_servers = @{
            enabled = @("filesystem")
            filesystem = @{
                enabled = $true
                args = @(".", ".codex/home/skills")
            }
        }
        features = @{
            powershell_utf8 = $true
            shell_snapshot = $true
            collaboration_modes = $true
            multi_agent = $true
            web_search = $false
        }
    }
    
    $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
    Write-Host "Default config created at: $CONFIG_FILE" -ForegroundColor Green
}

function Set-Provider {
    param([string]$ProviderType, [string]$ApiKeyEnv, [string]$Model, [string]$BaseUrl, [string]$ApiVersion)
    
    if (-not (Test-Path $CONFIG_FILE)) {
        Initialize-Config
    }
    
    $config = Get-Content $CONFIG_FILE | ConvertFrom-Json
    
    if ($ProviderType) {
        $config.provider.type = $ProviderType
    }
    if ($ApiKeyEnv) {
        $config.provider.api_key_env = $ApiKeyEnv
    }
    if ($Model) {
        $config.provider.model = $Model
    }
    if ($BaseUrl) {
        $config.provider.base_url = $BaseUrl
    }
    if ($ApiVersion) {
        $config.provider.api_version = $ApiVersion
    }
    
    $config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
    Write-Host "Provider configuration updated" -ForegroundColor Green
}

function Set-ApiKey {
    param([string]$Key)
    
    if (-not $Key) {
        Write-Host "ERROR: API key not provided" -ForegroundColor Red
        return
    }
    
    if (-not (Test-Path $CONFIG_FILE)) {
        Initialize-Config
    }
    
    $config = Get-Content $CONFIG_FILE | ConvertTo-Json | ConvertFrom-Json
    $envVarName = $config.provider.api_key_env
    
    # Update .env file
    $envContent = @()
    if (Test-Path $ENV_FILE) {
        $envContent = Get-Content $ENV_FILE
        $updated = $false
        for ($i = 0; $i -lt $envContent.Length; $i++) {
            if ($envContent[$i] -match "^$envVarName=") {
                $envContent[$i] = "$envVarName=$Key"
                $updated = $true
                break
            }
        }
        if (-not $updated) {
            $envContent += "$envVarName=$Key"
        }
    } else {
        $envContent = "$envVarName=$Key"
    }
    
    $envContent | Set-Content $ENV_FILE
    Write-Host "API key updated in .env file" -ForegroundColor Green
    Write-Host "  Variable: $envVarName" -ForegroundColor Gray
}

function Toggle-McpServer {
    param([string]$Server, [bool]$Enable)
    
    if (-not (Test-Path $CONFIG_FILE)) {
        Initialize-Config
    }
    
    $config = Get-Content $CONFIG_FILE | ConvertFrom-Json
    
    if (-not $config.mcp_servers.$Server) {
        Write-Host "ERROR: MCP server '$Server' not found in config" -ForegroundColor Red
        return
    }
    
    $config.mcp_servers.$Server.enabled = $Enable
    
    if ($Enable) {
        if ($config.mcp_servers.enabled -notcontains $Server) {
            $config.mcp_servers.enabled += $Server
        }
        Write-Host "MCP server '$Server' enabled" -ForegroundColor Green
    } else {
        $config.mcp_servers.enabled = $config.mcp_servers.enabled | Where-Object { $_ -ne $Server }
        Write-Host "MCP server '$Server' disabled" -ForegroundColor Yellow
    }
    
    $config | ConvertTo-Json -Depth 10 | Set-Content $CONFIG_FILE
}

# Main command handling
switch ($Action.ToLower()) {
    "show" {
        Show-Config
    }
    "init" {
        Initialize-Config
    }
    "set-provider" {
        Set-Provider -ProviderType $Provider -ApiKeyEnv $ApiKey -Model $Model
    }
    "set-key" {
        Set-ApiKey -Key $ApiKey
    }
    "enable-mcp" {
        if (-not $McpServer) {
            Write-Host "ERROR: Specify MCP server with -McpServer" -ForegroundColor Red
            return
        }
        Toggle-McpServer -Server $McpServer -Enable $true
    }
    "disable-mcp" {
        if (-not $McpServer) {
            Write-Host "ERROR: Specify MCP server with -McpServer" -ForegroundColor Red
            return
        }
        Toggle-McpServer -Server $McpServer -Enable $false
    }
    default {
        Write-Host "Usage: .\config-manager.ps1 [action] [options]"
        Write-Host ""
        Write-Host "Actions:"
        Write-Host "  show              - Show current configuration"
        Write-Host "  init               - Initialize default config"
        Write-Host "  set-provider       - Set provider (use -Provider, -Model, etc.)"
        Write-Host "  set-key            - Set API key (use -ApiKey)"
        Write-Host "  enable-mcp         - Enable MCP server (use -McpServer)"
        Write-Host "  disable-mcp        - Disable MCP server (use -McpServer)"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  .\config-manager.ps1 show"
        Write-Host "  .\config-manager.ps1 set-key -ApiKey 'sk-xxxx'"
        Write-Host "  .\config-manager.ps1 set-provider -Provider openai -Model gpt-4"
        Write-Host "  .\config-manager.ps1 enable-mcp -McpServer filesystem"
    }
}
