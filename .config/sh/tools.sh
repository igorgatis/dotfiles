#!/bin/sh
# tools.sh - Lazy tool installation and helpers
# Sourced by: interactive.sh (interactive shells only)

# Detect shell for tool initialization
if [ -n "${BASH_VERSION-}" ]; then
  __shell="bash"
elif [ -n "${ZSH_VERSION-}" ]; then
  __shell="zsh"
fi

# --- Lazy install helper ---

__lazy_install() {
  local cmd="$1"
  shift

  local init_func=""
  local install_cmd=""

  while [ $# -gt 0 ]; do
    case $1 in
      --init=*) init_func="${1#*=}" ;;
      --termux=*) [ -n "$TERMUX_VERSION" ] && install_cmd="${1#*=}" ;;
      --linux=*)
        if [ "$(uname)" = "Linux" ] && [ -z "$TERMUX_VERSION" ]; then
          install_cmd="${1#*=}"
        fi
        ;;
      --macos=*) [ "$(uname)" = "Darwin" ] && install_cmd="${1#*=}" ;;
    esac
    shift
  done

  if command -v "$cmd" >/dev/null 2>&1; then
    [ -n "$init_func" ] && eval "$init_func"
    return 0
  fi

  [ -z "$install_cmd" ] && return 1

  eval "$cmd() {
    printf 'Install $cmd? [Y/n]: '
    read response
    case \"\$response\" in
      [yY]*|'')
        if $install_cmd; then
          unset -f $cmd
          [ -n \"$init_func\" ] && eval \"$init_func\"
          $cmd \"\$@\"
        fi
        ;;
    esac
  }"
}

# --- Daily check helper ---

__daily() { :; }

__setup_daily_check() {
  local daily_file="$HOME/.config/sh/.daily_check"
  if [ ! -f "$daily_file" ] || [ -n "$(find "$daily_file" -mtime +1 2>/dev/null)" ]; then
    touch "$daily_file"
    __daily() { "$@"; }
  fi
}

__setup_daily_check

# --- Tool definitions ---

__yadm_check() {
  if [ -n "$(yadm status --porcelain 2>/dev/null)" ]; then
    echo "yadm: pending local changes."
  elif ! yadm diff --quiet HEAD origin/main 2>/dev/null; then
    echo "yadm: remote changes available."
  else
    (yadm fetch >/dev/null 2>&1 &)
  fi
}

__lazy_install "yadm" \
  --init="__daily __yadm_check" \
  --termux="pkg install yadm" \
  --linux="brew install yadm" \
  --macos="brew install yadm"

__lazy_install "starship" \
  --init="eval \"\$(starship init $__shell)\"" \
  --termux="pkg install starship" \
  --linux="brew install starship" \
  --macos="brew install starship"

__lazy_install "gh" \
  --termux="pkg install gh" \
  --linux="brew install gh" \
  --macos="brew install gh"

__lazy_install "claude" \
  --termux="npm install -g @anthropic-ai/claude-code" \
  --linux="brew install claude" \
  --macos="brew install claude"

# --- Helpers ---

ai() {
  local flags="-p"
  if [ "$1" = "-c" ]; then
    flags="$flags -c"
    shift
  fi
  echo "thinking..."
  claude --append-system-prompt \
    "shell assistant. Short answers only. Never run commands or use tools. \
No markdown. If answer is a command, just print it." \
    $flags "$*"
}

unset __shell
