#!/bin/sh
# aliases.sh - Shell-agnostic aliases

alias ..='cd ..'
alias du='du -h'
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
alias vi='vim'

if [ -n "$TERMUX_VERSION" ] && [ -d "$PREFIX/tmp" ]; then
  alias claude='proot -b $PREFIX/tmp:/tmp claude'
  alias gh='proot -b $PREFIX/tmp:/tmp gh'
fi
