if command -v claude &> /dev/null; then
  function _concise_claude() {
    flags="-p"
    if [[ "${1}" == "-c" ]]; then
      flags+=" -c"
      shift
    fi

    echo "thinking..."
    claude --append-system-prompt \
"Bash shell assistant. Short answers only. Never run commands or use tools. \
No markdown. If answer is a command, just print it." \
    ${flags} "${*}"
  }

  alias ai=_concise_claude
fi
