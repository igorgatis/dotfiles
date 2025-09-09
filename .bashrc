# If not running interactively, don't do anything.
[[ -z "$PS1" ]] && return

try-source() {
  [[ -r "$1" ]] && source "$1"
}
add-path() {
  export PATH="$1:$PATH"
}

try-source /etc/bashrc

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

# Tools path (in reverse order of preference):
source "$HOME/.config/sh/brew.sh" # Makes tools available.
add-path "$HOME/bin"
add-path "$HOME/go/bin"
try-source "$HOME/.bashrc_local"
source "$HOME/.config/sh/claude.sh"
source "$HOME/.config/sh/yadm.sh"
# Now, install asdf shims, notice it must come last.
source "$HOME/.config/sh/asdf.sh"

# Prompt and completion:
source "$HOME/.config/sh/completion.sh"
source "$HOME/.config/sh/prompt.sh"

# Cleanup.
unset -f add-path
unset -f try-source

# Makes sure this init script ends with error code 0.
env true
