if [ -f ~/.bash_debug ]; then
  echo "${BASH_SOURCE[0]} Script called from: ${BASH_SOURCE[1]:-unknown} (line ${BASH_LINENO[0]:-unknown}): $-"
  echo "__BASHRC_LOADED=${__BASHRC_LOADED:-}"
  echo "PS1=${PS1:-}"
  echo "PROMPT_COMMAND=${PROMPT_COMMAND:-}"
  echo ""
fi

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return
# Make sure this file is sourced once.
#[[ ${__BASHRC_LOADED:-} ]] && return
#export __BASHRC_LOADED=1

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR='vim'
export CLICOLOR=1

# History
shopt -s histappend
HISTCONTROL=ignoreboth
HISTFILESIZE=10000
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# Bindings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind 'set completion-ignore-case on'
# Allow jumping words.
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  bind '"\e[1;5C": forward-word'
  bind '"\e[1;5D": backward-word'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  bind '"\e[1;3D": backward-word'
  bind '"\e[1;3C": forward-word'
fi

# Aliases:
alias ..='cd ..'
alias du='du -h'
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
alias vi='vim'

# Makes tools available.
source "$HOME/.config/sh/tools.sh"
# Prompt and completion:
source "$HOME/.config/sh/completion.sh"
source "$HOME/.config/sh/prompt.sh"

[[ -r "$HOME/.bashrc_local" ]] && source "$HOME/.bashrc_local"

# Makes sure this init script ends with error code 0.
env true
