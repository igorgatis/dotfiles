
#!/bin/bash

if command -v yadm >/dev/null 2>&1; then
  local ts_file="$HOME/.config/bash/.yadm_last_check"

  function check_yadm() {
    if [[ -n "$(yadm status --porcelain)" ]]; then
      echo "yadm: pending local changes."
    else
      (yadm fetch >/dev/null 2>&1) & disown
      if ! yadm diff --quiet HEAD origin/main; then
        echo "yadm: update available."
      fi
    fi
  }

  # Check once a week.
  local ts=$(date +%Y-%W)
  if [[ "$(cat "$ts_file" 2>/dev/null || echo "")" != "$ts" ]]; then
    echo "$ts" > "$ts_file"
    check_yadm
  fi
fi
