#!/bin/sh
# interactive.sh - Entry point for interactive shells
# Sourced by: .bashrc, .zshrc

if [ -n "${BASH_VERSION-}" ]; then
  __shell="bash"
elif [ -n "${ZSH_VERSION-}" ]; then
  __shell="zsh"
fi

# Full mise activation (hooks, auto-switching) for interactive use
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate "$__shell")"
fi

# Shell-specific settings
. "$HOME/.config/sh/$__shell/init.sh"

# Common settings
. "$HOME/.config/sh/aliases.sh"
. "$HOME/.config/sh/completion.sh"
. "$HOME/.config/sh/prompt.sh"
. "$HOME/.config/sh/tools.sh"

export CLICOLOR=1

unset __shell
