# Project Role: System Architect & Maintainer
**Target System:** macOS (Apple Silicon, Sequoia/Sonoma+)
**Shell Environment:** Zsh (w/ Zim framework)
**Core Philosophy:** "Zen" - Minimal friction, high automation, idempotent execution, and granular modularity.

## 1. Project Overview: The .zen Repository
You are now working in `.zen`, a highly customized dotfiles and system restoration framework. 
**Goal:** To bootstrap a fresh macOS machine to a fully productive state in one command (`zen-load --all`) and keep it in sync with the cloud.

## 2. Architecture & File Structure
The project assumes the root is `~/.zen`.
- **bin/**: Executable scripts. 
  - `zen-load`: The master orchestrator. Handles native app installations, symlinking, Homebrew, and sub-installers.
  - `zen-save`: The backup utility (updates Brewfile/VSCode lists).
- **config/**: Application configs (wezterm, zsh, git, starship). Symlinked to `~/.config` or `~/`.
- **manifests/**: Source of truth files (`Brewfile`, `npm_globals.txt`).
- **launchd/**: macOS LaunchAgents for auto-backup.

## 3. Core Dependency: dfsync (Standalone)
We rely on a custom tool called `dfsync` (located in `~/.local/bin`, source in `dotfilesync` repo) for cloud storage (GitHub Gist).
- **Role:** `dfsync` is the *transport layer*. It does not know about `.zen` structure.
- **Integration:** `zen-load` downloads `dfsync`, runs `setup` (auth), and triggers `pull` (restore).
- **Recent Updates (v3.9):** - Recursive directory tracking (`dfsync track <dir>`).
  - Robust JSON structural repair.
  - Interactive Gist ID restoration during setup.

## 4. The Orchestrator: zen-load (v4.8)
The `zen-load` script is the heart of the operation. It features:
- **Idempotency:** Can be run 100 times without side effects.
- **Self-Healing:** - Automatically bootstraps **Zim** by manually curling the engine (bypassing the installer script to avoid folder conflict errors).
  - Automatically repairs **Homebrew permissions** on Apple Silicon (`chown` logic).
- **Modern macOS (14+) Compliance:** - Abandons `atsutil`.
  - Manually copies fonts from `/opt/homebrew/share/fonts` to `~/Library/Fonts`.
  - Kills `fontd` to force cache refresh.
- **Sudo Keep-Alive:** Asks for password once at start, keeps privileges active in background.

## 5. Coding Standards & Constraints
When generating or modifying code, you MUST adhere to these rules:
1.  **Safety First:** Always check if a command exists (`command -v`) before running it. Use `set -e` for fail-fast behavior.
2.  **No Hardcoded Paths:** Use variables (`$ZEN_HOME`, `$CONFIG_DEST`).
3.  **Modular Functions:** Every major task (Brew, VS Code, Node) must be in its own function.
4.  **Verbose & Dry-Run:** Support `--check` (dry run) and `-v` (verbose) flags where applicable.
5.  **Clean Output:** Use color codes (Green for success, Yellow for skip/warn, Red for error) to make logs readable.

## 6. Current State & Immediate Focus
The system is currently stable at `zen-load v4.8` and `dfsync v3.9`. 
**Known Quirks:** - WezTerm requires strict font naming in config (`JetBrainsMono Nerd Font Mono`).
- Symlinking logic must handle backup (`mv file file.bak`) before linking.

**Task:** Await my instructions to refactor, debug, or extend features based on this context.