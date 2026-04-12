__cnf_handler() {
  local cmd="$1"
  local ret=127

  if [ "${ENABLE_CNF_CLAUDE:-0}" != "1" ]; then
    printf '%s: command not found\n' "$cmd" >&2
    return 127
  fi

  if [ -x /usr/lib/command-not-found ]; then
    /usr/lib/command-not-found -- "$cmd"
    ret=$?
  elif [ -x /data/data/com.termux/files/usr/libexec/termux/command-not-found ]; then
    /data/data/com.termux/files/usr/libexec/termux/command-not-found "$cmd"
    ret=$?
  elif [ -x /usr/bin/pkcon ]; then
    /usr/bin/pkcon what-provides "$cmd" 2>/dev/null
    ret=$?
  else
    printf '%s: command not found\n' "$cmd" >&2
  fi

  if [ -t 0 ] && [ $ret -eq 127 ] && command -v claude >/dev/null 2>&1; then
    local full="$*"
    printf 'Start a Claude Code session with "%s"? [y/N] ' "$full" >&2
    read -r -t 15 answer
    case "$answer" in
      [yY]*) claude "$full"; return $? ;;
    esac
  fi

  return $ret
}

__cnf_enable() {
  export ENABLE_CNF_CLAUDE=1
  if [ -n "${BASH_VERSION-}" ]; then
    PROMPT_COMMAND="${PROMPT_COMMAND//__cnf_enable;/}"
  elif [ -n "${ZSH_VERSION-}" ]; then
    add-zsh-hook -d precmd __cnf_enable
  fi
}

if [ -n "${BASH_VERSION-}" ]; then
  command_not_found_handle() { __cnf_handler "$@"; }
  case "${PROMPT_COMMAND-}" in
    *__cnf_enable*) ;;
    *) PROMPT_COMMAND="__cnf_enable;${PROMPT_COMMAND-}" ;;
  esac
elif [ -n "${ZSH_VERSION-}" ]; then
  command_not_found_handler() { __cnf_handler "$@"; }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd __cnf_enable
fi
