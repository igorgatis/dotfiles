# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

export MACHINE="${HOSTNAME/\.*/}"

function __git_branch() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  branch=$(echo "$branch" | sed -e 's/^ *//g' -e 's/ *$//g')
  if [ -n "$branch" ]; then
    echo "[$branch]"
  fi
  echo ""
}

case "$TERM" in
  xterm*)
    export PROMPT_COMMAND='echo -ne "\e]0;$(echo $MACHINE):${PWD/$HOME/~}$(__git_branch)\007"'
    ;;
  *)
    export PROMPT_COMMAND=
    ;;
esac

p_root='${debian_chroot:+($debian_chroot)}'
p_time='\t'
p_host='$(echo $MACHINE)'
p_git='$(__git_branch)'
p_path='${PWD/$HOME/~}'
p_end='$ '
if [ "$color_prompt" = yes ]; then
  p_time="\[\e[1;30m\]${p_time}"
  p_host="\[\e[1;32m\]${p_host}"
  p_path="\[\e[1;34m\]${p_path}"
  if [ -n "$p_git" ]; then
    p_git="\[\e[1;33m\]${p_git}"
  fi
  p_end="\[\e[0m\]${p_end}"
fi
PS1="${p_root}${p_time} ${p_host}:${p_path}${p_git}${p_end}"
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias vi='vim -X'
alias vim='vim -X'
alias vimdiff='vimdiff -X'
alias less='less -S'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Make bash autocomplete with up arrow.
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

export EDITOR='vim -X'
[ -d $HOME/bin ] && export PATH="$HOME/bin/:$PATH"
[ -d $HOME/bin_local ] && export PATH="$HOME/bin_local/:$PATH"

# TMUX stuff.
export DEPOT="$HOME/depot"
# It's OK to list sessions while in TMUX session.
function lsc() {
  $HOME/bin/tmux-complete.py
}
if [ -z "$TMUX" ]; then
  # Not in TMUX session, adding TMUX attach commands.
  function rsc() {
    pushd "$DEPOT/$1"
    local clientid="$1.`date +%S`"
    tmux -q new-session -t "$1" -s "$clientid" \;\
        set-option destroy-unattached \;\
        set-option default-path "$DEPOT/$1" \;\
        attach-session -t "$clientid"
    popd
  }
  complete -o nospace -C "$HOME/bin/tmux-complete.py" rsc
  function mksc() {
    pushd "$DEPOT/$1"
    tmux -q new-session -d -s "$1"
    popd
    rsc "$1"
  }
  complete -o nospace -C "$HOME/bin/tmux-complete.py" mksc
fi

# Local stuff.
[ -f $HOME/.bashrc_local ] && source $HOME/.bashrc_local

