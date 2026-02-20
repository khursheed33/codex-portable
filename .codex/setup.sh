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

[[mcp_servers]]
name    = "git"
command = "node"
args    = [
  "$CODEX_DIR/node_modules/@modelcontextprotocol/server-git/dist/index.js",
  "--repository", "$PROJECT_ROOT"
]
TOML
echo "✅ config.toml written"

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

# ── Write the project root `codex` launcher ──────────────────────────────────
cat > "$PROJECT_ROOT/codex" << 'LAUNCHER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_DIR="$SCRIPT_DIR/.codex"
CODEX_BIN="$CODEX_DIR/node_modules/.bin/codex"
CODEX_HOME="$CODEX_DIR/home"

if [ ! -f "$CODEX_BIN" ]; then
  echo "❌ Not installed. Run: ./.codex/setup.sh"
  exit 1
fi

[ -f "$CODEX_DIR/.env" ] && export $(grep -v '^#' "$CODEX_DIR/.env" | xargs)

if [[ -z "$OPENAI_API_KEY" || "$OPENAI_API_KEY" == "sk-your-key-here" ]]; then
  echo "❌ Set OPENAI_API_KEY in .codex/.env"
  exit 1
fi

export OPENAI_API_KEY="$OPENAI_API_KEY"
export CODEX_HOME="$CODEX_HOME"
export XDG_CONFIG_HOME="$CODEX_DIR"

# Pass ALL arguments through exactly as-is to codex
# So `./codex` opens interactive, `./codex "do this"` runs one-shot
exec "$CODEX_BIN" "$@"
LAUNCHER

chmod +x "$PROJECT_ROOT/codex"
chmod +x "$CODEX_DIR/setup.sh"
echo "✅ ./codex launcher created at project root"

echo ""
echo "┌──────────────────────────────────────────┐"
echo "│  Done! Usage:                            │"
echo "│                                          │"
echo "│    ./codex                               │"
echo "│                                          │"
echo "│  That's it.                              │"
echo "└──────────────────────────────────────────┘"
