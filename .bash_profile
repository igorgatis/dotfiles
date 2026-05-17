# ~/.bash_profile - Bash login shell

__TRACE_NAME=.bash_profile; . "$HOME/.config/sh/trace.sh"

[ -f ~/.profile ] && . ~/.profile

if [ -z "$__BASHRC_LOADED" ] && [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
