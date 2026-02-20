# Codex Centralized Configuration

This project uses a centralized configuration system that makes it easy to:
- Switch between providers (Azure, OpenAI, Anthropic, etc.)
- Manage API keys
- Enable/disable MCP servers
- Override config.toml settings

## Configuration Files

1. **`.codex/config.json`** - Centralized configuration (JSON)
2. **`.codex/.env`** - API keys and secrets (gitignored)
3. **`.codex/home/config.toml`** - Codex runtime configuration (can be overridden)

## Quick Start

### View Current Configuration

**Windows:**
```powershell
cd .codex
.\config-manager.ps1 show
```

**Linux/Mac:**
```bash
cd .codex
bash config-manager.sh show
```

### Set API Key

**Windows:**
```powershell
.\config-manager.ps1 set-key -ApiKey "your-api-key-here"
```

**Linux/Mac:**
```bash
bash config-manager.sh set-key "your-api-key-here"
```

## Changing Providers

### Switch to OpenAI

1. Edit `.codex/config.json`:
```json
{
  "provider": {
    "type": "openai",
    "api_key_env": "OPENAI_API_KEY",
    "model": "gpt-4",
    "base_url": "https://api.openai.com/v1",
    "api_version": null
  }
}
```

2. Set the API key:
```powershell
.\config-manager.ps1 set-key -ApiKey "sk-your-openai-key"
```

3. Update `.codex/home/config.toml` to match:
```toml
model_provider = "openai"
model = "gpt-4"

[model_providers.openai]
name = "OpenAI"
base_url = "https://api.openai.com/v1"
env_key = "OPENAI_API_KEY"
```

### Switch to Anthropic

1. Edit `.codex/config.json`:
```json
{
  "provider": {
    "type": "anthropic",
    "api_key_env": "ANTHROPIC_API_KEY",
    "model": "claude-3-5-sonnet-20241022",
    "base_url": "https://api.anthropic.com/v1",
    "api_version": null
  }
}
```

2. Set the API key:
```powershell
.\config-manager.ps1 set-key -ApiKey "sk-ant-your-key"
```

3. Update `.codex/home/config.toml` accordingly.

### Switch Back to Azure

1. Edit `.codex/config.json`:
```json
{
  "provider": {
    "type": "azure",
    "api_key_env": "AZURE_OPENAI_API_KEY",
    "model": "gpt-5.1-codex-mini",
    "base_url": "https://asimovgenai.openai.azure.com/openai",
    "api_version": "2025-04-01-preview"
  }
}
```

2. Set the API key:
```powershell
.\config-manager.ps1 set-key -ApiKey "your-azure-key"
```

## Managing MCP Servers

### Enable/Disable MCP Server

**Windows:**
```powershell
# Enable
.\config-manager.ps1 enable-mcp -McpServer filesystem

# Disable
.\config-manager.ps1 disable-mcp -McpServer filesystem
```

**Linux/Mac:**
Edit `.codex/config.json` directly:
```json
{
  "mcp_servers": {
    "enabled": ["filesystem", "git"],
    "filesystem": {
      "enabled": true,
      "args": [".", ".codex/home/skills"]
    },
    "git": {
      "enabled": false
    }
  }
}
```

Then update `.codex/home/config.toml` to add/remove MCP server sections.

## Configuration Structure

### config.json Schema

```json
{
  "provider": {
    "type": "azure|openai|anthropic",
    "api_key_env": "ENVIRONMENT_VARIABLE_NAME",
    "model": "model-name",
    "base_url": "https://api.example.com",
    "api_version": "version-string-or-null"
  },
  "overrides": {
    "model": null,
    "model_provider": null,
    "approval_policy": null,
    "sandbox_mode": null
  },
  "mcp_servers": {
    "enabled": ["server1", "server2"],
    "server1": {
      "enabled": true,
      "args": ["arg1", "arg2"]
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
```

## Overriding config.toml

The `overrides` section in `config.json` can be used to override settings in `config.toml`. Currently, this requires manual updates to `config.toml`, but the centralized config serves as the source of truth.

## Best Practices

1. **Never commit `.env`** - It's already in `.gitignore`
2. **Commit `config.json`** - It defines your project's Codex setup (without secrets)
3. **Document provider changes** - Update README when switching providers
4. **Use config manager** - Use the scripts instead of editing JSON directly when possible

## Troubleshooting

### Config not being read

- Check that `config.json` exists in `.codex/` directory
- Verify JSON syntax is valid
- Run `./codex --info` to see what's being used

### API key not working

- Verify the key is set in `.codex/.env`
- Check that `api_key_env` in `config.json` matches the variable name
- Ensure the key is exported: `export $(grep -v '^#' .codex/.env | xargs)`

### Provider switch not working

- Update both `config.json` AND `config.toml`
- Restart Codex after changes
- Check `./codex --info` to verify settings
