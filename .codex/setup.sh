#!/bin/bash
set -e

CODEX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$CODEX_DIR/.." && pwd)"
CODEX_HOME="$CODEX_DIR/home"

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│  Codex Local Setup                       │"
echo "└──────────────────────────────────────────┘"
echo "  Project → $PROJECT_ROOT"
echo ""

# ── Prerequisites ─────────────────────────────────────────────────────────────
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found → https://nodejs.org"; exit 1; }
command -v npm  >/dev/null 2>&1 || { echo "❌ npm not found"; exit 1; }
echo "✅ node $(node -v) | npm $(npm -v)"

# ── Install codex + MCP servers locally ──────────────────────────────────────
echo ""
echo "📦 Installing codex + MCP servers..."
cd "$CODEX_DIR"
npm install
echo "✅ Installed → .codex/node_modules/"

# ── Create home structure ────────────────────────────────────────────────────
mkdir -p "$CODEX_HOME"/{skills,sessions,tmp}

# ── Write config.toml ────────────────────────────────────────────────────────
# Check if root codex.toml exists, if not create from example
if [ ! -f "$PROJECT_ROOT/codex.toml" ]; then
  if [ -f "$PROJECT_ROOT/codex.toml.example" ]; then
    cp "$PROJECT_ROOT/codex.toml.example" "$PROJECT_ROOT/codex.toml"
    echo "✅ Created codex.toml from example (update with your values)"
  else
    # Create basic config.toml in home directory as fallback
    cat > "$CODEX_HOME/config.toml" << TOML
model         = "codex-mini-latest"
approval_mode = "suggest"

[[mcp_servers]]
name    = "filesystem"
command = "node"
args    = [
  "$CODEX_DIR/node_modules/@modelcontextprotocol/server-filesystem/dist/index.js",
  "$PROJECT_ROOT"
]
TOML
    echo "✅ config.toml written (basic)"
  fi
else
  # Link root codex.toml to home directory
  ln -sf "$PROJECT_ROOT/codex.toml" "$CODEX_HOME/config.toml" 2>/dev/null || \
  cp "$PROJECT_ROOT/codex.toml" "$CODEX_HOME/config.toml" 2>/dev/null || true
  echo "✅ Linked codex.toml from root"
fi

# ── Setup config.json if needed ──────────────────────────────────────────────
if [ ! -f "$PROJECT_ROOT/config.json" ]; then
  if [ -f "$PROJECT_ROOT/config.json.example" ]; then
    cp "$PROJECT_ROOT/config.json.example" "$PROJECT_ROOT/config.json"
    echo "✅ Created config.json from example (update with your values)"
  fi
fi

# ── Starter skills ───────────────────────────────────────────────────────────
cat > "$CODEX_HOME/skills/project-context.md" << SKILL
# Project: $(basename "$PROJECT_ROOT")
Location: $PROJECT_ROOT

- Read files before editing them
- Make focused changes, not full rewrites
- Summarize what you changed after each edit
SKILL
echo "✅ Skills written"

# ── .env ─────────────────────────────────────────────────────────────────────
if [ ! -f "$CODEX_DIR/.env" ]; then
  echo 'OPENAI_API_KEY=sk-your-key-here' > "$CODEX_DIR/.env"
  echo "⚠️  Add your key → .codex/.env"
fi

# ── Make scripts executable ────────────────────────────────────────────────
chmod +x "$PROJECT_ROOT/codex" 2>/dev/null || true
chmod +x "$CODEX_DIR/setup.sh" 2>/dev/null || true
chmod +x "$CODEX_DIR/setup-config.sh" 2>/dev/null || true
chmod +x "$CODEX_DIR/mcp/setup.sh" 2>/dev/null || true
chmod +x "$CODEX_DIR/config-manager.sh" 2>/dev/null || true
echo "✅ Made scripts executable"

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│  Done! Usage:                            │"
echo "│                                          │"
echo "│    ./codex                               │"
echo "│                                          │"
echo "│  That's it.                              │"
echo "└──────────────────────────────────────────┘"
