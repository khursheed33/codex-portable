#!/bin/bash
set -e

# Get the script directory and project root
MCP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_DIR="$(cd "$MCP_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$CODEX_DIR/.." && pwd)"
MCP_SERVERS_DIR="$MCP_DIR/servers"

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│  MCP Servers Setup                       │"
echo "└──────────────────────────────────────────┘"
echo "  Project → $PROJECT_ROOT"
echo "  MCP Dir → $MCP_SERVERS_DIR"
echo ""

# ── Prerequisites ─────────────────────────────────────────────────────────────
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found → https://nodejs.org"; exit 1; }
command -v npm  >/dev/null 2>&1 || { echo "❌ npm not found"; exit 1; }
command -v git  >/dev/null 2>&1 || { echo "❌ git not found → https://git-scm.com"; exit 1; }
echo "✅ node $(node -v) | npm $(npm -v) | git $(git --version | cut -d' ' -f3)"

# ── Clone MCP Servers Repository ─────────────────────────────────────────────
echo ""
echo "📦 Cloning MCP servers repository..."
if [ -d "$MCP_SERVERS_DIR" ]; then
  echo "⚠️  Repository already exists, updating..."
  cd "$MCP_SERVERS_DIR"
  git pull origin HEAD || echo "⚠️  Could not update, using existing"
else
  git clone https://github.com/modelcontextprotocol/servers.git "$MCP_SERVERS_DIR"
  echo "✅ Repository cloned"
fi

# ── Install Dependencies and Build Filesystem Server ─────────────────────────
echo ""
echo "🔨 Building filesystem MCP server..."
cd "$MCP_SERVERS_DIR"

# Install root dependencies
if [ -f "package.json" ]; then
  npm install
  echo "✅ Root dependencies installed"
fi

# Build filesystem server
if [ -d "src/filesystem" ]; then
  cd src/filesystem
  if [ -f "package.json" ]; then
    npm install
    npm run build
    echo "✅ Filesystem server built"
  else
    echo "⚠️  No package.json in filesystem directory"
  fi
else
  echo "❌ filesystem directory not found"
  exit 1
fi

# ── Verify Build ─────────────────────────────────────────────────────────────
FILESYSTEM_DIST="$MCP_SERVERS_DIR/src/filesystem/dist/index.js"
if [ -f "$FILESYSTEM_DIST" ]; then
  echo "✅ Filesystem server ready at: $FILESYSTEM_DIST"
else
  echo "❌ Build failed: $FILESYSTEM_DIST not found"
  exit 1
fi

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│  MCP Servers Setup Complete!             │"
echo "│                                          │"
echo "│  Filesystem server:                      │"
echo "│    $FILESYSTEM_DIST                      │"
echo "└──────────────────────────────────────────┘"
