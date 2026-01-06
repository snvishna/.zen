
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# ==============================================================================
#   Zsh Main Config (Zen Infrastructure v2.1 - Refactored for Help)
# ==============================================================================

# 0. COMPLETION SETTINGS
# ------------------------------------------------------------------------------
# We let Zim handle compinit for speed, but we redirect the dump file to keep ~ clean.
export ZSH_COMPDUMP="$HOME/.cache/.zcompdump"

# 1. ZXOIDE INITIALIZATION (Must be early)
# ------------------------------------------------------------------------------
if command -v zoxide > /dev/null; then
  eval "$(zoxide init zsh --cmd cd)" 
fi

# 2. ZIMFW BOOTSTRAP
# ------------------------------------------------------------------------------
# Bridge Pattern: Use ~/.config paths so Zsh is agnostic
export ZIM_HOME=${HOME}/.zim
export ZIM_CONFIG_FILE=${HOME}/.zimrc
zstyle ':zim:completion' dumpfile "$ZSH_COMPDUMP"

if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# 3. SETTINGS & HISTORY (Optimized "Best of Both Worlds")
# ------------------------------------------------------------------------------
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000              # Memory capacity
SAVEHIST=10000              # Disk capacity
setopt SHARE_HISTORY        # Share history between sessions
setopt APPEND_HISTORY       # Append to history file, don't overwrite
setopt HIST_IGNORE_ALL_DUPS # Don't save duplicates
setopt HIST_FIND_NO_DUPS    # Don't show duplicates in search
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks
setopt HIST_IGNORE_SPACE    # Ignore commands starting with space
setopt AUTO_CD                   # Navigation: cd by typing directory name
setopt CORRECT                   # Correction: Auto-correct commands

# 4. LOOK & FEEL
# ------------------------------------------------------------------------------
eval "$(starship init zsh)"

# 5. POWER UTILITIES & FUNCTIONS
# ------------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH" # Path: Add local bin

# --- HELP ALIAS (ha) ---
# Fuzzy search your aliases and functions by comment description
ha() {
    # 1. SEARCH LOCATIONS
    local alias_files=(~/.zshrc)

    # 2. THE PIPELINE
    # 'command grep' : Force system grep (ignore aliases like grep=rg)
    # '-h' : Suppress filenames
    local selected=$(command grep -h "^alias" "${alias_files[@]}" 2>/dev/null | \
        fzf --height 40% --layout=reverse --border --prompt="🔍 Search Aliases > " \
            --query="$1" \
            --preview "echo {} | cut -d'=' -f2- | sed 's/#/\n#/'" \
            --preview-window=down:3:wrap)

    # 3. EXECUTION
    if [[ -n "$selected" ]]; then
        local alias_name=$(echo "$selected" | sed 's/^alias //' | cut -d'=' -f1)
        print -z "$alias_name "
    fi
}

# --- DIRECTORY UTILS ---
take() { mkdir -p "$1" && cd "$1"; } # Dir: Make and enter directory

# --- NETWORK UTILS ---
kp() { # Net: Kill process on specific port
    lsof -i tcp:${1} | awk 'NR!=1 {print $2}' | xargs kill
    echo "💀 Killed process on port $1"
}
flushdns() { # Net: Flush DNS cache
    sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
}

# --- ARCHIVE UTILS ---
extract() { # File: Universal extractor
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1      ;;
      *.tar.gz)    tar xzf $1      ;;
      *.zip)       unzip $1        ;;
      *.rar)       unrar e $1      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# 6. ZEN DASHBOARD (DEEP STATS EDITION)
# ------------------------------------------------------------------------------
function zstats() {
    local C='\033[1;36m'; local Y='\033[1;33m'; local B='\033[1;34m'; local NC='\033[0m'
    local host=$(hostname -s)
    local os=$(sw_vers -productVersion)
    local load=$(sysctl -n vm.loadavg | awk '{print $2" "$3" "$4}')
    local mem=$(ps -A -o %mem | awk '{s+=$1} END {print s"%"}')
    local batt=$(pmset -g batt | grep -o '[0-9]*%' | head -1)
    local page_size=$(getconf PAGESIZE)
    local cache=$(vm_stat | awk -v ps=$page_size 'BEGIN{sum=0} /Pages (speculative|inactive)/{gsub(/\./, "", $3); sum+=$3} END{printf "%.1fG", sum*ps/1024/1024/1024}')
    local swap=$(sysctl -n vm.swapusage | awk '{print $6}')
    local ip=$(ipconfig getifaddr en0 2>/dev/null || echo "Offline")
    local disk=$(df -h / | awk 'NR==2 {print $5 " used"}')
    local pkgs=$(ls /opt/homebrew/Cellar 2>/dev/null | wc -l | xargs)
    local hist=$(wc -l < "$HISTFILE" 2>/dev/null || echo 0)
    local up=$(uptime | awk -F'(up |,| user)' '{print $2}' | xargs)

    echo -e "\n${C}  System: $host (macOS $os)${NC}"
    echo -e "${B}  --------------------------------------------------${NC}"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "IP:" "$ip" "BATT:" "$batt"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "CPU:" "$load" "MEM:" "$mem"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "SWAP:" "$swap" "CACHE:" "$cache"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "DISK:" "$disk" "PKGS:" "$pkgs"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "UP:" "$up" "HIST:" "$hist"
    echo -e "${B}  --------------------------------------------------${NC}"
}

# 7. NAVIGATION HOOK
# ------------------------------------------------------------------------------
function chpwd() {
    local count=$(ls -1 | wc -l | xargs)
    echo -e "\033[1;30m   [ 📁 $count items ]\033[0m"
}

# 8. FZF PRO CONFIGURATION
# ------------------------------------------------------------------------------
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --prompt='🔎 ' --pointer='▶' --marker='✓' \
  --layout=reverse --border --height=40%"

  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
  
  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

# 9. FZF-TAB CONFIGURATION (Interactive Completion)
# ------------------------------------------------------------------------------
# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# Set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# Preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# Switch to flat mode for cd
zstyle ':fzf-tab:complete:cd:*' popup-pad 1 3
# Preview file content with bat (if installed)
if command -v bat > /dev/null; then
  zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
fi


# 10. EDITOR EXPERIENCE (Keybindings)
# ------------------------------------------------------------------------------
# Enable standard Emacs mode (default)
bindkey -e

# --- Undo / Redo ---
bindkey '^_' undo          # Ctrl+_ (Standard Undo)
bindkey '^y' redo          # Ctrl+y (Mapped to Cmd+Shift+Z in WezTerm)

# --- Visual Selection (Shift+Arrows) ---
# WezTerm sends xterm codes for Shift+Arrow. We bind them to selection widgets.
# 1. Define custom widgets for selection
function r-delregion() {
  if ((REGION_ACTIVE)) then
     zle kill-region
  else 
     local widget_name=$1
     shift
     zle $widget_name -- $@
  fi
}

function z-visual-mode-backward-char() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle backward-char
}
function z-visual-mode-forward-char() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle forward-char
}
function z-visual-line-beginning() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle beginning-of-line
}
function z-visual-line-end() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle end-of-line
}

# 2. Register widgets
zle -N z-visual-mode-backward-char
zle -N z-visual-mode-forward-char
zle -N z-visual-line-beginning
zle -N z-visual-line-end

# 3. Bind Keys (Codes match WezTerm config)
bindkey '^[[1;2D' z-visual-mode-backward-char   # Shift+Left
bindkey '^[[1;2C' z-visual-mode-forward-char    # Shift+Right
bindkey '^[[1;9D' z-visual-line-beginning       # Cmd+Shift+Left
bindkey '^[[1;9C' z-visual-line-end             # Cmd+Shift+Right

# 4. Handle Backspace on Selection
# If text is selected, backspace should delete the selection, not just the char
function z-delete-selection() {
  if ((REGION_ACTIVE)); then
      zle kill-region
  else 
      zle backward-delete-char
  fi
}
zle -N z-delete-selection
bindkey '^?' z-delete-selection

# 5. Clipboard Integration (Cmd+C / Cmd+X)
# WezTerm sends Esc-c / Esc-x
function z-copy-region() {
    if ((REGION_ACTIVE)); then
        zle copy-region-as-kill
        print -rn -- $CUTBUFFER | pbcopy
        zle deactivate-region
    fi
}

function z-cut-region() {
    if ((REGION_ACTIVE)); then
        zle kill-region
        print -rn -- $CUTBUFFER | pbcopy
    fi
}

# 6. Type-to-Replace (The "Editor" Feel)
# If text is selected, typing any key should replace it.
function z-smart-insert() {
  if ((REGION_ACTIVE)); then
      zle kill-region
  fi
  zle .self-insert
}
zle -N self-insert z-smart-insert 

zle -N z-copy-region
zle -N z-cut-region

bindkey '^[c' z-copy-region # Esc-c (Cmd+C)
bindkey '^[x' z-cut-region  # Esc-x (Cmd+X)

# 6. Smart Paste (Cmd+V) - Esc+v
function z-smart-paste() {
    if ((REGION_ACTIVE)); then
        zle kill-region
    fi
    # Paste from macOS clipboard
    LBUFFER+="$(pbpaste)"
}
zle -N z-smart-paste
bindkey '^[v' z-smart-paste

# 7. Multi-line Entry (Shift+Enter) - Esc+Enter
function z-smart-newline() {
    LBUFFER+=$'\n'
}
zle -N z-smart-newline
bindkey '^[\r' z-smart-newline

# 8. Vertical Selection (Shift+Up/Down)
function z-visual-line-up() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle up-line
}
function z-visual-line-down() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle down-line
}
zle -N z-visual-line-up
zle -N z-visual-line-down
bindkey '^[[1;2A' z-visual-line-up   # Shift+Up
bindkey '^[[1;2B' z-visual-line-down # Shift+Down

# 9. Word Selection (Shift+Option+Left/Right)
function z-visual-word-backward() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle backward-word
}
function z-visual-word-forward() {
    ((REGION_ACTIVE)) || zle set-mark-command
    zle forward-word
}
zle -N z-visual-word-backward
zle -N z-visual-word-forward
bindkey '^[[1;10D' z-visual-word-backward # Shift+Option+Left
bindkey '^[[1;10C' z-visual-word-forward  # Shift+Option+Right

# 11. LAUNCH & ALIASES (Post-Init)
# ------------------------------------------------------------------------------
# zstats Lite (Fast & Recursive)
function zstats() {
    # 1. Instant: Root item count
    local root_count=$(ls -1 | wc -l | tr -d ' ')
    echo -n "  📂 $root_count items"

    # 2. Async-ish: Recursive count (Timeout 1s, Exclude heavy folders)
    # Using 'fd' because it's insanely fast and respects .gitignore
    if command -v fd > /dev/null; then
        local deep_count=$(timeout 0.5s fd --type f --hidden --no-ignore \
            --exclude .git \
            --exclude node_modules \
            --exclude .venv \
            --exclude target \
            --exclude dist \
            --exclude build \
            --exclude .cache \
            --exclude .next \
            | wc -l | tr -d ' ')
        echo " | 🚀 $deep_count deep"
    else
        echo "" 
    fi
}
chpwd_functions+=(zstats)

# 12. ZEN ALIASES (Moved to Bottom to Override Zim)
# ------------------------------------------------------------------------------
# --- Navigation & Listing ---
alias ..="cd .."         # Nav: Go up one level
alias ...="cd ../.."     # Nav: Go up two levels
alias ....="cd ../../.." # Nav: Go up three levels
alias .config="cd ~/.config" # Nav: Go to config
alias .zen="cd ~/.zen"       # Nav: Go to .zen repo
alias .bin="cd ~/.local/bin" # Nav: Go to local bin

alias ls="eza --icons --group-directories-first" # List: Modern ls (Eza)
alias ll="eza -lah --icons --group-directories-first --git" # List: Details + Git
alias la="eza -lah --icons --group-directories-first --git" # List: All (same as ll)
alias lt="eza --tree --level=2 --icons" # List: Tree view
alias lts="eza --tree --level=2 --icons --long --total-size" # List: Tree with Directory Sizes (Slow)

# --- Search & Preview ---
alias grep="rg"  # Search: Replace grep with Ripgrep
alias ft="rg"    # Search: Find Text (Ripgrep)
alias ff="fd"    # Search: Find File (fd)
alias cat="bat"  # Read: Replace cat with Bat
alias p="bat --style=plain" # Read: Plain text (easy copy)

# --- Clipboard (MacOS) ---
alias cpd="pwd | pbcopy && echo '✅ Path copied'" # Clip: Copy current path
alias cpf="pbcopy <" # Clip: Copy file content
alias cpl="fc -ln -1 | pbcopy && echo '✅ Last command copied'" # Clip: Copy last cmd

# --- Git Workflows ---
alias g="git" # Git: Base command
alias gs="git status"        # Git: Status
alias ga="git add ."         # Git: Add all
alias gc="git commit -m"     # Git: Commit with message
alias gp="git push"          # Git: Push
alias gl="git log --oneline --graph --decorate" # Git: Graph log
alias gd="git diff"          # Git: Diff (uses delta)
alias gundo="git reset --soft HEAD~1" # Git: Undo last commit
alias gwip="git add -A; git rm \$(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m '--wip--'" # Git: Work in progress
alias gnah="git reset --hard && git clean -df" # Git: Reset everything (Dangerous)

# --- System & Maintenance ---
alias reload="exec zsh" # Sys: Reload shell
alias diff="delta --side-by-side --light" # Sys: Better diff
alias rm="echo 'Use trash or /bin/rm'; false" # Sys: Safety catch for rm
alias t="trash" # Sys: Move to Trash
alias brewup="brew update && brew upgrade && brew cleanup" # Sys: Update all
alias myip="curl https://ifconfig.me; echo" # Net: My Public IP (HTTPS)
alias ports="lsof -i -P -n | grep LISTEN" # Net: Open ports
alias h="history 0 | fzf" # Hist: FZF History Search
alias backup="zen-save" # Zen: Run backups
alias install-stack="zen-load" # Zen: Rehydrate system

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

