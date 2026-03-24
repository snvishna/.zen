# Zen-Load Fixes Applied

## Issues Found

1. **Broken symlink conflict resolution**: The script was backing up valid stow symlinks as "conflicts" when multiple packages wanted to share `.config`
2. **Missing directory creation**: LaunchAgents directory wasn't created before writing plist file

## Fixes Applied

### 1. Fixed `resolve_conflicts()` function
- Changed symlink validation to accept ANY symlink pointing into `.zen/stow/*` (not just the specific package)
- Removed directory checking from conflict resolution (stow handles directory merging automatically)
- This allows multiple packages (starship, atuin, wezterm, vscode, nvim) to properly share `.config`

### 2. Fixed LaunchAgent installation
- Added `mkdir -p "${HOME}/Library/LaunchAgents"` before writing plist file

## How to Fix Your Current System

Run the cleanup script:

```bash
cd ~/.zen
./fix-symlinks.sh
```

This will:
1. Remove all broken `.config.pre-zen-*.bak` symlinks
2. Remove the broken `.config` symlink
3. Create a real `.config` directory
4. Re-stow all packages properly (stow will merge them into `.config`)

## Expected Result

After running the fix script, you should have:
- `~/.config/` as a real directory (not a symlink)
- `~/.config/atuin/` → symlink to `.zen/stow/atuin/.config/atuin/`
- `~/.config/nvim/` → symlink to `.zen/stow/nvim/.config/nvim/`
- `~/.config/wezterm/` → symlink to `.zen/stow/wezterm/.config/wezterm/`
- `~/.config/vscode/` → symlink to `.zen/stow/vscode/.config/vscode/`
- etc.

This is how stow is designed to work - it creates a real parent directory and symlinks the subdirectories.

## Testing

After running the fix script, test that configs work:
```bash
# Check wezterm config
wezterm --version

# Check nvim config  
nvim --version

# Verify symlinks
ls -la ~/.config/
```


## Understanding the Structure

Your stow packages have this structure:
```
stow/
├── atuin/.config/atuin/
├── nvim/.config/nvim/
├── starship/.config/starship.toml
├── vscode/.config/vscode/
└── wezterm/.config/wezterm/
```

When stowed properly, this creates:
```
~/.config/              (real directory)
├── atuin/             (symlink → .zen/stow/atuin/.config/atuin/)
├── nvim/              (symlink → .zen/stow/nvim/.config/nvim/)
├── starship.toml      (symlink → .zen/stow/starship/.config/starship.toml)
├── vscode/            (symlink → .zen/stow/vscode/.config/vscode/)
└── wezterm/           (symlink → .zen/stow/wezterm/.config/wezterm/)
```

The old buggy behavior was creating:
```
~/.config → .zen/stow/nvim/.config  (WRONG - points to one package only!)
```

## Future zen-load Runs

The fixed `zen-load` script will now work correctly on fresh systems. The key change is that it recognizes all `.zen/stow/*` symlinks as valid, allowing stow to properly merge multiple packages into shared parent directories.
