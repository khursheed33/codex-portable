# Migration Guide: Centralized Configuration

All configuration files have been moved to the **root directory** for easier management.

## What Changed

### Before (Old Structure)
```
.codex/
├── config.json          ❌ Duplicate
├── .env                 ❌ Hidden location
└── home/
    └── config.toml      ❌ Manual editing required
```

### After (New Structure)
```
codex-app/
├── config.json          ✅ Single source of truth
├── codex.toml           ✅ Single source of truth
└── .env                 ✅ Easy to find and edit
```

## Migration Steps

### 1. Move Your `.env` File

If you have an existing `.codex/.env` file:

**On Linux/Mac:**
```bash
mv .codex/.env .env
```

**On Windows:**
```batch
move .codex\.env .env
```

### 2. Update Your Config Files

Your `config.json` and `codex.toml` should already be in the root directory. If not:

1. Copy from examples:
   ```bash
   cd .codex
   bash setup-config.sh
   ```

2. Update with your values (endpoints, deployment names, etc.)

### 3. Delete Old Files (Already Done)

The following files have been automatically deleted:
- `.codex/config.json` (duplicate)
- `.codex/home/config.toml` (will be auto-created at runtime)

### 4. Verify Setup

Run the launcher to verify everything works:
```bash
./codex --info
```

This should show:
- Config File: `codex.toml` (root)
- Central Config: `config.json` (root)
- API keys loaded from `.env` (root)

## How It Works Now

1. **All configs in root**: `config.json`, `codex.toml`, `.env`
2. **Runtime copy**: The launcher automatically copies/links `codex.toml` to `.codex/home/config.toml` when Codex starts
3. **Single source of truth**: Edit files in root, they're automatically used

## Benefits

✅ **Easier to find**: All configs in one place (root directory)  
✅ **Easier to edit**: No need to navigate hidden directories  
✅ **No duplicates**: Single source of truth for each config  
✅ **Auto-sync**: Runtime copy ensures Codex always uses latest config  
✅ **Version control**: Only `.example` files are committed (templates)

## Troubleshooting

### "Config file not found" Error

Run the setup script:
```bash
cd .codex
bash setup-config.sh
```

### API Key Not Working

Make sure `.env` is in the root directory (not `.codex/.env`):
```bash
# Check location
ls -la .env

# Should show: .env in root directory
```

### Old Config Still Being Used

1. Delete `.codex/home/config.toml` (it will be recreated from root)
2. Restart Codex: `./codex`

The launcher will automatically copy the latest `codex.toml` from root.
