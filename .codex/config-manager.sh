#!/bin/bash
# Codex Configuration Manager (Bash version)
# Manages centralized configuration for Codex

CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.json"
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
ACTION="${1:-show}"

show_config() {
    echo ""
    echo "========================================"
    echo "  Codex Configuration"
    echo "========================================"
    echo ""
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found. Creating default..."
        init_config
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "Provider:"
        echo "  Type: $(jq -r '.provider.type' "$CONFIG_FILE")"
        echo "  Model: $(jq -r '.provider.model' "$CONFIG_FILE")"
        echo "  API Key Env: $(jq -r '.provider.api_key_env' "$CONFIG_FILE")"
        echo ""
        
        echo "MCP Servers:"
        jq -r '.mcp_servers.enabled[]' "$CONFIG_FILE" | while read server; do
            enabled=$(jq -r ".mcp_servers.$server.enabled" "$CONFIG_FILE")
            status=$([ "$enabled" = "true" ] && echo "Enabled" || echo "Disabled")
            echo "  $server : $status"
        done
        echo ""
    else
        echo "Install 'jq' for better config viewing: https://stedolan.github.io/jq/"
        echo "Config file: $CONFIG_FILE"
    fi
}

init_config() {
    cat > "$CONFIG_FILE" << 'EOF'
{
  "provider": {
    "type": "azure",
    "api_key_env": "AZURE_OPENAI_API_KEY",
    "model": "gpt-5.1-codex-mini",
    "base_url": "https://asimovgenai.openai.azure.com/openai",
    "api_version": "2025-04-01-preview"
  },
  "overrides": {
    "model": null,
    "model_provider": null,
    "approval_policy": null,
    "sandbox_mode": null
  },
  "mcp_servers": {
    "enabled": ["filesystem"],
    "filesystem": {
      "enabled": true,
      "args": [".", ".codex/home/skills"]
    }
  },
  "features": {
    "powershell_utf8": true,
    "shell_snapshot": true,
    "collaboration_modes": true,
    "multi_agent": true,
    "web_search": false
  }
}
EOF
    echo "Default config created at: $CONFIG_FILE"
}

set_api_key() {
    local key="$1"
    if [ -z "$key" ]; then
        echo "ERROR: API key not provided"
        echo "Usage: $0 set-key <api-key>"
        return 1
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        init_config
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local env_var=$(jq -r '.provider.api_key_env' "$CONFIG_FILE")
        
        # Update .env file
        if [ -f "$ENV_FILE" ]; then
            if grep -q "^$env_var=" "$ENV_FILE"; then
                sed -i.bak "s|^$env_var=.*|$env_var=$key|" "$ENV_FILE"
            else
                echo "$env_var=$key" >> "$ENV_FILE"
            fi
        else
            echo "$env_var=$key" > "$ENV_FILE"
        fi
        
        echo "API key updated in .env file"
        echo "  Variable: $env_var"
    else
        echo "ERROR: 'jq' is required for this operation"
        echo "Install from: https://stedolan.github.io/jq/"
        return 1
    fi
}

case "$ACTION" in
    show)
        show_config
        ;;
    init)
        init_config
        ;;
    set-key)
        set_api_key "$2"
        ;;
    *)
        echo "Usage: $0 [action] [options]"
        echo ""
        echo "Actions:"
        echo "  show              - Show current configuration"
        echo "  init              - Initialize default config"
        echo "  set-key <key>     - Set API key"
        echo ""
        echo "Examples:"
        echo "  $0 show"
        echo "  $0 set-key 'sk-xxxx'"
        ;;
esac
