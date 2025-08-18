
#!/bin/bash

if command -v yadm >/dev/null 2>&1; then
  local update_file="$HOME/.config/bash/.yadm_changes"
  local ts_file="$HOME/.config/bash/.yadm_last_check"

  function check_yadm_async() {
    if [[ -n "$(yadm status --porcelain)" ]]; then
      echo "yadm: pending local changes." > "$update_file"
    else
      yadm fetch >/dev/null 2>&1
      if ! yadm diff --quiet HEAD origin/main; then
        echo "yadm: update available." > "$update_file"
      else
        rm -f "$update_file"
      fi
    fi
  }

  local ts=$(date +%Y-%m-%d)
  if [[ "$(cat "$ts_file" 2>/dev/null || echo "")" != "$ts" ]]; then
    echo "$ts" > "$ts_file"
    if [[ -f "$update_file" ]]; then
      cat "$update_file"
    else
      check_yadm_async & disown
    fi
  fi
fi
