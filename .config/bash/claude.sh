if command -v claude &> /dev/null; then
  function _concise_claude() {
    echo "thinking..."
    claude --append-system-prompt \
"Bash shell assistant. Short answers only. \
Never run commands or use tools. No markdown. \
If answer is a command, just print it." \
    -p "${*}"
  }
  alias ai=_concise_claude
fi
