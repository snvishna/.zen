
#  .zen


**The Zen Garden for macOS.**

A holistic, modular, and resilient dotfiles framework designed to keep your development environment in perfect harmony.


---


## 🧘 Philosophy


Most dotfile setups are fragile "symlink farms" or giant monolithic scripts. **.zen** separates concerns into three distinct layers:


1.  **Core Configs:** Pure configuration files (`.zshrc`, `starship.toml`) stored in `config/`.

2.  **Manifests:** Declarative lists of what *should* be installed (`Brewfile`, `npm_globals.txt`, `extensions.txt`).

3.  **Automation:** Smart scripts (`zen-load`, `zen-save`) that enforce state without breaking things.


It integrates seamlessly with **[dfsync](https://github.com/snvishna/dotfilesync)** for secure, cloud-based synchronization of critical secrets and portable configs.


---


## 📂 Structure


```text

~/.zen

├── bin/                 # The brain (automation scripts)

│   ├── zen-load         # Restores environment (Idempotent installer)

│   └── zen-save         # Snapshots current state to manifests

├── config/              # The body (actual config files)

│   ├── zsh/             # Shell configuration

│   ├── wezterm/         # Terminal emulator settings

│   ├── vscode/          # VS Code settings & keybindings

│   └── macos/           # System defaults (defaults write ...)

├── manifests/           # The memory (declarative lists)

│   ├── Brewfile         # Homebrew formulas & casks

│   ├── npm_globals.txt  # Node.js global packages

│   └── extensions.txt   # VS Code extensions list

└── launchd/             # Auto-backup agents

```


---


## 🚀 Getting Started


### Prerequisites

* **macOS** (Latest or recent version)

* **Git**


### Installation (Bootstrapping)


1.  Clone this repository to your home directory:

    ```bash

    git clone https://github.com/snvishna/.zen.git ~/.zen

    ```


2.  Run the **Zen Load** utility to hydrate your system:

    ```bash

    ~/.zen/bin/zen-load --all

    ```


This command will:

1.  **Link:** Symlink all configs to their correct locations (`~/.config`, `~/.zshrc`, etc).

2.  **Install:** Homebrew packages, Node globals, VS Code extensions, and `dfsync`.

3.  **Configure:** Apply macOS system defaults and setup auto-backup hooks.


---


## 🧠 The Zen Stack


This environment is opinionated. It is built for **speed**, **keyboard-centric navigation**, and **aesthetic consistency**.


### 1. The System Layer ("Ludicrous Speed")

The included `defaults.sh` script transforms macOS behavior:

* **Input:** Key repeat rates are pushed beyond System Settings limits (`InitialKeyRepeat 10`, `KeyRepeat 3`) for instant cursor movement. "Press and Hold" for accents is disabled in favor of key repetition.

* **Trackpad:** Natural scrolling is **disabled** (standard direction enforced). Three-finger drag is enabled.

* **UI:** Window animations are disabled for "snappy" response times.


### 2. The Terminal Layer

We bypass Terminal.app/iTerm2 in favor of **WezTerm**:

* **Renderer:** Uses `WebGpu` for 120FPS performance.

* **Aesthetics:** "Catppuccin Mocha" theme with custom Neon Green foreground (`#a6e3a1`) and "Frosted Glass" transparency.

* **Keybindings:** Re-mapped to behave like a tiling window manager (Split/Move panes via `CMD + Arrow/d`).

* **Shell:** Zsh + Starship prompt (auto-detects project context like Node/Rust/Docker versions).


### 3. The Interface Layer

We replace native window management with faster alternatives:

* **Raycast:** Replaces Spotlight. Scriptable launcher for apps, math, and system commands.

* **Rectangle:** Adds Windows-style window snapping (halves, thirds, maximize) via keyboard.

* **AltTab:** Brings Windows-style `Alt+Tab` window switching (with previews) to macOS.

* **Ice:** Hides menu bar clutter.


### 4. The Dev Layer

* **Editors:** VS Code (Catppuccin theme, AI-heavy setup with Copilot) + Neovim.

* **Runtime:** `nvm` for managing multiple Node.js versions.

* **Tools:** `ripgrep` (fast search), `jq` (JSON parsing), `fzf` (fuzzy finding).

* **AI:** `Kiro` (Agent-centric IDE).


---


## 🛠 Usage


### `zen-load` (Restore)

Use this when pulling changes from git or setting up a new machine.


* **Fast Sync (Symlinks only):**

    ```bash

    zen-load

    ```

* **Full Install (Apps, Brew, Defaults):**

    ```bash

    zen-load --all

    ```

* **Check for Conflicts (Dry Run):**

    ```bash

    zen-load --check

    ```

* **Update `dfsync` binary:**

    ```bash

    zen-load --dfsync --force

    ```


### `zen-save` (Snapshot)

Use this before committing changes. It dumps your *current* system state into the `manifests/` directory.


```bash

zen-save

```

* Updates `Brewfile` from currently installed formulas.

* Updates `npm_globals.txt`.

* Updates `extensions.txt` from VS Code.

* *Note: This runs automatically every night via `launchd`.*


---


## ☁️ Cloud Sync (dfsync)


This repo manages the *files*, but **dfsync** manages the *syncing* of those files to a private GitHub Gist (useful for secrets or portable configs).


* **Push changes to Gist:** `dfsync push`

* **Pull changes from Gist:** `dfsync pull`


---


## 📜 License

MIT
