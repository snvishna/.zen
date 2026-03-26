#!/bin/bash
# Fix broken symlinks created by zen-load

set -e

ZEN_HOME="${HOME}/.zen"
STOW_DIR="${ZEN_HOME}/stow"

echo "🔧 Fixing broken symlinks..."

# Remove all the broken .bak symlinks
echo "Removing broken backup symlinks..."
t ~/.config.pre-zen-*.bak 2>/dev/null || true

# Remove the current broken .config symlink
if [[ -L ~/.config ]]; then
    echo "Removing broken .config symlink..."
    t ~/.config
fi

# Create real .config directory if it doesn't exist
if [[ ! -d ~/.config ]]; then
    echo "Creating ~/.config directory..."
    mkdir -p ~/.config
fi

# Now restow all packages properly
echo ""
echo "Re-stowing packages..."
cd "$STOW_DIR"

# Stow each package - stow will handle merging into .config automatically
for pkg in zsh starship git bin atuin wezterm vscode nvim; do
    if [[ -d "$pkg" ]]; then
        echo "  - Stowing $pkg..."
        stow -R -d "$STOW_DIR" -t "$HOME" "$pkg" 2>&1 | sed 's/^/    /' || true
    fi
done

echo ""
echo "✅ Symlinks fixed!"
echo ""
echo "Verifying .config structure:"
ls -la ~/.config/ | head -20
