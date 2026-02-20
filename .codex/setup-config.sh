#!/bin/bash
# Setup script to copy example config files if they don't exist

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_JSON="$PROJECT_ROOT/config.json"
CONFIG_JSON_EXAMPLE="$PROJECT_ROOT/config.json.example"
CODEX_TOML="$PROJECT_ROOT/codex.toml"
CODEX_TOML_EXAMPLE="$PROJECT_ROOT/codex.toml.example"

echo ""
echo "========================================"
echo "  Codex Configuration Setup"
echo "========================================"
echo ""

# Copy config.json if it doesn't exist
if [ ! -f "$CONFIG_JSON" ]; then
    if [ -f "$CONFIG_JSON_EXAMPLE" ]; then
        cp "$CONFIG_JSON_EXAMPLE" "$CONFIG_JSON"
        echo "[OK] Created config.json from example"
        echo "     Edit config.json and update with your values"
    else
        echo "[!] config.json.example not found"
    fi
else
    echo "[OK] config.json already exists"
fi

# Copy codex.toml if it doesn't exist
if [ ! -f "$CODEX_TOML" ]; then
    if [ -f "$CODEX_TOML_EXAMPLE" ]; then
        cp "$CODEX_TOML_EXAMPLE" "$CODEX_TOML"
        echo "[OK] Created codex.toml from example"
        echo "     Edit codex.toml and update with your values"
    else
        echo "[!] codex.toml.example not found"
    fi
else
    echo "[OK] codex.toml already exists"
fi

echo ""
echo "Next steps:"
echo "  1. Edit config.json and update:"
echo "     - base_url: Your Azure deployment URL"
echo "     - model: Your deployment name"
echo ""
echo "  2. Edit codex.toml and update:"
echo "     - base_url: Your Azure deployment URL"
echo "     - model: Your deployment name"
echo "     - Project paths: Update to match your project"
echo ""
echo "  3. Set your API key in .env (root directory):"
echo "     AZURE_OPENAI_API_KEY=your-key-here"
echo ""
