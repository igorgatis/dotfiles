
if command -v yadm >/dev/null 2>&1; then
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
  check_file="$HOME/.config/sh/.yadm_last_check"
  if [[ ! -f "$check_file" || $(find "$check_file" -mtime +1 2>/dev/null) ]]; then
    touch "$check_file"
    check_yadm
  fi
else
  yadm() {
    echo "yadm is not installed. Run:"
    if [[ -n "$TERMUX_VERSION" ]]; then
      echo "pkg install yadm"
    else
      echo 'brew install yadm'
    fi
  }
fi
