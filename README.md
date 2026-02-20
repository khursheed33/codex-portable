# Codex App

A local Codex setup for this project with pre-configured MCP servers and skills, using Azure OpenAI.

## Setup

1. **Install Codex dependencies:**
   ```bash
   cd .codex
   npm install
   ```

2. **Setup MCP servers:**
   
   **On Windows (Easiest - Just double-click):**
   ```batch
   cd .codex\mcp
   setup.bat
   ```
   
   Or simply double-click `setup.bat` in Windows Explorer.
   
   **On Windows (PowerShell):**
   ```powershell
   cd .codex\mcp
   .\setup.ps1
   ```
   
   **On Linux/Mac or Git Bash:**
   ```bash
   cd .codex/mcp
   bash setup.sh
   ```
   
   This will clone and build the MCP servers repository, including the filesystem server.

3. **Set your API keys:**
   Edit `.codex/.env`:
   ```
   AZURE_OPENAI_API_KEY=your-azure-api-key-here
   OPENAI_API_KEY=sk-your-key-here  # Optional fallback
   ```

4. **Run Codex (IMPORTANT - Use local launcher):**
   
   **On Windows (Easiest - Just double-click or run):**
   ```batch
   codex.bat
   ```
   
   Or:
   ```powershell
   .\codex.ps1
   ```
   
   **On Windows (Git Bash or WSL):**
   ```bash
   ./codex
   ```
   
   ⚠️ **CRITICAL**: Always use `codex.bat`, `.\codex.ps1`, or `./codex`, NOT just `codex`
   - `codex.bat` / `.\codex.ps1` / `./codex` = Uses LOCAL installation with your project config
   - `codex` = Uses GLOBAL installation (wrong config/keys)

5. **Verify you're using local Codex:**
   ```bash
   ./codex --info
   ```
   
   Or run the verification script:
   ```batch
   verify-codex.bat
   ```

## Usage

See **[USAGE.md](USAGE.md)** for detailed step-by-step instructions.

**Quick commands:**
- `./codex` - Opens interactive TUI session
- `./codex "your task here"` - One-shot command execution
- `./codex --info` - **Verify you're using local installation** (shows paths and config)
- `./codex --help` - See all available options

**Verify local installation:**
- Run `./codex --info` to see local environment details
- Or run `verify-codex.bat` (Windows) for detailed verification

## Project Structure

```
codex-app/
├── .codex/
│   ├── setup.sh              # Main setup script
│   ├── package.json          # Codex dependencies
│   ├── .env                  # API keys (gitignored)
│   ├── home/
│   │   ├── config.toml       # Codex configuration (Azure, MCP servers)
│   │   ├── skills/           # Project-specific skills
│   │   ├── sessions/         # Session data (gitignored)
│   │   └── tmp/              # Temporary files (gitignored)
│   ├── mcp/
│   │   ├── setup.sh          # MCP servers setup (bash)
│   │   ├── setup.ps1         # MCP servers setup (PowerShell)
│   │   ├── README.md         # MCP setup documentation
│   │   └── servers/          # Cloned MCP servers repo (gitignored)
│   └── node_modules/         # Installed packages (gitignored)
├── codex                     # Launcher script
└── README.md
```

## Configuration

The main configuration is in `.codex/home/config.toml`. It includes:
- **Azure OpenAI** provider settings (model: `gpt-5.1-codex-mini`)
- **Approval policy**: `never` (full access)
- **Sandbox mode**: `danger-full-access`
- **MCP servers**: Filesystem server (cloned from GitHub)
- **Features**: PowerShell UTF-8, shell snapshots, collaboration modes, multi-agent

### MCP Servers

MCP servers are cloned from the [official repository](https://github.com/modelcontextprotocol/servers) and built locally:
- **Filesystem server**: Located at `.codex/mcp/servers/src/filesystem/dist/index.js`
- To add more servers, see `.codex/mcp/README.md`

## Configuration Management

This project uses a **centralized configuration system** for easy management:

- **`.codex/config.json`** - Centralized config (provider, MCP servers, features)
- **`.codex/.env`** - API keys (gitignored, never committed)
- **`.codex/home/config.toml`** - Codex runtime config (can be overridden)

### Quick Config Commands

**View configuration:**
```batch
cd .codex
config-manager.bat show
```

**Set API key:**
```batch
config-manager.bat set-key -ApiKey "your-key-here"
```

**Switch providers:** Edit `.codex/config.json` and update `config.toml` accordingly.

See **[.codex/CONFIG.md](.codex/CONFIG.md)** for detailed configuration guide.

## Notes

- Uses **Azure OpenAI** by default (configured in `config.json` and `config.toml`)
- MCP servers are built from source, not npm packages
- On Windows, use PowerShell for `setup.ps1` or Git Bash/WSL for `setup.sh`
- The `.env` file contains your API keys and is gitignored for security
- **`config.json` should be committed** - it defines your project setup (without secrets)