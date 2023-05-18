# ---------------------
# Environment Variables
# ---------------------
export LANG=ja_JP.UTF-8
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export FZF_COMPLETION_TRIGGER='++'
export FZF_COMPLETION_OPTS='--border --info=inline'
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"

# ------------------
# Variables, Options
# ------------------
# 履歴管理
HISTFILE=$XDG_DATA_HOME/zsh/history
HISTSIZE=1000
SAVEHIST=10000
HISTORY_IGNORE="(ls|pwd|cd ..)"

setopt auto_cd		    # easy move directory
setopt no_correctall	# disable correct
setopt print_eight_bit
setopt auto_pushd
setopt share_history

# ---------
# Functions
# ---------
# auto ls
function chpwd() { ls }

# -------
# Aliases
# -------
alias la='ls -la'
alias g='git'
alias t='tmux'

# ------------
# Key Bindings
# ------------
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

[ -f $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh ] && . $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh

if command -v starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

autoload -Uz compinit; compinit
