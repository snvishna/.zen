
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"

#  Zen Profile (v2.0)
# Environment Variables & Paths (Runs once at login)

# 1. Homebrew Setup (Apple Silicon)
if [ -d "/opt/homebrew/bin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Homebrew Setup (Intel Fallback)
if [ -d "/usr/local/bin" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Add Zen Binaries to PATH
export PATH="$HOME/.local/bin:$PATH"


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"
