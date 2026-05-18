#!/bin/sh
# trace.sh - shell init-order diagnostics
# Logs each rc file as it is sourced, but only when ~/.config/sh/.trace exists.
# Enable on a machine: touch ~/.config/sh/.trace
# Disable: rm ~/.config/sh/.trace     Inspect: cat ~/.cache/initlog

if [ -e "$HOME/.config/sh/.trace" ]; then
  __t_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  mkdir -p "$__t_dir"
  __t_login=$(shopt -q login_shell 2>/dev/null && echo y || echo n)
  echo "$(date +%T) ${__TRACE_NAME:-?} pid=$$ ppid=$PPID flags=$- login=$__t_login" \
    >> "$__t_dir/initlog"
  unset __t_dir __t_login
fi
unset __TRACE_NAME
