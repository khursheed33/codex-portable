#!/bin/bash
# Make all scripts executable (Linux/Mac)
# Run: bash make-executable.sh

echo "Making scripts executable..."

chmod +x codex 2>/dev/null && echo "✓ codex"
chmod +x .codex/setup.sh 2>/dev/null && echo "✓ .codex/setup.sh"
chmod +x .codex/setup-config.sh 2>/dev/null && echo "✓ .codex/setup-config.sh"
chmod +x .codex/config-manager.sh 2>/dev/null && echo "✓ .codex/config-manager.sh"
chmod +x .codex/mcp/setup.sh 2>/dev/null && echo "✓ .codex/mcp/setup.sh"

echo ""
echo "Done! All scripts are now executable."
