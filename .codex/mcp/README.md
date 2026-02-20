# MCP Servers Setup

This directory contains scripts to clone and build MCP (Model Context Protocol) servers from the official repository.

## Setup

### On Windows (Easiest - Recommended):

**Just double-click or run:**
```batch
cd .codex\mcp
setup.bat
```

Or simply double-click `setup.bat` in Windows Explorer.

### On Windows (PowerShell):

**Option 1: Direct execution (if execution policy allows):**
```powershell
cd .codex\mcp
.\setup.ps1
```

**Option 2: Bypass execution policy:**
```powershell
cd .codex\mcp
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

**Option 3: Use the simpler script:**
```powershell
cd .codex\mcp
powershell -ExecutionPolicy Bypass -File .\setup-simple.ps1
```

### On Linux/Mac or Git Bash (Windows):
```bash
cd .codex/mcp
bash setup.sh
```

## What it does:

1. **Clones the MCP servers repository** from GitHub:
   - Repository: https://github.com/modelcontextprotocol/servers
   - Location: `.codex/mcp/servers/`

2. **Builds the filesystem server**:
   - Installs dependencies
   - Builds the TypeScript project
   - Output: `.codex/mcp/servers/src/filesystem/dist/index.js`

3. **Verifies the build** was successful

## Adding More Servers

To add additional MCP servers (e.g., git, sequentialthinking):

1. Clone the repository (already done if you ran setup)
2. Navigate to the server directory: `cd .codex/mcp/servers/src/<server-name>`
3. Install and build: `npm install && npm run build`
4. Update `.codex/home/config.toml` to include the new server configuration

## Configuration

The built servers are referenced in `.codex/home/config.toml`:

```toml
[mcp_servers.filesystem]
command = "node"
args = [
  ".codex/mcp/servers/src/filesystem/dist/index.js",
  ".",
  ".codex/home/skills"
]
```

## Troubleshooting

- **Build fails**: Make sure Node.js 18+ is installed
- **Git clone fails**: Check your internet connection and git installation
- **Permission errors**: On Windows, run PowerShell as Administrator if needed
