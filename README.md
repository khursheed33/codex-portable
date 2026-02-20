# Codex App

A local Codex setup for this project with pre-configured MCP servers and skills, using Azure OpenAI.

**Cross-platform:** Works on Windows, Linux, and macOS.

## Setup

### Quick Start (All Platforms)

**Run the setup script:**
```bash
cd .codex
bash setup.sh
cd ..
```

This will install dependencies, setup MCP servers, and create config files.

### Manual Setup

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
   
   **Note:** On Linux, you may need to make scripts executable first:
   ```bash
   chmod +x .codex/mcp/setup.sh
   ```
   
   This will clone and build the MCP servers repository, including the filesystem server.

3. **Setup configuration files:**
   
   **On Windows:**
   ```batch
   cd .codex
   setup-config.bat
   ```
   
   **On Linux/Mac or Git Bash:**
   ```bash
   cd .codex
   bash setup-config.sh
   ```
   
   **Note:** On Linux, you may need to make scripts executable first:
   ```bash
   chmod +x .codex/setup-config.sh
   ```
   
   This will create `config.json` and `codex.toml` from example files.
   Then edit them and update with your actual values:
   - Update `base_url` with your Azure deployment URL
   - Update `model` with your deployment name
   - Update project paths in `codex.toml`

4. **Set your API keys:**
   Edit `.env` (root directory):
   ```
   AZURE_OPENAI_API_KEY=your-azure-api-key-here
   OPENAI_API_KEY=sk-your-key-here  # Optional fallback
   ```
   
   Or use the config manager:
   ```batch
   cd .codex
   config-manager.bat set-key -ApiKey "your-key-here"
   ```

5. **Run Codex (IMPORTANT - Use local launcher):**
   
   **On Windows (Easiest - Just double-click or run):**
   ```batch
   codex.bat
   ```
   
   Or:
   ```powershell
   .\codex.ps1
   ```
   
   **On Linux/Mac:**
   ```bash
   ./codex
   ```
   
   **On Windows (Git Bash or WSL):**
   ```bash
   ./codex
   ```
   
   **Note:** On Linux, make sure the script is executable:
   ```bash
   chmod +x codex
   ```
   
   ⚠️ **CRITICAL**: Always use `codex.bat`, `.\codex.ps1`, or `./codex`, NOT just `codex`
   - `codex.bat` / `.\codex.ps1` / `./codex` = Uses LOCAL installation with your project config
   - `codex` = Uses GLOBAL installation (wrong config/keys)

6. **Verify you're using local Codex:**
   ```bash
   ./codex --info
   ```
   
   Or run the verification script:
   ```batch
   verify-codex.bat    # Windows
   ```
   ```bash
   bash verify-codex.sh  # Linux/Mac
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
- Or run `verify-codex.bat` (Windows) or `bash verify-codex.sh` (Linux/Mac) for detailed verification

## Project Structure

```
codex-app/
├── config.json.example       # Example centralized config (commit this)
├── codex.toml.example        # Example Codex config (commit this)
├── config.json               # Your actual config (gitignored - contains secrets)
├── codex.toml                # Your actual config (gitignored - contains secrets)
├── .codex/
│   ├── setup.sh              # Main setup script
│   ├── package.json          # Codex dependencies
│   ├── .env                  # API keys (gitignored)
│   ├── home/
│   │   ├── config.toml       # Linked from root codex.toml (auto-created)
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

This project uses a **centralized configuration system** with all config files in the **root directory** for easy management:

- **`config.json.example`** (root) - Example centralized config (commit this)
- **`codex.toml.example`** (root) - Example Codex config (commit this)
- **`config.json`** (root) - Your actual config (gitignored - contains endpoints/secrets)
- **`codex.toml`** (root) - Your actual config (gitignored - contains endpoints/secrets)
- **`.env`** (root) - API keys (gitignored, never committed)
- **`.codex/home/config.toml`** - Auto-linked from root `codex.toml` (don't edit directly)

### Configuration Files Overview

**Yes, all configuration is managed in just two files:**

1. **`codex.toml`** - **Primary config** (Codex reads this directly)
   - All runtime settings (model, provider, MCP servers, features, timeouts)
   - This is the source of truth for Codex

2. **`config.json`** - **Helper config** (used by launcher scripts)
   - Provider type and API key env var name
   - MCP server enable/disable flags
   - Used by config manager and launcher scripts

3. **`.env`** (root) - **Secrets only** (API keys)

**⚠️ Important:** 
- `config.json` and `codex.toml` are gitignored because they contain sensitive info (endpoints, deployment names)
- Always commit the `.example` files as templates
- New team members should run `setup-config.bat` to create their config files
- **`codex.toml` is the primary config** - edit this for most settings
- See **[CONFIG-GUIDE.md](CONFIG-GUIDE.md)** for detailed configuration guide

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

**Switch providers:** Edit `config.json` (root) and update `codex.toml` (root) accordingly.

See **[.codex/CONFIG.md](.codex/CONFIG.md)** for detailed configuration guide.

## Platform-Specific Notes

### Linux
- See **[INSTALL-LINUX.md](INSTALL-LINUX.md)** for detailed Linux installation guide
- Make scripts executable: `bash make-executable.sh` or `chmod +x codex .codex/*.sh`
- Use forward slashes in paths: `/home/user/projects/codex-app`
- Symlinks work natively (better than Windows)

### Windows
- Use `setup.bat` or `setup.ps1` for easier execution
- Use backslashes or forward slashes in paths (both work)
- Symlinks may require admin privileges (launcher falls back to copy)

### macOS
- Similar to Linux setup
- Use `bash setup.sh` for scripts
- Symlinks work natively

## General Notes

- Uses **Azure OpenAI** by default (configured in `config.json` and `codex.toml`)
- MCP servers are built from source, not npm packages
- The `.env` file contains your API keys and is gitignored for security
- **`.example` files should be committed** - they're templates for new team members
- **`config.json` and `codex.toml` are gitignored** - they contain sensitive info