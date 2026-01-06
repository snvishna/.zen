# Migration Walkthrough: .zen to GNU Stow

I have successfully refactored your dotfiles framework to use **GNU Stow**. This fixes the path issues, resolves WezTerm font errors, and cleans up the Zim setup.

## 1. New Structure
Your configurations now live in `~/.zen/stow/`. Each subdirectory is a "package" that Stow manages.

- `stow/zsh/` → Symlinks to `~/.zshrc`
- `stow/wezterm/` → Symlinks to `~/.config/wezterm/`
- `stow/bin/` → Symlinks to `~/.local/bin/` (contains `zen-load` & `zen-save`)

## 2. Changes Made
- **Directory**: Moved all `config/` folders to `stow/`.
- **Scripts**: Rewrote `zen-load` and `zen-save` to rely on `stow` instead of custom loop logic.
- **Binaries**: `zen-load` and `zen-save` are now symlinked from `stow/bin` into `~/.local/bin`.
- **Zim**: Deleted committed modules (`config/zim/modules`). `zimfw` will now cleanly reinstall them on next shell startup or `zen-load` run.
- **Fonts**: Added logic to `zen-load` to auto-copy Nerd Fonts to `~/Library/Fonts` if missing (fixing WezTerm).
- **Zsh**: Integrated "Zen" aliases and `ha` (Help Alias) function interactively searchable via `fzf`. Added power tools `zoxide`, `eza`, `bat`, `fd`, `trash`.

## 3. How to Use
Run the commands as usual. They now use Stow under the hood.

### Restore / Update
```bash
zen-load
```
*Checks for missing fonts, runs `stow -R` to relink configs, and ensures Zim is ready.*

### Snapshot / Backup
```bash
zen-save --all
```
*Dumps Brewfile, VS Code extensions, and macOS defaults to `manifests/`.*
### 3. Zsh Power-Up
- **New Utilities**: Added `zoxide`, `eza`, `bat`, `fd`, `trash`, `tldr`, `btop`.
- **Searchable Aliases**: Added `ha` function to fuzzy-find aliases by description.
- **Completion Fix**: Removed manual `compinit` to let Zim handle it correctly (fixing startup warnings).

### 4. Robust Conflict Resolution
- **Philosophy**: "Backup & Overwrite".
- **Mechanism**: `zen-load` now pre-checks every Stow target.
    - If a **real file** exists (conflict): It moves it to `.pre-zen.bak` (Safe).
    - If a **broken link** exists: It deletes it (Clean).
- **Result**: You can run `zen-load` on a messy fresh Mac, and it will "just work" without errors or data loss.

### 5. Security & PII Audit
- **Templates**: PII-laden files (like `Recents.savedSearch` and LaunchAgents) are now templates.
    - `zen-load` dynamically generates them using `{{HOME}}` substitution at install time.
- **Quarantine**: Replaced the brute-force `xattr` scan with `HOMEBREW_CASK_OPTS="--no-quarantine"`. Cleaner and faster.
- **Cleaning**: Removed internal paths and ignored sensitive artifacts in `.gitignore`.

### 6. Terminal as Editor (New!)
WezTerm and Zsh now work together to provide a GUI-like editing experience on the command line:

| Action | Shortcut | Behavior |
| :--- | :--- | :--- |
| **Undo / Redo** | `Cmd+Z` / `Shift+Z` | Undo typing (no more holding backspace!). |
| **Highlight** | `Shift + Arrows` | Visual selection (like in Word/VS Code). |
| **Vertical** | `Shift + Up/Down` | Select multiple lines. |
| **Word Select** | `Shift + Option + Arrows` | Select word-by-word. |
| **Type-Replace**| *Type over selection* | **Overwrites** selected text (Editor style!). |
| **Type-Replace**| *Type over selection* | **Overwrites** selected text (Editor style!). |
| **Copy / Cut** | `Cmd+C` / `Cmd+X` | Copy/Cut selection to system clipboard. |
| **Smart Paste** | `Cmd+V` | **Replaces** selected text if highlighted, else pastes. |
| **Multi-line** | `Shift+Enter` | Insert new line without executing. |
| **Line Select** | `Cmd+Shift+Left` | Select to start of line. |

### 7. New "Zen Glass" Visuals & Power Tools
- **Completion**: Press `<Tab>` to see an interactive menu.
    - **Previews**: Selecting a file shows its content automatically in a side panel.
- **Visuals**:
    - **Glass**: 90% Opacity + Background Blur.
    - **Focus**: Inactive panes are dimmed.
    - **Tabs**: Moved to bottom for a cleaner header.

### Verify Connectivity
To check if Stow is happy:
```bash
zen-load --check
```

## 4. Verification
I have run `stow` manually, and the symlinks are active. You can verify this by running:
```bash
ls -l ~/.config/wezterm/wezterm.lua
# Should point to .zen/stow/wezterm/.config/wezterm/wezterm.lua
```

Your WezTerm error `No such file or directory` should now be resolved.
