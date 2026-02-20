# Linux Installation Guide

This guide covers setting up Codex App on Linux.

## Prerequisites

- **Node.js 18+** and **npm**
- **Git**
- **Bash** (usually pre-installed)

Install if needed:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nodejs npm git

# Fedora/RHEL
sudo dnf install nodejs npm git

# Arch Linux
sudo pacman -S nodejs npm git
```

## Installation Steps

### 1. Clone or Navigate to Project

```bash
cd /path/to/codex-app
```

### 2. Install Codex Dependencies

```bash
cd .codex
npm install
cd ..
```

### 3. Setup MCP Servers

```bash
cd .codex/mcp
bash setup.sh
cd ../..
```

### 4. Setup Configuration Files

```bash
cd .codex
bash setup-config.sh
cd ..
```

This creates `config.json` and `codex.toml` from example files.

### 5. Edit Configuration

Edit the config files in the root directory:

**`config.json`:**
```json
{
  "provider": {
    "base_url": "https://your-deployment-name.openai.azure.com/openai",
    "model": "your-model-name"
  }
}
```

**`codex.toml`:**
- Update `base_url` with your Azure deployment URL
- Update `model` with your deployment name
- Update project paths (if needed):
  ```toml
  [projects.'/home/user/projects/codex-app']
  trust_level = "trusted"
  ```

### 6. Set API Key

Edit `.env` (root directory):
```bash
nano .env
```

Add:
```
AZURE_OPENAI_API_KEY=your-actual-key-here
```

### 7. Make Launcher Executable

```bash
chmod +x codex
```

### 8. Run Codex

```bash
./codex
```

Or for one-shot commands:
```bash
./codex "your task here"
```

## Quick Setup Script

You can also run the main setup script:

```bash
cd .codex
bash setup.sh
cd ..
```

This will:
- Install dependencies
- Setup MCP servers
- Create config files
- Make scripts executable

## Verification

Check your setup:
```bash
./codex --info
```

This shows:
- Local installation paths
- Configuration files
- Environment variables

## Troubleshooting

### Permission Denied

If you get "Permission denied" when running `./codex`:
```bash
chmod +x codex
chmod +x .codex/setup.sh
chmod +x .codex/mcp/setup.sh
```

### Node.js Not Found

Install Node.js:
```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 18
nvm use 18

# Or use package manager
sudo apt install nodejs npm  # Ubuntu/Debian
```

### jq Not Found (Optional)

The config manager uses `jq` for JSON parsing. Install if needed:
```bash
sudo apt install jq  # Ubuntu/Debian
sudo dnf install jq  # Fedora/RHEL
```

If `jq` is not available, the launcher will use default values.

### Symlink Issues

If symlinks don't work, the launcher will automatically fall back to copying the config file.

## Path Differences

**Windows paths:**
```toml
[projects.'D:\\PROJECTS\\codex-app']
```

**Linux paths:**
```toml
[projects.'/home/user/projects/codex-app']
```

The `codex.toml.example` file has placeholders - update them to match your system.

## Next Steps

- See [README.md](README.md) for usage instructions
- See [CONFIG-GUIDE.md](CONFIG-GUIDE.md) for configuration details
- See [USAGE.md](USAGE.md) for detailed usage guide
