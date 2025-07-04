# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR='vim'
export CLICOLOR=1

try-source() {
  [ -r "$1" ] && source "$1"
}
try-source /etc/bashrc

# Bash unified history control (ref: )
shopt -s histappend
HISTCONTROL=ignoreboth
HISTFILESIZE=10000
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

# Make bash autocomplete with up arrow.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
# Allow jumping words.
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  bind '"\e[1;5C": forward-word'
  bind '"\e[1;5D": backward-word'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  bind '"\e[1;3D": backward-word'
  bind '"\e[1;3C": forward-word'
fi
# Case insensitve:
bind 'set completion-ignore-case on'

# Core aliases:
alias ..='cd ..'
alias du='du -h'
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
# Other:
alias venv='source .venv/bin/activate'

try-path() {
  [ -d "$1" ] && export PATH="$1:$PATH"
}
try-path "/opt/homebrew/bin"
try-path "$HOME/bin"
try-path "$HOME/bin_local"
try-path "$HOME/go/bin"

# Now that PATH is set, we can source completion and ps1.
try-source "$HOME/.config/bash/completion.sh"
try-source "$HOME/.config/bash/ps1.sh"

# Third party:
try-source "$HOME/.config/bash/brew.sh"
try-source "$HOME/.config/bash/llm.sh"
try-source "$HOME/.config/bash/pyenv.sh"

# Last thing to allow local overrides.
try-source "$HOME/.bashrc_local"

# Cleanup.
unset -f try-path
unset -f try-source

# Makes sure this init script ends with error code 0.
env true

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
