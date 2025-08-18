
#!/bin/bash

if command -v yadm >/dev/null 2>&1; then
  # Check once per day
  local today=$(date +%Y-%m-%d)
  local file="$HOME/.config/bash/.yadm_last_check"
  if [[ "$(cat "$file" 2>/dev/null || echo "")" != "$today" ]]; then
    echo "$today" > "$file"
    if ! yadm diff --quiet || ! yadm diff --cached --quiet; then
      echo "REMINDER: you have pending yadm changes."
    fi
  fi
fi
