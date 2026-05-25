#!/bin/sh
# env.sh - Environment setup for all shells (interactive and non-interactive)
# Sourced by: .profile, .zshenv, BASH_ENV
# Keep minimal and fast.

# termux.sh defines the debian() function which doesn't propagate across exec,
# so it must run in every child shell — before the guard. Its TERMUX_VERSION
# gate makes it a fast no-op on other platforms.
[ -f "$HOME/.config/sh/termux.sh" ] && . "$HOME/.config/sh/termux.sh"

# Bridge: PATH + BROWSER + DISPLAY for the xdg-open shim. Runs before the
# guard because non-interactive child shells may have had PATH scrubbed
# (proot --isolated, env -i, BASH_ENV re-entry) while still inheriting
# __ENV_SOURCED. The xdg-open name is what Python's webbrowser module looks
# for; gcloud rejects GenericBrowser but accepts xdg-open as BackgroundBrowser.
# DISPLAY=:0 is required for webbrowser to even register xdg-open — accepted
# tradeoff: it leaks to X11-aware tools in the same shell.
if [ -p /tmp/xdg-open.fifo ] || [ -n "${TERMUX_VERSION:-}" ]; then
  case ":$PATH:" in
    *":$HOME/.config/sh/termux:"*) ;;
    *) export PATH="$HOME/.config/sh/termux:$PATH" ;;
  esac
  if command -v xdg-open >/dev/null 2>&1; then
    export BROWSER=xdg-open
    [ -z "${DISPLAY:-}" ] && export DISPLAY=:0
  fi
fi

[ -n "${__ENV_SOURCED:-}" ] && return
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
__prepend_path "$HOME/.pulumi/bin"

# mise shims for non-interactive shells
__prepend_path "$HOME/.local/share/mise/shims"

unset -f __prepend_path

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

