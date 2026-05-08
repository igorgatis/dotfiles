#!/bin/sh
# aliases.sh - Shell-agnostic aliases

alias ..='cd ..'
alias cc='claude'
alias du='du -h'
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
alias rg='rg --no-heading -N'
alias vi='vim'

if [ -n "$__ON_TERMUX" ] && command -v proot-distro >/dev/null 2>&1; then
  debian() {
    if [ "$#" -eq 0 ]; then
      proot-distro login debian --user igorgatis
    else
      proot-distro login debian --user igorgatis -- bash -lc "$*"
    fi
  }
fi
