# How to Run and Use Codex App

## Quick Start Guide

### Platform-Specific Setup

**Linux/Mac:**
```bash
# Make scripts executable
bash make-executable.sh

# Run setup
cd .codex
bash setup.sh
cd ..
```

**Windows:**
```batch
cd .codex
setup.bat
```

### Step 1: Initial Setup (One-time)

#### 1.1 Install Codex Dependencies
```powershell
cd .codex
npm install
```

This installs the `@openai/codex` package locally.

#### 1.2 Setup MCP Servers

**On Linux/Mac:**
```bash
cd .codex/mcp
bash setup.sh
```

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

**On Windows (Git Bash):**
```bash
cd .codex/mcp
bash setup.sh
```

This will:
- Clone the MCP servers repository from GitHub
- Build the filesystem server
- Take a few minutes the first time

#### 1.3 Setup Configuration Files

**On Linux/Mac:**
```bash
cd .codex
bash setup-config.sh
cd ..
```

**On Windows:**
```batch
cd .codex
setup-config.bat
```

This creates `config.json` and `codex.toml` from example files.
Then edit them with your actual values (endpoints, deployment names).

#### 1.4 Configure API Keys

Edit `.env` file (root directory) and add your Azure OpenAI API key:

```
AZURE_OPENAI_API_KEY=your-actual-azure-api-key-here
```

**Or** if you prefer OpenAI (fallback):
```
OPENAI_API_KEY=sk-your-actual-key-here
```

> **Note:** The `.env` file is gitignored for security. Never commit your API keys!

---

### Step 2: Running Codex

#### Option A: Interactive Mode (TUI)

**On Linux/Mac:**
```bash
./codex
```

**On Windows (Git Bash or WSL):**
```bash
./codex
```

**On Windows (PowerShell):**
```powershell
.\codex.ps1
```

**On Windows (Command Prompt):**
```batch
codex.bat
```

**Note:** On Linux, make sure the script is executable:
```bash
chmod +x codex
```

This opens an interactive terminal UI where you can:
- Chat with Codex
- Ask it to read, modify, and create files
- Run commands with approval
- Use MCP servers for filesystem operations

#### Option B: One-Shot Commands

Run Codex with a specific task:

```bash
./codex "add type hints to all Python files"
```

```bash
./codex "create a README.md file explaining the project"
```

```bash
./codex "refactor the utils module to use async/await"
```

#### Option C: Help and Options

```bash
./codex --help
```

---

## Common Usage Examples

### 1. Reading and Understanding Code
```bash
./codex "explain what the main function does in src/index.js"
```

### 2. Making Code Changes
```bash
./codex "add error handling to the API client"
```

### 3. Creating New Files
```bash
./codex "create a new component called Button.tsx with TypeScript"
```

### 4. Refactoring
```bash
./codex "refactor the database queries to use prepared statements"
```

### 5. Debugging
```bash
./codex "find and fix the bug causing the memory leak"
```

---

## Interactive Mode Features

When you run `./codex` without arguments, you enter interactive mode:

### Available Commands in TUI:
- Type your questions/tasks directly
- Codex will read files, make changes, and run commands
- You'll see a preview of changes before they're applied (depending on approval mode)
- Use MCP tools for filesystem operations

### Approval Modes:
- **Current setting**: `never` (full access) - Codex can make changes directly
- You can change this in `.codex/home/config.toml` if you want more control

---

## Verifying Local Installation

To confirm you're using the **local** Codex installation (not global):

### Quick Check:
```bash
./codex --info
```

This shows:
- Project root path
- Local Codex binary location
- Config file location
- Environment variables

### Detailed Verification:

**On Windows:**
```batch
verify-codex.bat
```

**On Linux/Mac or PowerShell:**
```powershell
powershell -ExecutionPolicy Bypass -File verify-codex.ps1
```

This script checks:
- ✓ Local Codex binary exists
- ✓ Local config file exists
- ✓ Environment variables are set correctly
- ⚠️ Warns if global Codex is also installed

### How to Tell You're Using Local:

1. **Check the binary path**: Run `./codex --info` and verify the "Codex Binary" path points to `.codex/node_modules/.bin/codex`

2. **Check environment variables**: The `CODEX_HOME` should point to `.codex/home` in your project

3. **Check config**: Your local config at `.codex/home/config.toml` should be used (not global config)

4. **Use the project launcher**: Always run `./codex` (with `./`) not just `codex` (which might use global)

---

## Troubleshooting

### Issue: "Not installed. Run: ./.codex/setup.sh"
**Solution:** Run `npm install` in the `.codex` directory:
```powershell
cd .codex
npm install
```

### Issue: "Set AZURE_OPENAI_API_KEY in .env"
**Solution:** Edit `.env` (root directory) and add your API key:
```
AZURE_OPENAI_API_KEY=your-key-here
```

### Issue: MCP server not found
**Solution:** Run the MCP setup script:
```powershell
cd .codex\mcp
.\setup.ps1
```

### Issue: Permission denied on `./codex`
**Solution (Windows):** Use Git Bash or WSL, or run:
```powershell
bash codex
```

**Solution (Linux/Mac):** Make it executable:
```bash
chmod +x codex
```

### Issue: Node.js not found
**Solution:** Install Node.js 18+ from https://nodejs.org

---

## Configuration

### Main Config File: `.codex/home/config.toml`

Key settings you might want to adjust:

```toml
# Change approval policy (current: "never")
[approval]
policy = "never"  # Options: "never", "always", "on-request"

# Change sandbox mode (current: "danger-full-access")
[sandbox]
mode = "danger-full-access"  # Options: "read-only", "workspace-write", "danger-full-access"

# Model settings
model = "gpt-5.1-codex-mini"
model_provider = "azure"
```

### MCP Servers

The filesystem MCP server is configured in `config.toml`:
- Allows Codex to read/write files in your project
- Access to `.codex/home/skills` directory
- Configured with 30s startup timeout and 1hr tool timeout

---

## Tips for Best Results

1. **Be Specific**: Instead of "fix bugs", say "fix the null pointer exception in UserService.java line 42"

2. **Use Context**: Codex can read your files, but providing context helps:
   ```
   "In the auth module, add JWT token validation"
   ```

3. **Iterative Approach**: Break large tasks into smaller ones:
   ```
   "First, create the database schema"
   "Then, create the API endpoints"
   "Finally, add error handling"
   ```

4. **Review Changes**: Even with `approval = "never"`, review what Codex changes before committing

5. **Use Skills**: Add project-specific guidance in `.codex/home/skills/` to help Codex understand your project better

---

## Next Steps

1. ✅ Complete the setup steps above
2. ✅ Run `./codex` to start interactive mode
3. ✅ Try a simple task like "list all files in the project"
4. ✅ Ask Codex to help with your actual project tasks

Happy coding! 🚀
