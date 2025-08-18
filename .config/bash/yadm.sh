
#!/bin/bash

if command -v yadm >/dev/null 2>&1; then
  # Check once per day
  local ts=$(date +%Y-%m-%d)
  local file="$HOME/.config/bash/.yadm_last_check"
  if [[ "$(cat "$file" 2>/dev/null || echo "")" != "$ts" ]]; then
    echo "$ts" > "$file"
    yadm fetch >/dev/null 2>&1 & disown
    local local_commit=$(yadm rev-parse @ 2>/dev/null)
    local remote_commit=$(yadm rev-parse @{upstream} 2>/dev/null)
    if [[ "$local_commit" != "$remote_commit" ]]; then
      echo "yadm: update available."
    elif [[ -n "$(yadm status --porcelain)" ]]; then
      echo "yadm: pending local changes."
    fi
  fi
fi
