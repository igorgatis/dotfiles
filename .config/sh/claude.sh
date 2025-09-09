if command -v claude &> /dev/null; then
  _concise_claude() {
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
else
  ai() {
    echo "Claude is not installed. Run:"
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "npm install -g @anthropic-ai/claude-code"
    else
      echo 'brew install --cask claude-code'
    fi
  }
fi
