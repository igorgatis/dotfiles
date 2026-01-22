#!/bin/bash
# bash/init.sh - Bash-specific interactive settings

# History
shopt -s histappend
HISTCONTROL=ignoreboth
HISTFILE=~/.bash_history
HISTFILESIZE=10000
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# Keybindings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind 'set completion-ignore-case on'

# Word jumping (Ctrl+arrows)
if [[ "$OSTYPE" == linux-gnu* ]] || [[ -n "$TERMUX_VERSION" ]]; then
  bind '"\e[1;5C": forward-word'
  bind '"\e[1;5D": backward-word'
elif [[ "$OSTYPE" == darwin* ]]; then
  bind '"\e[1;3D": backward-word'
  bind '"\e[1;3C": forward-word'
fi
