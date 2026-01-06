# Refactoring .zen to GNU Stow & Fixing Core Issues

## Goal Description
Refactor the `.zen` dotfiles framework to use **GNU Stow** for symlink management, replacing the custom `process_link` shell logic. Address critical setup issues with **Zim** (initialization errors) and **WezTerm** (missing fonts).

## User Review Required
> [!IMPORTANT]
> **Directory Structure Change**: This refactor will significantly alter the directory structure of `~/.zen`. All configuration files currently in `config/` will be moved to `stow/<package_name>/`.
> 
> **Zim Modules**: I propose deleting the currently committed Zim modules (`config/zim/modules`) and letting `zimfw` reinstall them fresh. This ensures platform compatibility and fixes the "folder conflict" errors you mentioned.

## Proposed Changes

### 1. Directory Restructuring (The "Zen" Stow Layout)
We will adopt a standard Stow package structure `stow/` at the project root. This keeps the "source" clean while populating `~` responsibly.

- **`stow/`** (Root for packages):
    - **`zsh/`** -> `stow/zsh/.zshrc`, `stow/zsh/.zprofile` (Target: `~`)
    - **`zim/`** -> `stow/zim/.config/zim/` (Target: `~/.config/zim`) — *Preserves `.zshrc` paths!*
    - **`wezterm/`** -> `stow/wezterm/.config/wezterm/` (Target: `~/.config/wezterm`) — *Preserves paths!*
    - **`bin/`** -> `stow/bin/.local/bin/` (Moves `zen-load`/`zen-save` here. Target: `~/.local/bin`)
    - **`launchd/`** -> `stow/launchd/Library/LaunchAgents/` (Target: `~/Library/LaunchAgents`)
    - **`git/`** -> `stow/git/.gitconfig`
    - **`vscode/`**, **`starship/`**, **`rectangle/`**, **`finder/`** -> Mapped similarly.

- **`manifests/`** (NO CHANGE):
    - Stays at root (`~/.zen/manifests`). This is the "database" (Brewfile, npm list) read by scripts. It is *not* a dotfile.

### 2. Logic Updates

#### [MODIFY] [zen-load](file:///Users/shankar/.zen/bin/zen-load)
- **Refactor Symlink Logic**: Replace custom loop with:
  ```bash
  # Ensure Stow is ready
  command -v stow >/dev/null || brew install stow
  # Stow all packages
  stow -d "$ZEN_HOME/stow" -t "$HOME" -R *
  ```
- **Path Safety**: The script will verify that critical paths (`~/.config/zim`, `~/.config/wezterm`) exist and resolve correctly after stowing.
- **dfsync Integration**:
    - `dfsync` binary stays in `~/.local/bin`.
    - Since `stow/bin` will likely be symlinked as individual files into `~/.local/bin` (because the dir exists), `dfsync` (a real file) will peacefully coexist with `zen-load` (a symlink).

#### [MODIFY] [zen-save](file:///Users/shankar/.zen/bin/zen-save)
- **Update** paths to point to the new `stow/` directories for snapshotting VS Code extensions and verifying configs.

#### [MODIFY] [.zshrc](file:///Users/shankar/.zen/config/zsh/.zshrc)
- **Verify** `ZIM_HOME` points to `~/.config/zim`.
- **Ensure** `zimfw` initialization logic handles a fresh install cleanly without erroring on existing directories.

### 3. Zim & Git Maintenance
- **Delete** `config/zim/modules` (and remove from Git) to allow `zimfw` to manage dependencies.
- **Update** `.gitignore` to ignore `stow/zim/.config/zim/modules`.

## Verification Plan

### Automated Tests
- **Dry Run**: Run `zen-load --check` (which we will update to use `stow -n -v`).
- **Idempotency**: Run `zen-load` twice to ensure Stow handles existing links correctly without error.

### Manual Verification
1. **Fonts**: Open WezTerm after running `zen-load`. Verify icons (Nerd Font) render correctly and "JetBrains Mono" is used.
2. **Zim**: Open a new Zsh terminal. Verify no error messages appear at the top. Check if syntax highlighting works.
3. **Structure**: `ls -l ~/.zshrc` should point to `.zen/stow/zsh/.zshrc`.

## Zsh Refactor & Zen Aliases
> [!NOTE]
> We are enhancing the shell experience with modern tools and "Zen" aliases.

### 1. New Dependencies (Brewfile)
We will add the following "champion" tools:
- `zoxide` (Smarter `cd`)
- `eza` (Better `ls`, replacing `lsd`)
- `bat` (Better `cat`)
- `fd` (Better `find`)
- `trash` (Safe `rm`)
- `tldr` (Simpler `man`)
- `btop` (Better `top`)

### 2. .zshrc Overhaul
Refactor `.zshrc` to support the "Help Alias" (`ha`) workflow:
- **Comments**: Every alias and export will have a `# Description` comment.
- **`ha` Function**: Add the smart fuzzy-finder for aliases.
- **Zen Aliases**: Implement the robust list (Navigation, Git, System).
- **Organization**: Move all aliases to the bottom of the file (as requested) to simplify future appends.
- **Safety**: Preserve existing `zen-load`/`zen-save` aliases and `zstats`.

## Cleanup & Final Polish
> [!NOTE]
> Simplifying the repo structure and ensuring high-quality documentation.

### 1. Zim Simplification (Repo Hygiene)
- **Goal**: Guarantee `.zen` repo only contains the config (`.zimrc`). All modules/builds must live in `~/.zim`.
- **Change**: Move `.zimrc` to `stow/zim/.zimrc`.
- **Update**: `.zshrc` to set `ZIM_HOME=${HOME}/.zim`. This ensures `zimfw` installs modules to the user's home dir, NOT into the `.zen` repo.

### 2. Trash Cleanup
- **Command**: Use `trash` (installed via brew) to separate the wheat from the chaff.
- **Targets**: `.zen/bin`, `.zen/config` (empty dirs), and any `*.bak`/`*.old` files found in the repo.

### 3. Documentation (README.md)
- **Rewrite**: Create a comprehensive `README.md` covering:
    - **Philosophy**: "Zen" approach + Stow integration.
    - **Directory Tree**: Visual explanation (using `tree`).
    - **Installation**: One-liner usage.
    - **Components**: Justifying Starship, Zim, etc.
    - **Dependencies**: Detailed table of Brew packages (eza, bat, etc.) and Apps (Raycast, WezTerm).

### 4. Gitignore Update
- **Goal**: Reflect new structure and ignore old paths.
- **Remove**: `config/*`, `bin/*` (old).
- **Add**: `stow/bin/.local/bin/dfsync` (just in case), `stow/zim/.zim` (if any).
- **Keep**: `.DS_Store`, `*.log`, `dfsync.json`.

### 5. PII & Security Cleanup
- **Launchd**: `com.shankar.configbackup.plist` contains `/Users/shankar`.
    - **Fix**: Remove `com.shankar.configbackup.plist` from repo. Keep `com.template.configbackup.plist`.
    - **Update**: `git` ignore the real plist.
    - **Script**: Update `zen-load` to generate the real plist from template on install.
- **Finder**: `Recents.savedSearch` contains hardcoded paths.
    - **Fix**: Replace `/Users/shankar` with `~` or remove file if binary/unfixable. (It's an XML plist, likely fixable).
- **Zshrc**: Contains Antigravity path.
    - **Fix**: Remove the Antigravity export line (it was added by the Agent, not needed for the user).
- **Gitignore**: Add `stow/launchd/Library/LaunchAgents/com.shankar.configbackup.plist`.

### 6. zen-load Conflict Resolution (Refactor)
- **Goal**: Handle pre-existing files gracefully on fresh installs (preventing Stow errors).
- **Strategy**: **"Backup & Overwrite"** (The Zen Way).
    - If a target file exists and is NOT a symlink:
        1. Move it to `TargetFile.pre-zen.bak` (Safety).
        2. Let Stow create the link.
    - If it IS a symlink but pointing elsewhere:
        1. Overwrite it.
- **Implementation**:
    - Add a pre-flight check in `zen-load` before running `stow`.
    - Iterate through package manifests or known targets (`.zshrc`, `.config/wezterm`, etc.).
    - If conflict found -> Backup -> Stow.
- **dfsync**: Already handles conflicts interactively or via `-y`. We will default to `-y` (overwrite local with cloud) if `--all` is passed, effectively making the repo/gist the source of truth.

### 7. Refactor Quarantine Logic
- **Problem**: `fix_quarantine` function blindly runs `xattr` on `/Applications`, which is slow and aggressive ("code smell").
- **Solution**: Prevent quarantine at install time.
- **Implementation**:
    - Remove `fix_quarantine` function and calls.
    - Set `export HOMEBREW_CASK_OPTS="--no-quarantine"` before running `brew bundle`.
    - This ensures new apps are usable immediately without scanning the whole disk.

### 8. Zshrc Deep Clean (Requested)
- **Performance Fix**: `chpwd` runs `du -sh` on every directory change. This is catastrophically slow on large repos.
    - **Fix**: Remove disk usage calculation from the hook. Keep file count only.
- **Refinement (User Feedback)**:
    - **Keep**: `alias grep="rg"` and `alias cat="bat"`. (User prefers muscle memory. Note: Scripts should use `command grep` to be safe).
- **Simplification**:
    - Remove `tre` (Redundant. Use `lt` for "List Tree", matches `ll`/`ls` pattern).
    - Remove `~` (Redundant with `AUTO_CD`).
    - Add `alias l="ll"` (Shortest valid form).
    - Remove `mkcd` (Keep `take`, it's the standard Zsh name).
- **Modernization**: Update `myip` to use HTTPS (`ifconfig.me`).

### 9. WezTerm & Zsh Editing Experience (Requested)
- **Problem**: Terminal doesn't feel like an editor (no Shift+Select, no Cmd+Z).
- **Solution (WezTerm Side)**:
    - Map `CMD+Z` -> Send `\x1f` (Ctrl+_, standard TTY Undo).
    - Map `CMD+SHIFT+Z` -> Send `\x19` (Ctrl+Y, often Redo/Yank in Emacs mode).
    - Map `SHIFT+Left/Right` -> Send specific escape codes if standard ones fail, but standard xterm codes usually suffice if Zsh handles them.
    - Map `CMD+SHIFT+Left/Right` -> Send hex codes for "Select to Line Start/End".
- **Solution (Zsh Side)**:
    - Enable `zle` visual selection.
    - Bind `Shift-Left` (`^[[1;2D`) -> `visual-mode` + `backward-char`.
    - Bind `Shift-Right` (`^[[1;2C`) -> `visual-mode` + `forward-char`.
    - Bind `Shift-Right` (`^[[1;2C`) -> `visual-mode` + `forward-char`.
    - Bind `Cmd+Shift+Left` (Mapped code) -> `visual-line-mode` + `beginning-of-line`.

### 10. Clipboard Integration (Cmd+C/X/V)
- **Problem**: `Cmd+C` in WezTerm copies *WezTerm's* selection (mouse), not *Zsh's* visual selection (Shift+Arrows).
- **Solution (WezTerm)**:
    - Remap `Cmd+C` to send `\x1b c` (Esc+c).
    - Remap `Cmd+X` to send `\x1b x` (Esc+x).
    - Preserve `Cmd+V` as `PasteFrom Clipboard` (Standard behavior).
    - Add `Cmd+Shift+C` for "Native WezTerm Copy" (Fallback).
- **Solution (Zsh)**:
    - Bind `Esc+c` (`^[c`) -> Widget that pipes selection to `pbcopy`.
    - Bind `Esc+c` (`^[c`) -> Widget that pipes selection to `pbcopy`.
    - Bind `Esc+x` (`^[x`) -> Widget that cuts selection and pipes to `pbcopy`.

### 11. Level 2 Editor Experience (Requested)
- **Problem**: Missing vertical selection, multi-line entry, and replace-on-paste.
- **Solution (WezTerm)**:
    - `Shift+Enter` -> Send `\x1b\r` (Esc+Enter).
    - `Shift+Up` -> Send `\x1b[1;2A`.
    - `Shift+Down` -> Send `\x1b[1;2B`.
    - `Cmd+V` -> Remap to Send `\x1b v` (Esc+v) instead of native paste.
- **Solution (Zsh)**:
    - Bind `Esc+Enter` -> Widget `z-smart-newline` (Inserts `\n` without executing).
    - Bind `Shift-Up/Down` -> `visual-line-mode` + `up-line`/`down-line`.
    - Bind `Shift-Up/Down` -> `visual-line-mode` + `up-line`/`down-line`.
    - Bind `Esc+v` -> Widget `z-smart-paste`:
        - If text selected: `zle kill-region`.
        - Insert key `pbpaste`.

### 12. Final Polish: Word Navigation & Selection
- **Status**: `Option+Left/Right` (Jump Word) is already configured (`Alt-b`/`Alt-f`).
- **Missing**: `Shift+Option+Left/Right` (Select Word).
- **Solution**:
    - **WezTerm**: Map `Shift+Option+Left/Right` -> Send `\x1b[1;10D` / `\x1b[1;10C`.
    - **Zsh**: Bind codes to `z-visual-word-backward` / `z-visual-word-forward`.

### 13. True Editor Feel: Type-to-Replace & Debugging
- **Problem**: Typing over selection appends instead of overwriting. Cmd+C/V functionality reported broken.
- **Solution (Type-to-Replace)**:
    - Override Zsh `self-insert` widget.
    - Logic: `if ((REGION_ACTIVE)) zle kill-region; zle .self-insert`.
- **Solution (Word Selection)**:
    - Implement the `Shift+Option+Arrow` plan defined above.
- **Solution (Clipboard Debug)**:
    - Verify WezTerm is sending `Esc+c` / `Esc+v`.
    - Verify Zsh bindings. (Likely WezTerm config didn't reload or keycodes differ on Mac).

### 14. Fix Zoxide (cd replacement)
- **Problem**: `cd` is still the shell built-in.
- **Solution**: Update zoxide init command to `eval "$(zoxide init zsh --cmd cd)"`.

### 15. Refine macOS Defaults
- **Goal**: Add missing critical defaults found in gap analysis.
- **Additions**:
    - **Menu Bar**: Date format, Flash separators off.
    - **Dock**: Process indicators (dots).
    - **Zen**: TextEdit (Plain Text), iCloud (Save Local), Updates (Auto-Check).
    - **Zen**: TextEdit (Plain Text), iCloud (Save Local), Updates (Auto-Check).
    - **Scrollbars**: Always show (WhenScrolling).

### 16. Optimize Zsh History (Requested)
- **Goal**: "Best of Both Worlds" history settings (Reliable + Clean).
- **Settings**:
    - `HISTSIZE`/`SAVEHIST`: Increase to 10k/10k (or higher).
    - `HIST_IGNORE_ALL_DUPS`: Don't save duplicates (cleaner).
    - `HIST_FIND_NO_DUPS`: Don't show duplicates in search (FZF).
    - `HIST_REDUCE_BLANKS`: Tidy up commands.
    - `SHARE_HISTORY` vs `APPEND_HISTORY`: Ensure sessions share history but don't overwrite.
    - `HIST_IGNORE_SPACE`: Prefix space to ignore (standard).

### 17. Autocompletion & WezTerm Visuals ("Best of Both Worlds")
- **Autocompletion**:
    - **Add `Aloxaf/fzf-tab`**: Replaces standard tab grid with interactive FZF menu.
    - **Config**: Preview file contents when tabbing!
- **WezTerm Visuals (Zen Glass)**:
    - **Title Bar**: Keep standard macOS title bar (`window_decorations = "TITLE | RESIZE"`).
    - **Glass**: `window_background_opacity = 0.90` + `macos_window_background_blur = 20`.
    - **Focus**: Dim inactive panes (`inactive_pane_hsb`).
    - **Tabs**: Move to bottom (cleaner look).
