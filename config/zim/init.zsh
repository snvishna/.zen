# FILE AUTOMATICALLY GENERATED FROM /Users/shankar/.config/zim/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]] zimfw() { source "${HOME}/.config/zim/zimfw.zsh" "${@}" }
fpath=("${HOME}/.config/zim/modules/utility/functions" "${HOME}/.config/zim/modules/git/functions" ${fpath})
autoload -Uz -- mkcd mkpw git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove
source "${HOME}/.config/zim/modules/environment/init.zsh"
source "${HOME}/.config/zim/modules/input/init.zsh"
source "${HOME}/.config/zim/modules/termtitle/init.zsh"
source "${HOME}/.config/zim/modules/utility/init.zsh"
source "${HOME}/.config/zim/modules/git/init.zsh"
source "${HOME}/.config/zim/modules/prompt/init.zsh"
source "${HOME}/.config/zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${HOME}/.config/zim/modules/zsh-history-substring-search/zsh-history-substring-search.zsh"
