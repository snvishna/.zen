
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
  eval "$(zoxide init zsh)" 
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

# 3. SETTINGS & HISTORY
# ------------------------------------------------------------------------------
export HISTSIZE=1000000          # History: Keep 1 million lines
export SAVEHIST=1000000          # History: Save 1 million lines
export HISTFILE="$HOME/.config/.zsh_history"
setopt EXTENDED_HISTORY SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
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

# 9. ZEN ALIASES (Refactored for Searchability)
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
alias l="ll" # List: Shortest valid form
alias lt="eza --tree --level=2 --icons" # List: Tree view

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

# --- Zen Tools ---
alias backup="zen-save" # Zen: Run backups
alias install-stack="zen-load" # Zen: Rehydrate system

# 10. LAUNCH
# ------------------------------------------------------------------------------
zstats

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

