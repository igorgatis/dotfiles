# ~/.bashrc - Bash interactive shell

[[ $- != *i* ]] && return

. "$HOME/.config/sh/interactive.sh"

[[ -f ~/.bashrc_local ]] && . ~/.bashrc_local
