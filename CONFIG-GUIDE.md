# Configuration Guide

## Overview

Yes, all configuration can be managed using just **two files** in the root directory:

1. **`codex.toml`** - Primary configuration (Codex reads this directly)
2. **`config.json`** - Helper/centralized config (used by launcher scripts)

Plus one file for secrets:
3. **`.codex/.env`** - API keys (gitignored, never committed)

## File Roles

### `codex.toml` (Primary Config)
**This is the main configuration file that Codex actually uses.**

Contains:
- Model and provider settings
- API endpoints and connection settings
- MCP server configurations
- Feature flags
- Approval policies
- Sandbox settings
- Timeouts and retry settings
- Project-specific settings

**Location:** Root directory  
**Used by:** Codex directly (via `.codex/home/config.toml` link)  
**Edit this for:** All Codex runtime settings

### `config.json` (Helper Config)
**This is a helper file used by launcher scripts and config manager.**

Contains:
- Provider type and API key environment variable name
- MCP server enable/disable flags
- Feature flags (for reference)
- Override settings (future use)

**Location:** Root directory  
**Used by:** 
- Launcher scripts (to determine which API key to check)
- Config manager scripts (to show/edit settings)
- Future: Could override `codex.toml` settings

**Edit this for:** 
- Changing which API key environment variable to use
- Enabling/disabling MCP servers via config manager
- Quick provider switching

### `.env` (Secrets)
**Contains API keys and other secrets.**

Contains:
- `AZURE_OPENAI_API_KEY=your-key-here`
- `OPENAI_API_KEY=sk-...` (optional)
- Other API keys as needed

**Location:** `.env` (root directory)  
**Used by:** Launcher scripts (loads before starting Codex)  
**Edit this for:** API keys only

## Configuration Flow

```
1. Launcher reads config.json
   └─> Determines which API key env var to check
   └─> Loads .env (root)
   └─> Links codex.toml → .codex/home/config.toml

2. Codex starts
   └─> Reads .codex/home/config.toml (linked from root)
   └─> Uses all settings from there
```

## What to Edit Where

### To Change Provider (Azure → OpenAI):

**Option 1: Edit both files manually**
1. Edit `config.json`: Change `provider.type` to `"openai"`
2. Edit `codex.toml`: Update `model_provider`, `model`, and `[model_providers.openai]` section
3. Update `.env` (root): Set `OPENAI_API_KEY=sk-...`

**Option 2: Use config manager (partial)**
1. `config-manager.bat set-provider -Provider openai`
2. Still need to manually update `codex.toml` for full switch

### To Change Model:

1. Edit `codex.toml`: Change `model = "your-model"`
2. (Optional) Edit `config.json`: Update `provider.model` for reference

### To Enable/Disable MCP Server:

**Option 1: Use config manager**
```batch
config-manager.bat enable-mcp -McpServer filesystem
config-manager.bat disable-mcp -McpServer filesystem
```
Then manually update `codex.toml` to add/remove the MCP server section.

**Option 2: Edit manually**
1. Edit `config.json`: Change `mcp_servers.filesystem.enabled = false`
2. Edit `codex.toml`: Comment out or remove `[mcp_servers.filesystem]` section

### To Change Timeouts/Settings:

1. Edit `codex.toml` directly (this is the source of truth)

## Current Limitations

- `config.json` doesn't automatically override `codex.toml` yet
- You need to keep both files in sync manually
- Config manager can help with some settings but not all

## Future Improvements

Ideally, `config.json` could:
- Automatically sync settings to `codex.toml`
- Provide a single source of truth
- Allow easier provider switching

For now, **`codex.toml` is the primary config** and `config.json` is a helper.

## Quick Reference

| Setting | Edit In | Notes |
|---------|---------|-------|
| Provider type | `codex.toml` + `config.json` | Keep both in sync |
| Model name | `codex.toml` | Primary source |
| API endpoint | `codex.toml` | Primary source |
| API key | `.env` (root) | Secrets only |
| MCP servers | `codex.toml` | Primary source |
| Features | `codex.toml` | Primary source |
| Timeouts | `codex.toml` | Primary source |
| Approval policy | `codex.toml` | Primary source |

## Summary

✅ **Yes, all configuration is managed in two files:**
- `codex.toml` - Primary config (what Codex uses)
- `config.json` - Helper config (for launcher/scripts)

Plus:
- `.env` (root) - API keys (secrets)

**Best practice:** 
- Edit `codex.toml` for most changes
- Use `config.json` for provider switching and MCP server management
- Keep them in sync when changing providers
