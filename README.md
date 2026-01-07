#  .zen
> *The Art of Maintenance-Free macOS Automation.*

### Workflow
```mermaid
flowchart TD
    Start([Start zen-load]) --> Sudo{Sudo Auth}
    Sudo -->|Success| Init[Init Dependencies]
    Init --> CheckBrew{Brew Installed?}
    CheckBrew -->|No| InstallBrew[Install Homebrew Core]
    CheckBrew -->|Yes| CheckStow{Stow Installed?}
    CheckStow -->|No| InstallStow[Brew Install Stow]
    CheckStow -->|Yes| InstallDF[Install/Link dfsync]
    InstallDF --> Resolve[Resolve Conflicts<br/>Backup ~/.zshrc...]
    
    Resolve --> PromptShell{ Prompt: <br/>Stow Shell Env? }
    PromptShell -->|Yes| ActivateShell[dfsync_activate<br/>zshrc, starship...]
    ActivateShell --> PullShell{Confirm Pull?<br/>Overwrite Repo?}
    PullShell -->|Yes| RestoreShell[Update .zen/stow/...]
    PullShell -->|No| SkipShellRest[Keep Git Version]
    RestoreShell --> StowShell[Stow: zsh, starship]
    SkipShellRest --> StowShell
    PromptShell -->|No| Next1
    StowShell --> Next1[Next Module]

    Next1 --> PromptApp{ Prompt: <br/>Other Apps? }
    PromptApp -->|Yes| ActivateApp[dfsync_activate<br/>vscode, wezterm...]
    ActivateApp --> PullApp{Confirm Pull?}
    PullApp -->|Yes| RestoreApp[Update .zen/stow/...]
    PullApp -->|No| SkipAppRest
    RestoreApp --> StowApp[Stow: vscode, wezterm]
    PromptApp -->|No| Next2

    Next2 --> PromptSys{ Prompt: <br/>Apply Defaults? }
    PromptSys -->|Yes| ActivateSys[dfsync_activate<br/>System Configs...]
    ActivateSys --> PullSys{Confirm Pull?}
    PullSys -->|Yes| RestoreSys[Update manifests/private/...]
    RestoreSys --> ApplyDef[defaults.sh<br/>LaunchAgents]
    PromptSys -->|No| Done

    Done([Zen Load Complete])

    classDef prompt fill:#f9f,stroke:#333,stroke-width:2px;
    classDef action fill:#bbf,stroke:#333,stroke-width:1px;
    classDef auto fill:#dfd,stroke:#333,stroke-width:1px;
    
    class Start,Done action
    class PromptShell,PromptApp,PromptSys prompt
    class Init,CheckBrew,InstallBrew,CheckStow,InstallStow,InstallDF,Resolve auto
```

**Current Status:** `v2.1.0` (Stow Edition + Zen Glass)  
**System:** macOS Sequoia+ (Apple Silicon)

`.zen` is a highly opinionated, "zero-friction" dotfiles framework designed to bootstrap a fresh Mac into a powerhouse development machine in minutes.

---

## 📚 Documentation
We treat documentation as code. Comprehensive guides are located in the `docs/` directory:

- **[Setup Guide & Manual](docs/manuals/setup_guide.md)**: Full walkthrough of features, keybindings (WezTerm/Zsh), and installation.
- **[Architecture Spec](docs/specs/v2_architecture.md)**: Deep dive into the Stow structure, `zen-load` logic, and design philosophy.
- **[Project Tracker](docs/project_tracker.md)**: Current roadmap and task history.

---

## 🚀 Quick Start

### Bootstrap a Fresh Mac
```bash
# Clone to ~/.zen
git clone https://github.com/snvishna/.zen.git ~/.zen

# Run the Orchestrator
~/.zen/stow/bin/.local/bin/zen-load
```

### Daily Usage
- **Update/Relink Configs:** `zen-load`
- **Snapshot System:** `zen-save`

---

## 🔥 Key Features (v2.1)
- **Zen Glass Terminal**: WezTerm with 90% opacity, blur, and "Editor-like" keybindings (`Cmd+C/V`, Type-to-Replace).
- **Smart Shell**: Zsh + Starship with autosuggestions, interactive completion (`fzf-tab`), and "Best of Both Worlds" history.
- **Deep Stats**: Instant `cd` with `zstats` lite (shows item count + recursive depth on demand).
- **Automation**: `zen-load` handles everything from Homebrew to Font installation.

---

> Populated by **Antigravity**.
