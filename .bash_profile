# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1
[[ -f ~/.bashrc ]] && source ~/.bashrc
