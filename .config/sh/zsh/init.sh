#!/bin/zsh
# zsh/init.sh - Zsh-specific interactive settings

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups

# Completion
setopt no_case_glob
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Keybindings
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey '^[w' kill-region

# Word jumping (Ctrl+arrows)
if [[ "$OSTYPE" == linux-gnu* ]] || [[ -n "$TERMUX_VERSION" ]]; then
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word
elif [[ "$OSTYPE" == darwin* ]]; then
  bindkey '^[[1;3D' backward-word
  bindkey '^[[1;3C' forward-word
fi
