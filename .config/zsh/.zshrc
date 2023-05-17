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

autoload -Uz compinit; compinit
