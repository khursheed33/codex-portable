#!/bin/bash
# Bash script to verify Codex is running from local installation
# Run: bash verify-codex.sh

echo ""
echo "========================================"
echo "  Codex Environment Verification"
echo "========================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_DIR="$SCRIPT_DIR/.codex"
CODEX_BIN_DIR="$CODEX_DIR/node_modules/.bin"
CODEX_BIN="$CODEX_BIN_DIR/codex"
CODEX_HOME="$CODEX_DIR/home"
CONFIG_FILE="$CODEX_HOME/config.toml"
CENTRAL_CONFIG="$SCRIPT_DIR/config.json"
CONFIG_TOML="$SCRIPT_DIR/codex.toml"

echo "Checking local installation..."
echo ""

# Check if local binary exists
codexBinary=""
if [ -f "$CODEX_BIN" ]; then
    codexBinary="$CODEX_BIN"
    echo "[OK] Local Codex binary found"
    echo "    Location: $codexBinary"
else
    echo "[X] Local Codex binary NOT found"
    echo "    Expected: $CODEX_BIN"
    echo "    Run: cd .codex && npm install"
fi

echo ""

# Check centralized config
if [ -f "$CENTRAL_CONFIG" ]; then
    echo "[OK] Centralized config found"
    echo "    Location: $CENTRAL_CONFIG"
else
    echo "[!] Centralized config not found (optional)"
    echo "    Location: $CENTRAL_CONFIG"
fi

echo ""

# Check config file
if [ -f "$CONFIG_TOML" ]; then
    echo "[OK] Root config.toml found"
    echo "    Location: $CONFIG_TOML"
    
    # Try to extract model and provider
    if command -v grep >/dev/null 2>&1; then
        model=$(grep -m 1 '^model\s*=' "$CONFIG_TOML" 2>/dev/null | sed 's/.*= *"\([^"]*\)".*/\1/' | head -1)
        provider=$(grep -m 1 '^model_provider\s*=' "$CONFIG_TOML" 2>/dev/null | sed 's/.*= *"\([^"]*\)".*/\1/' | head -1)
        if [ -n "$model" ]; then
            echo "    Model: $model"
        fi
        if [ -n "$provider" ]; then
            echo "    Provider: $provider"
        fi
    fi
else
    echo "[X] Root config.toml NOT found"
    echo "    Expected: $CONFIG_TOML"
    echo "    Run: cd .codex && bash setup-config.sh"
fi

echo ""

# Check linked config
if [ -f "$CONFIG_FILE" ]; then
    echo "[OK] Linked config.toml found"
    echo "    Location: $CONFIG_FILE"
    if [ -L "$CONFIG_FILE" ]; then
        linkTarget=$(readlink "$CONFIG_FILE")
        echo "    Linked from: $linkTarget"
    fi
else
    echo "[!] Linked config.toml not found (will be created on first run)"
    echo "    Expected: $CONFIG_FILE"
fi

echo ""

# Check for global installation
echo "Checking for global installation..."
if command -v codex >/dev/null 2>&1; then
    globalCodex=$(which codex)
    echo "[!] Global Codex installation detected"
    echo "    Location: $globalCodex"
    echo ""
    echo "    To use LOCAL Codex, run: ./codex"
    echo "    NOT: codex (this uses global)"
else
    echo "[OK] No global Codex installation found"
    echo "    (This is fine - you will only use local)"
fi

echo ""

# Check environment variables (if Codex is running)
echo "Environment Variables (if Codex is running):"
if [ -n "$CODEX_HOME" ]; then
    if [ "$CODEX_HOME" = "$CODEX_DIR/home" ]; then
        echo "[OK] CODEX_HOME is set to LOCAL path"
        echo "    Value: $CODEX_HOME"
    else
        echo "[!] CODEX_HOME is set but points to different location"
        echo "    Current: $CODEX_HOME"
        echo "    Expected: $CODEX_DIR/home"
    fi
else
    echo "[!] CODEX_HOME not set (Codex may not be running)"
fi

if [ -n "$XDG_CONFIG_HOME" ]; then
    echo "[OK] XDG_CONFIG_HOME is set"
    echo "    Value: $XDG_CONFIG_HOME"
fi

echo ""

# Summary
echo "========================================"
echo "  Verification Summary"
echo "========================================"
echo ""

allGood=true
if [ -z "$codexBinary" ]; then
    allGood=false
fi
if [ ! -f "$CONFIG_TOML" ]; then
    allGood=false
fi

if [ "$allGood" = true ]; then
    echo "[OK] Local Codex installation is ready!"
    echo ""
    echo "To use local Codex, run:"
    echo "  ./codex"
    echo "  or"
    echo "  ./codex --info"
    echo "    (to see local environment info)"
else
    echo "[X] Local Codex installation is incomplete"
    echo ""
    echo "Next steps:"
    if [ -z "$codexBinary" ]; then
        echo "  1. Install dependencies: cd .codex && npm install"
    fi
    if [ ! -f "$CONFIG_TOML" ]; then
        echo "  2. Run setup: cd .codex && bash setup-config.sh"
    fi
fi

echo ""
