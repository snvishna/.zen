# ==============================================================================
#   Zsh Main Config (Zen Infrastructure v3.1)
#
#  DEPENDENCIES (Install via Homebrew):
#  > brew install starship zoxide eza bat fzf fd ripgrep git-delta tldr ncdu jq trash sevenzip
# ==============================================================================

# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# 1. INITIALIZATION & PATHS
# ------------------------------------------------------------------------------
# Export Paths
export PATH="$HOME/.local/bin:$PATH"

# Zsh Options (The Foundation)
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000              # Memory capacity
SAVEHIST=10000              # Disk capacity
setopt SHARE_HISTORY        # Share history between sessions
setopt APPEND_HISTORY       # Append to history, don't overwrite
setopt HIST_IGNORE_ALL_DUPS # Don't save duplicates
setopt HIST_FIND_NO_DUPS    # Don't show duplicates in search
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks
setopt HIST_IGNORE_SPACE    # Ignore commands starting with space
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # Auto-correct typos
setopt EXTENDED_GLOB        # Enable advanced globbing (needed for zmv)
setopt NO_BEEP              # Silence error beeps

# Completion Settings
# We let Zim handle compinit, but redirect dump file to keep ~ clean
export ZSH_COMPDUMP="$HOME/.cache/.zcompdump"

# Zoxide Initialization (Smart Jump)
if command -v zoxide > /dev/null; then
  eval "$(zoxide init zsh --cmd cd)" 
fi

# 2. ZIMFW BOOTSTRAP (Plugin Manager)
# ------------------------------------------------------------------------------
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

# 3. LOOK & FEEL
# ------------------------------------------------------------------------------
# Starship Prompt
eval "$(starship init zsh)"

# 4. POWER FUNCTIONS
# ------------------------------------------------------------------------------

# --- HELP ALIAS (ha) ---
# Fuzzy search aliases with inline/preceding comments + Syntax Highlighting
ha() {
    local alias_files=(~/.zshrc)
    local parsed_aliases=$(awk '
        /^[ \t]*#/ { sub(/^[ \t]*#[ \t]*/, ""); doc = $0; next }
        /^[ \t]*alias/ {
            if ($0 ~ /#/) { print $0 } 
            else if (doc != "") { print $0 "   ## " doc } 
            else { print $0 }
            doc = ""; next
        }
        { doc = "" }
    ' "${alias_files[@]}")

    local selected=$(echo "$parsed_aliases" | \
        fzf --height 40% --layout=reverse --border --prompt="🔍 Search Aliases > " \
            --query="$1" \
            --with-nth=1.. \
            --preview "echo {} | bat --color=always --language=zsh --style=plain" \
            --preview-window=down:3:wrap)

    if [[ -n "$selected" ]]; then
        local alias_name=$(echo "$selected" | cut -d'=' -f1 | sed 's/^[ \t]*alias //')
        print -z "$alias_name "
    fi
}

# --- HEALTH CHECK (zdoctor) ---
# Verifies all "Power User" dependencies are installed
zdoctor() {
    local deps=("starship:Prompt" "zoxide:Smart Jump" "eza:Modern LS" "bat:Modern Cat" "fzf:Fuzzy Finder" "fd:Fast Find" "rg:Fast Grep" "delta:Git Diff" "tldr:Modern Help" "ncdu:Disk Usage" "jq:JSON Processor" "trash:Safe Delete" "7z:Archiver")
    local missing=()
    echo "\n🩺 Zen Infrastructure Diagnostic"
    echo "=============================="
    for entry in "${deps[@]}"; do
        local tool="${entry%%:*}"
        local desc="${entry##*:}"
        if command -v "$tool" &> /dev/null; then printf "  ✅ %-10s %s\n" "$tool" "($desc)"; else printf "  ❌ %-10s %s\n" "$tool" "($desc)"; missing+=("$tool"); fi
    done
    echo "=============================="
    if [ ${#missing[@]} -eq 0 ]; then echo "🚀 All systems operational."; else echo "⚠️  Missing packages. Run:"; echo "   brew install ${missing[*]}"; fi
    echo ""
}

# --- DIRECTORY UTILS ---
take() { mkdir -p "$1" && cd "$1"; } # Dir: Make and enter directory

# --- MACOS FINDER INTEGRATION ---
cdf() { # Mac: cd to the current Finder window
    target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
    if [ -n "$target" ]; then cd "$target"; else echo "❌ No Finder window open"; fi
}

pfd() { # Mac: Print path of current Finder window
    osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'
}

quicklook() { # Mac: Preview file (Spacebar) from terminal
    (( $# > 0 )) && qlmanage -p "$@" &>/dev/null &
}

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
      *.tar.xz)    tar xJf $1      ;;
      *.zip)       unzip $1        ;;
      *.rar)       unrar e $1      ;;
      *.7z)        7z x $1         ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# --- SYSTEM DASHBOARD (Renamed to zinfo) ---
function zinfo() {
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

# 5. FZF PRO CONFIGURATION
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

# FZF-TAB (Interactive Completion)
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' popup-pad 1 3
# Previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
if command -v bat > /dev/null; then
  zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'
fi

# 6. EDITOR KEYBINDINGS (WezTerm/Emacs Style)
# ------------------------------------------------------------------------------
bindkey -e # Emacs mode

# --- FZF & KEYBOARD FIXES ---
bindkey -r '\ec'
bindkey -r '^[c'
bindkey '^[t' fzf-file-widget

# --- SMART NAVIGATION (Multi-line Support) ---
# Function: Up Arrow
# Logic: If multi-line text, move cursor up. If at top (or single line), search history.
function smart-up-arrow() {
    if [[ $BUFFER == *$'\n'* ]]; then
        local original_cursor=$CURSOR
        zle up-line
        [[ $CURSOR -eq $original_cursor ]] && zle fzf-history-widget
    else
        zle fzf-history-widget
    fi
}
zle -N smart-up-arrow

# Function: Down Arrow
# Logic: If multi-line text, move cursor down. If at bottom, go to next history item.
function smart-down-arrow() {
    if [[ $BUFFER == *$'\n'* ]]; then
        local original_cursor=$CURSOR
        zle down-line
        [[ $CURSOR -eq $original_cursor ]] && zle down-line-or-history
    else
        zle down-line-or-history
    fi
}
zle -N smart-down-arrow

# Bind the Smart Widgets
bindkey '^[[A' smart-up-arrow
bindkey '^[[B' smart-down-arrow

# Helpers
function r-delregion() {
  if ((REGION_ACTIVE)) then zle kill-region; else local w=$1; shift; zle $w -- $@; fi
}
function z-smart-insert() { ((REGION_ACTIVE)) && zle kill-region; zle .self-insert; }

# Selection Widgets
function z-visual-mode-backward-char() { ((REGION_ACTIVE)) || zle set-mark-command; zle backward-char; }
function z-visual-mode-forward-char() { ((REGION_ACTIVE)) || zle set-mark-command; zle forward-char; }
function z-visual-line-beginning() { ((REGION_ACTIVE)) || zle set-mark-command; zle beginning-of-line; }
function z-visual-line-end() { ((REGION_ACTIVE)) || zle set-mark-command; zle end-of-line; }
function z-visual-line-up() { ((REGION_ACTIVE)) || zle set-mark-command; zle up-line; }
function z-visual-line-down() { ((REGION_ACTIVE)) || zle set-mark-command; zle down-line; }
function z-visual-word-backward() { ((REGION_ACTIVE)) || zle set-mark-command; zle backward-word; }
function z-visual-word-forward() { ((REGION_ACTIVE)) || zle set-mark-command; zle forward-word; }

# Copy/Cut/Paste/Delete
function z-delete-selection() { if ((REGION_ACTIVE)); then zle kill-region; else zle backward-delete-char; fi }
function z-copy-region() { if ((REGION_ACTIVE)); then zle copy-region-as-kill; print -rn -- $CUTBUFFER | pbcopy; zle deactivate-region; fi }
function z-cut-region() { if ((REGION_ACTIVE)); then zle kill-region; print -rn -- $CUTBUFFER | pbcopy; fi }
function z-smart-paste() { if ((REGION_ACTIVE)); then zle kill-region; fi; LBUFFER+="$(pbpaste)"; }
function z-smart-newline() { LBUFFER+=$'\n'; }

# Register Widgets
zle -N z-visual-mode-backward-char; zle -N z-visual-mode-forward-char
zle -N z-visual-line-beginning; zle -N z-visual-line-end
zle -N z-visual-line-up; zle -N z-visual-line-down
zle -N z-visual-word-backward; zle -N z-visual-word-forward
zle -N z-delete-selection; zle -N self-insert z-smart-insert
zle -N z-copy-region; zle -N z-cut-region
zle -N z-smart-paste; zle -N z-smart-newline

# Bindings
bindkey '^_' undo                           # Ctrl+_
bindkey '^y' redo                           # Ctrl+y
bindkey '^[[1;2D' z-visual-mode-backward-char   # Shift+Left
bindkey '^[[1;2C' z-visual-mode-forward-char    # Shift+Right
bindkey '^[[1;9D' z-visual-line-beginning       # Cmd+Shift+Left
bindkey '^[[1;9C' z-visual-line-end             # Cmd+Shift+Right
bindkey '^[[1;2A' z-visual-line-up              # Shift+Up
bindkey '^[[1;2B' z-visual-line-down            # Shift+Down
bindkey '^[[1;10D' z-visual-word-backward       # Shift+Opt+Left
bindkey '^[[1;10C' z-visual-word-forward        # Shift+Opt+Right
bindkey '^?' z-delete-selection                 # Backspace
bindkey '^[c' z-copy-region                     # Cmd+C
bindkey '^[x' z-cut-region                      # Cmd+X
bindkey '^[v' z-smart-paste                     # Cmd+V
bindkey '^[\r' z-smart-newline                  # Shift+Enter

# 7. ALIASES (The Power Blocks)
# ------------------------------------------------------------------------------

# --- Global Aliases (The Pipes) ---
# Usage: "cat file G pattern" or "pwd C"
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g C='| pbcopy'
alias -g N='> /dev/null'

# --- Suffix Aliases (Open by Typing) ---
alias -s {txt,md,json,yml,yaml}=code  # Text: Open in VS Code
alias -s {png,jpg,jpeg,gif,svg}=open   # Image: Open in default viewer
alias -s {py}=python3                  # Py: Run script

# --- Modern Replacements (New Power Utils) ---
alias help="tldr"         # Doc: Simplified man pages
alias usage="ncdu"        # Disk: Interactive usage analyzer
alias json="jq"           # Data: Pretty print/query JSON

# --- Meta/Config ---
alias dot="code ~/.zshrc"       # Zen: Edit config
alias src="source ~/.zshrc"     # Zen: Reload config
alias zbackup="zen-save"        # Zen: Run backup script
alias install-stack="zen-load"  # Zen: Run loader

# --- Navigation & Listing ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .config="cd ~/.config"
alias .zen="cd ~/.zen"
alias .bin="cd ~/.local/bin"
alias ls="eza --icons --group-directories-first"
alias ll="eza -lah --icons --group-directories-first --git"
alias la="ll"
alias lt="eza --tree --level=2 --icons -a"

# --- Search & Preview ---
alias grep="rg"
alias ft="rg"                # Search: Find Text
alias ff="fd"                # Search: Find File
alias cat="bat"              # Read: Syntax highlighted
alias p="bat --style=plain"  # Read: Plain text

# --- Clipboard (MacOS) ---
alias cpd="pwd | pbcopy && echo '✅ Path copied'"
alias cpf="pbcopy <"
alias cpl="fc -ln -1 | pbcopy && echo '✅ Last command copied'"

# --- Git Workflows ---
alias g="git"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"
alias gd="git diff"
alias gundo="git reset --soft HEAD~1"
alias gwip="git add -A; git rm \$(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m '--wip--'"
alias gnah="git reset --hard && git clean -df"

# --- System & Maintenance ---
alias reload="exec zsh"
alias diff="delta --side-by-side --light"
alias t="trash"  # Safe delete
alias brewup="brew update && brew upgrade && brew cleanup"
alias myip="curl https://ifconfig.me; echo"
alias ports="lsof -i -P -n | grep LISTEN"
alias h="history 0 | fzf"

# --- Safety Nets ---
alias cp='cp -i'
alias mv='mv -i'
alias rm="echo '⛔ Use t (trash) or /bin/rm'; false"

# 8. POST-LOAD (Scripts & Local)
# ------------------------------------------------------------------------------

# zstats Lite (Fast & Recursive for chpwd)
function zstats() {
    # 1. Instant: Root item count
    local root_count=$(ls -1 | wc -l | tr -d ' ')
    echo -n "  📂 $root_count items"

    # 2. Async-ish: Recursive count (Timeout 0.5s)
    if command -v fd > /dev/null; then
        local deep_count=$(timeout 0.5s fd --type f --hidden --no-ignore \
            --exclude .git --exclude node_modules --exclude .venv --exclude target \
            --exclude dist --exclude build --exclude .cache --exclude .next \
            | wc -l | tr -d ' ')
        echo " | 🚀 $deep_count deep"
    else
        echo "" 
    fi
}
chpwd_functions+=(zstats)

# Kiro CLI post block
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

# Private Overrides (API keys, etc.)
[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"

# 9. STARTUP
# ------------------------------------------------------------------------------
# Auto-run zinfo only if we are in WezTerm (prevents clutter in VS Code)
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    zinfo
fi
