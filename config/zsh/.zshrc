
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# ==============================================================================
#   Zsh Main Config (Zen Infrastructure v2.0 - Deep Stats Restored)
# ==============================================================================

# 0. ATOMIC COMPLETION GUARD
# ------------------------------------------------------------------------------
export ZSH_COMPDUMP="$HOME/.cache/.zcompdump"
if [[ -z "$_COMPINIT_DONE" ]]; then
    autoload -Uz compinit
    if [[ -n ${ZSH_COMPDUMP}(#qN.m-1) ]]; then
        compinit -C -d "$ZSH_COMPDUMP"
    else
        compinit -d "$ZSH_COMPDUMP"
    fi
    export _COMPINIT_DONE=1
fi

# 1. ZIMFW BOOTSTRAP
# ------------------------------------------------------------------------------
# Bridge Pattern: Use ~/.config paths so Zsh is agnostic
export ZIM_HOME=${HOME}/.config/zim
export ZIM_CONFIG_FILE=${HOME}/.config/zim/.zimrc
zstyle ':zim:completion' skip-compinit 'yes'
zstyle ':zim:completion' dumpfile "$ZSH_COMPDUMP"

if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# 2. SETTINGS & HISTORY
# ------------------------------------------------------------------------------
export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTFILE="$HOME/.config/.zsh_history"
setopt EXTENDED_HISTORY SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # Auto-correct commands

# 3. LOOK & FEEL
# ------------------------------------------------------------------------------
eval "$(starship init zsh)"

# 4. POWER UTILITIES
# ------------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

function ff() { find . -type f -iname "*$1*" ; }
function ft() { grep -rnw . -e "$1" --color=auto --exclude-dir={.git,node_modules,dist,build} ; }
function tre() { tree -I 'node_modules|.git|.cache|.DS_Store' --dirsfirst -L "${1:-2}" -C "${2:-.}"; }
function take() { mkdir -p "$1" && cd "$1"; }
function ports() { lsof -iTCP -sTCP:LISTEN -n -P; }

function extract() {
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

# 5. CORE ALIASES
# ------------------------------------------------------------------------------
alias reload="exec zsh"
alias ..="cd .."
alias ...="cd ../.."
alias .config="cd ~/.config"
alias .zen="cd ~/.zen"
alias .bin="cd ~/.local/bin"
alias ls="ls -G"
alias ll="ls -lGh"
alias la="ls -lGha"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# Zen Tools Mappings
alias backup="zen-save"
alias install-stack="zen-load"

# Delta Side-by-Side (Light Mode)
alias diff="delta --side-by-side --light"

# 6. ZEN DASHBOARD (DEEP STATS EDITION)
# ------------------------------------------------------------------------------
function zstats() {
    local C='\033[1;36m' # Cyan
    local Y='\033[1;33m' # Yellow
    local B='\033[1;34m' # Blue
    local NC='\033[0m'   # No Color

    # --- RAW DATA COLLECTION ---
    local host=$(hostname -s)
    local os=$(sw_vers -productVersion)
    
    # Resources
    local load=$(sysctl -n vm.loadavg | awk '{print $2" "$3" "$4}')
    local mem=$(ps -A -o %mem | awk '{s+=$1} END {print s"%"}')
    local batt=$(pmset -g batt | grep -o '[0-9]*%' | head -1)
    
    # Memory Details (RESTORED)
    local page_size=$(getconf PAGESIZE)
    local cache=$(vm_stat | awk -v ps=$page_size 'BEGIN{sum=0} /Pages (speculative|inactive)/{gsub(/\./, "", $3); sum+=$3} END{printf "%.1fG", sum*ps/1024/1024/1024}')
    local swap=$(sysctl -n vm.swapusage | awk '{print $6}')

    # Disk & Network (RESTORED)
    local ip=$(ipconfig getifaddr en0 2>/dev/null || echo "Offline")
    local disk=$(df -h / | awk 'NR==2 {print $5 " used"}')
    
    # Meta
    local pkgs=$(ls /opt/homebrew/Cellar 2>/dev/null | wc -l | xargs)
    local hist=$(wc -l < "$HISTFILE" 2>/dev/null || echo 0)
    local up=$(uptime | awk -F'(up |,| user)' '{print $2}' | xargs)

    # --- RENDER DASHBOARD ---
    echo -e "\n${C}  System: $host (macOS $os)${NC}"
    echo -e "${B}  --------------------------------------------------${NC}"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "IP:" "$ip" "BATT:" "$batt"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "CPU:" "$load" "MEM:" "$mem"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "SWAP:" "$swap" "CACHE:" "$cache"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "DISK:" "$disk" "PKGS:" "$pkgs"
    printf "  ${Y}%-6s${NC} %-15s ${Y}%-6s${NC} %s\n" "UP:" "$up" "HIST:" "$hist"
    echo -e "${B}  --------------------------------------------------${NC}"
}

function zhelp() {
    local G='\033[1;32m'
    local B='\033[1;34m'
    local Y='\033[1;33m'
    local NC='\033[0m'
    
    echo -e "${G}🚀 ZEN INFRASTRUCTURE v2.0${NC}"
    
    echo -e "\n${Y}[ SEARCH (FZF & UTILS) ]${NC}"
    printf "  ${B}%-15s${NC} %s\n" "Ctrl + R" "Search History (FZF)"
    printf "  ${B}%-15s${NC} %s\n" "Ctrl + T" "Search Files (Preview)"
    printf "  ${B}%-15s${NC} %s\n" "Alt  + C" "Search Folders & cd"
    printf "  ${B}%-15s${NC} %s\n" "ff <name>" "Find file (Simple)"
    printf "  ${B}%-15s${NC} %s\n" "ft <text>" "Find text (Grep)"

    echo -e "\n${Y}[ SYSTEM & INFRA ]${NC}"
    printf "  ${B}%-15s${NC} %s\n" "zen-load" "Hydrate Stack (Apps/Configs)"
    printf "  ${B}%-15s${NC} %s\n" "zen-save" "Snapshot & Sync to Cloud"
    printf "  ${B}%-15s${NC} %s\n" ".zen" "Go to Repo (~/.zen)"
    printf "  ${B}%-15s${NC} %s\n" "zstats" "Show Dashboard"
    echo ""
}

# 7. NAVIGATION HOOK (THE NERDY DIR STATS)
# ------------------------------------------------------------------------------
function chpwd() {
    local size=$(du -sh . 2>/dev/null | cut -f1)
    local count=$(ls -1 | wc -l | xargs)
    echo -e "\033[1;30m   [ 📁 $count items  |  💾 $size ]\033[0m"
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

  export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

  if command -v fd >/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

# 9. LAUNCH
# ------------------------------------------------------------------------------
zstats


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
