# ~/.bashrc - Bash interactive shell

__TRACE_NAME=.bashrc; . "$HOME/.config/sh/trace.sh"

[[ $- != *i* ]] && return

__BASHRC_LOADED=1

. "$HOME/.config/sh/interactive.sh"

[[ ! -f ~/.bashrc_local ]] || . ~/.bashrc_local
