#!/bin/bash
COMMAND=$(cat | jq -r '.tool_input.command')
FIRST_WORD=$(echo "$COMMAND" | awk '{print $1}')

case "$FIRST_WORD" in
  cat|head|tail|less|more)
    echo "Use the Read tool instead of '$FIRST_WORD'." >&2
    exit 2
    ;;
  grep|rg|ag|ack)
    echo "Use the Grep tool instead of '$FIRST_WORD'." >&2
    exit 2
    ;;
  find)
    echo "Use the Glob tool instead of '$FIRST_WORD'." >&2
    exit 2
    ;;
  sed)
    echo "Use the Edit tool instead of '$FIRST_WORD'." >&2
    exit 2
    ;;
  echo)
    if echo "$COMMAND" | grep -qE '>\s*\S'; then
      echo "Use the Write tool instead of 'echo > file'." >&2
      exit 2
    fi
    ;;
  cd)
    if echo "$COMMAND" | grep -qE '&&|;'; then
      echo "Instead of 'cd <dir> && <cmd>', use separate calls: 'pushd <dir>', then '<cmd>', then 'popd'." >&2
      exit 2
    fi
    ;;
  git)
    if echo "$COMMAND" | grep -qE '^git\s+-C\s'; then
      echo "Use 'pushd <dir>' + 'git ...' + 'popd' instead of 'git -C'." >&2
      exit 2
    fi
    ;;
esac

exit 0
