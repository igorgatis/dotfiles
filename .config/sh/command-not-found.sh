__cnf_handler() {
  local cmd="$1"
  local full="$*"
  local ret=127

  if [ -x /usr/lib/command-not-found ]; then
    /usr/lib/command-not-found -- "$cmd"
    ret=$?
  elif [ -x /data/data/com.termux/files/usr/libexec/termux/command-not-found ]; then
    /data/data/com.termux/files/usr/libexec/termux/command-not-found "$cmd"
    ret=$?
  elif [ -x /usr/bin/pkcon ]; then
    /usr/bin/pkcon what-provides "$cmd" 2>/dev/null
  else
    printf '%s: command not found\n' "$cmd" >&2
  fi

  if [ -t 0 ] && [ $ret -eq 127 ] && command -v claude >/dev/null 2>&1; then
    printf 'Start a Claude Code session with "%s"? [y/N] ' "$full" >&2
    read -r answer
    case "$answer" in
      [yY]*) claude "$full"; return $? ;;
    esac
  fi

  return $ret
}

if [ -n "${BASH_VERSION-}" ]; then
  command_not_found_handle() { __cnf_handler "$@"; }
elif [ -n "${ZSH_VERSION-}" ]; then
  command_not_found_handler() { __cnf_handler "$@"; }
fi
