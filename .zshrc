# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

[[ -n "${ENABLE_ZPROF-}" ]] && zmodload zsh/zprof

try-source() {
  [[ -r "$1" ]] && source "$1"
}

try-source /etc/zshrc

export LC_ALL=C
if locale -a 2>/dev/null | grep -q en_US.UTF-8; then
  export LC_ALL=en_US.UTF-8
fi
export LANG=$LC_ALL
export EDITOR='vim'
export CLICOLOR=1

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
# Allow jumping words.
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word
elif [[ "$OSTYPE" == "darwin"* ]]; then
  bindkey '^[[1;3D' backward-word
  bindkey '^[[1;3C' forward-word
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

try-source "$HOME/.zshrc_local"

# Cleanup.
unset -f try-source

[[ -n "${ENABLE_ZPROF-}" ]] && zprof

# Makes sure this init script ends with error code 0.
env true
