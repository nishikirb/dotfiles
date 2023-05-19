#!/bin/bash

# tmux additional setup
if [[ ! -f "$XDG_CONFIG_HOME/tmux/plugins/tpm/tpm" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/tmux/plugins" && git clone https://github.com/tmux-plugins/tpm "$XDG_CONFIG_HOME/tmux/plugins/tpm"
else 
    echo "tpm already installed"
fi

# create $XDG_DATA_HOME
if [[ ! -d "$XDG_DATA_HOME/zsh" ]]; then
    mkdir -p "$XDG_DATA_HOME/zsh"
else
    echo "\$XDG_DATA_HOME already exists"
fi

# remove unused zsh files
# zfiles=(".zprofile" ".zsh_history" ".zsh_sessions")
# for file in "${zfiles[@]}"
# do
#     rm -i "${HOME}/${file:?}"
# done
