#  .zen
> *The Art of Maintenance-Free macOS Automation.*

**Current Status:** `v5.0` (Stow Edition)  
**System:** macOS Sequoia+ (Apple Silicon)

`.zen` is a highly opinionated, "zero-friction" dotfiles framework designed to bootstrap a fresh Mac into a powerhouse development machine in minutes. It prioritizes **automation**, **idempotency**, and **clean architecture**.

---

## 🚀 Quick Start

### Bootstrap a Fresh Mac
One command to rule them all. Installs Homebrew, Stow, Fonts, Apps, and links all configurations.

```bash
# Clone to ~/.zen
git clone https://github.com/snvishna/.zen.git ~/.zen

# Run the Orchestrator
~/.zen/stow/bin/.local/bin/zen-load --all
```

### Daily Usage
- **Update/Relink Configs:** `zen-load`
- **Snapshot System:** `zen-save --all`
- **Verify Health:** `zen-load --check`

---

## 🧘 Architecture & Philosophy

This repository solves the two hardest problems in dotfile management: **Placement** and **Transport**.

### 1. Placement: GNU Stow
We use **GNU Stow** to manage symlinks. Instead of a complex shell script trying to guess where files go, we use a declarative directory structure.
- **Source:** `~/.zen/stow/package/path/to/file`
- **Target:** `~/path/to/file`

**Directory Structure:**
```text
~/.zen
├── stow/               # The "Packages"
│   ├── zsh/            # -> links to ~/.zshrc
│   ├── wezterm/        # -> links to ~/.config/wezterm
│   ├── bin/            # -> links to ~/.local/bin
│   └── vscode/         # -> links to ~/.config/vscode
├── manifests/          # The "Database"
│   ├── Brewfile        # All apps and CLIs
│   └── npm_globals.txt # Node packages
└── bin/                # (Symlinked) Orchestration scripts
```

### 2. Transport: dfsync
We distinguish between **Public Structure** and **Private Data**.
- **Public (.zen):** This Git repo. Contains the *machinery* and *structure*.
- **Private (dfsync):** Contains your *tokens*, *secrets*, and *private env vars*.
- `dfsync` (included in `bin/`) syncs these secrets from a private GitHub Gist, keeping this repo clean and shareable.

---

## 🛠 The Stack

### Shell Environment (Zsh + Zim + Starship)
We use a layered approach for a blazing fast shell:
1.  **Zsh:** The base shell.
2.  **Zim:** A framework faster than Oh-My-Zsh. We use `zimfw` to compile modules locally in `~/.zim`, keeping the repo clean.
3.  **Starship:** The prompt. Minimalist, fast, and informative (Git status, Node version, Rust version, etc.).

### Terminal: WezTerm
GPU-accelerated, Lua-configured terminal.
- **Font:** JetBrains Mono Nerd Font (Auto-installed by `zen-load`).
- **Key Features:**
    - `Cmd+K`: Clear scrollback.
    - `Cmd+F`: Search buffer.
    - `Cmd+T`: New tab.
    - **Copy Mode (`Cmd+Shift+Space`)**: Vim-like text selection and copying without a mouse.

### Apps & CLIs (Homebrew)
All dependencies are managed via `manifests/Brewfile`.

#### Core Utilities
| Tool | Replacement For | Why? |
| :--- | :--- | :--- |
| **`starship`** | Prompt | Instant git status, contextual info, Rust-based speed. |
| **`zoxide`** | `cd` | Jumps to directories by name/frequency (`z project`). |
| **`eza`** | `ls` | Colors, icons, git integration, tree view. |
| **`bat`** | `cat` | Syntax highlighting, line numbers, git modifications. |
| **`fd`** | `find` | Faster, ignores `.git` automatically, simple syntax. |
| **`ripgrep`** | `grep` | The fastest text searcher in the world. |
| **`fzf`** | `Ctrl+R` | Fuzzy finder for history, files, and processes. |
| **`trash`** | `rm` | Moves files to macOS Trash instead of permanent deletion. |
| **`tldr`** | `man` | Practical examples instead of long manuals. |
| **`btop`** | `top` | Beautiful, clickable system monitor. |

#### GUI Applications
- **Raycast:** Spotlight on steroids. Scriptable launcher, clipboard manager, snippet host.
- **Rectangle:** Window snapping (`Ctrl+Opt+Arrows`).
- **Stats:** Menu bar system monitor (CPU/RAM/Net).
- **VS Code:** Configured with `catppuccin` theme and key extensions (synced via `stow/vscode`).

---

## 🔧 Scripts

### `zen-load` (The Orchestrator)
The brain of the operation.
- **What it does:**
    1.  Checks/Installs **Homebrew**.
    2.  Installs **Stow** and **Fonts** (auto-copies to `~/Library/Fonts`).
    3.  Runs `stow` to link all configurations.
    4.  Runs `brew bundle` to install apps.
    5.  Fixes macOS "Quarantine" attribute on new apps.
    6.  Sets up **Zim** and **dfsync**.
- **Usage:** `zen-load --all` (Full bootstrap) or `zen-load` (Refresh links).

### `bin/zen-save` (The Snapshotter)
- **What it does:**
    1.  Dumps current Brew installs to `manifests/Brewfile`.
    2.  Dumps VS Code extensions to `stow/vscode/.../extensions.txt`.
    3.  Dumps macOS `defaults` to `manifests/macos/`.
- **Usage:** `zen-save` (Snapshot) or `zen-save --sync` (Snapshot + Cloud Push).

---

## ⌨️ Zen Aliases
Your `.zshrc` is packed with "Zen" aliases for speed.

| Alias | Command | Description |
| :--- | :--- | :--- |
| `ha` | `fzf`... | **Help Alias:** Fuzzy search all aliases by description. |
| `z` | `zoxide` | Smart directory jump. |
| `ll` | `eza ...` | List files with details and git status. |
| `..` | `cd ..` | Go up one level. |
| `gp` | `git push` | Git Push. |
| `gd` | `delta` | Beautiful side-by-side diffs. |
| `ft` | `rg` | **Find Text:** Search inside files. |
| `ff` | `fd` | **Find File:** Search for filenames. |
| `cpd` | `pbcopy` | Copy current directory path. |
| `mkcd`| `mkdir && cd` | Make directory and enter it. |

---

> Built with 🧘 by Shankar.
