# PowerShell script for Windows - MCP Servers Setup
# This script clones the MCP servers repository and builds the filesystem server

$ErrorActionPreference = "Stop"

# Get script directory
$MCP_DIR = Split-Path -Parent $PSCommandPath
$CODEX_DIR = Split-Path -Parent $MCP_DIR
$PROJECT_ROOT = Split-Path -Parent $CODEX_DIR
$MCP_SERVERS_DIR = Join-Path $MCP_DIR "servers"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MCP Servers Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Project: $PROJECT_ROOT"
Write-Host "  MCP Dir: $MCP_SERVERS_DIR"
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

try {
    $nodeVersion = & node -v 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Node.js not found" }
    Write-Host "  Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js not found. Install from https://nodejs.org" -ForegroundColor Red
    exit 1
}

try {
    $npmVersion = & npm -v 2>&1
    if ($LASTEXITCODE -ne 0) { throw "npm not found" }
    Write-Host "  npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: npm not found" -ForegroundColor Red
    exit 1
}

try {
    $gitVersion = & git --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git not found" }
    $gitVersion = $gitVersion -replace 'git version ', ''
    Write-Host "  git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: git not found. Install from https://git-scm.com" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Clone repository
Write-Host "Cloning MCP servers repository..." -ForegroundColor Yellow
if (Test-Path $MCP_SERVERS_DIR) {
    Write-Host "  Repository exists, updating..." -ForegroundColor Yellow
    Push-Location $MCP_SERVERS_DIR
    & git pull origin HEAD 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Warning: Could not update, using existing" -ForegroundColor Yellow
    } else {
        Write-Host "  Repository updated" -ForegroundColor Green
    }
    Pop-Location
} else {
    Write-Host "  Cloning from GitHub..." -ForegroundColor Gray
    & git clone https://github.com/modelcontextprotocol/servers.git $MCP_SERVERS_DIR
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Repository cloned successfully" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: Failed to clone repository" -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Install root dependencies
Write-Host "Installing root dependencies..." -ForegroundColor Yellow
Push-Location $MCP_SERVERS_DIR
if (Test-Path "package.json") {
    & npm install
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Root dependencies installed" -ForegroundColor Green
    } else {
        Write-Host "  Warning: Root dependencies installation had issues" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Warning: No package.json in root directory" -ForegroundColor Yellow
}
Pop-Location
Write-Host ""

# Build filesystem server
Write-Host "Building filesystem MCP server..." -ForegroundColor Yellow
$filesystemDir = Join-Path $MCP_SERVERS_DIR "src\filesystem"

if (-not (Test-Path $filesystemDir)) {
    Write-Host "  ERROR: Filesystem directory not found at: $filesystemDir" -ForegroundColor Red
    exit 1
}

Push-Location $filesystemDir

if (-not (Test-Path "package.json")) {
    Write-Host "  ERROR: No package.json in filesystem directory" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "  Installing dependencies..." -ForegroundColor Gray
& npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Failed to install dependencies" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "  Building..." -ForegroundColor Gray
& npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location
Write-Host "  Filesystem server built successfully" -ForegroundColor Green
Write-Host ""

# Verify build
$filesystemDist = Join-Path $filesystemDir "dist\index.js"
if (Test-Path $filesystemDist) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Setup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Filesystem server location:" -ForegroundColor Cyan
    Write-Host "  $filesystemDist" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "  ERROR: Build verification failed" -ForegroundColor Red
    Write-Host "  Expected file not found: $filesystemDist" -ForegroundColor Yellow
    exit 1
}
