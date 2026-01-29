#!/bin/sh
# env.sh - Environment setup for all shells (interactive and non-interactive)
# Sourced by: .profile, .zshenv, BASH_ENV
# Keep minimal and fast.

[ -n "$__ENV_SOURCED" ] && return
export __ENV_SOURCED=1

# Locale (UTF-8 needed for proper terminal rendering)
for __locale in en_US.UTF-8 en_US.utf8 C.UTF-8 C.utf8; do
  if locale -a 2>/dev/null | grep -qx "$__locale"; then
    export LANG="$__locale"
    export LC_ALL="$__locale"
    break
  fi
done
unset __locale

export EDITOR='vim'

# --- PATH setup ---

__prepend_path() {
  [ -d "$1" ] && case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# Homebrew
if [ -d "/opt/homebrew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "$HOME/.linuxbrew" ]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

__prepend_path "$HOME/.local/bin"
__prepend_path "$HOME/go/bin"

# mise shims for non-interactive shells
__prepend_path "$HOME/.local/share/mise/shims"

unset -f __prepend_path
