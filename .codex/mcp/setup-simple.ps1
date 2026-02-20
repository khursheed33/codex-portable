# Simple PowerShell script - just clone and install
# Run with: powershell -ExecutionPolicy Bypass -File .\setup-simple.ps1

$ErrorActionPreference = "Stop"

$MCP_DIR = Split-Path -Parent $PSCommandPath
$MCP_SERVERS_DIR = Join-Path $MCP_DIR "servers"

Write-Host "MCP Servers Setup" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
$npmCheck = Get-Command npm -ErrorAction SilentlyContinue
$gitCheck = Get-Command git -ErrorAction SilentlyContinue

if (-not $nodeCheck) {
    Write-Host "ERROR: Node.js not found. Install from https://nodejs.org" -ForegroundColor Red
    exit 1
}
if (-not $npmCheck) {
    Write-Host "ERROR: npm not found" -ForegroundColor Red
    exit 1
}
if (-not $gitCheck) {
    Write-Host "ERROR: git not found. Install from https://git-scm.com" -ForegroundColor Red
    exit 1
}

Write-Host "Prerequisites OK" -ForegroundColor Green
Write-Host ""

# Clone repository
Write-Host "Cloning MCP servers repository..." -ForegroundColor Yellow
if (Test-Path $MCP_SERVERS_DIR) {
    Write-Host "Repository exists, updating..." -ForegroundColor Yellow
    Set-Location $MCP_SERVERS_DIR
    git pull
    Set-Location $MCP_DIR
} else {
    Write-Host "Cloning from GitHub..." -ForegroundColor Gray
    git clone https://github.com/modelcontextprotocol/servers.git $MCP_SERVERS_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to clone repository" -ForegroundColor Red
        exit 1
    }
    Write-Host "Repository cloned" -ForegroundColor Green
}
Write-Host ""

# Install root dependencies
Write-Host "Installing root dependencies..." -ForegroundColor Yellow
Set-Location $MCP_SERVERS_DIR
if (Test-Path "package.json") {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Root dependencies installation had issues" -ForegroundColor Yellow
    } else {
        Write-Host "Root dependencies installed" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: No package.json in root" -ForegroundColor Yellow
}
Write-Host ""

# Install and build filesystem server
Write-Host "Building filesystem server..." -ForegroundColor Yellow
$filesystemDir = Join-Path $MCP_SERVERS_DIR "src\filesystem"
if (Test-Path $filesystemDir) {
    Set-Location $filesystemDir
    if (Test-Path "package.json") {
        Write-Host "Installing dependencies..." -ForegroundColor Gray
        npm install
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Building..." -ForegroundColor Gray
            npm run build
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Filesystem server built successfully" -ForegroundColor Green
            } else {
                Write-Host "ERROR: Build failed" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "ERROR: Failed to install dependencies" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "ERROR: No package.json in filesystem directory" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "ERROR: Filesystem directory not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "Filesystem server location: $filesystemDir\dist\index.js" -ForegroundColor Cyan
