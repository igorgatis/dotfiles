
if command -v yadm >/dev/null 2>&1; then
  local ts_file="$HOME/.config/bash/.yadm_last_check"

  function check_yadm() {
    if [[ -n "$(yadm status --porcelain)" ]]; then
      echo "yadm: pending local changes."
    elif ! yadm diff --quiet HEAD origin/main; then
      echo "yadm: remote changes available."
    else
      (yadm fetch >/dev/null 2>&1) & disown
    fi
  }

  # Check once a day.
  local ts=$(date +%Y-%m-%d)
  if [[ "$(cat "$ts_file" 2>/dev/null || echo "")" != "$ts" ]]; then
    echo "$ts" > "$ts_file"
    check_yadm
  fi
fi
