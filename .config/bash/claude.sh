if command -v claude &> /dev/null; then
  function _concise_claude() {
    if [ $# -eq 0 ]; then
      echo "try: ai how prune git branches"
      return
    fi
    echo "thinking..."
    claude --append-system-prompt \
"Bash shell assistant. Short answers only. Never run commands or use tools. \
No markdown. If answer is a command, just print it." \
    -p "${*}"
  }
  alias ai=_concise_claude
fi
