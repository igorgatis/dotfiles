#!/bin/sh
set -e

action="${1:-help}"
shift 2>/dev/null || true

SH_DIR="$HOME/.config/sh"

case "$action" in
  list-tools)
    echo "# Lazy-install tools in tools.sh:"
    grep '^__lazy_install "' "$SH_DIR/tools.sh" | \
      sed 's/.*__lazy_install "\([^"]*\)".*/\1/' | while read -r tool; do
        if command -v "$tool" >/dev/null 2>&1; then
          printf "  %-20s [installed]\n" "$tool"
        else
          printf "  %-20s [stub]\n" "$tool"
        fi
      done
    ;;

  list-aliases)
    echo "# Aliases in aliases.sh:"
    grep '^[[:space:]]*alias ' "$SH_DIR/aliases.sh" | sed 's/^[[:space:]]*//'
    ;;

  list-env)
    echo "# Exports in env.sh:"
    grep '^[[:space:]]*export ' "$SH_DIR/env.sh" | sed 's/^[[:space:]]*//'
    ;;

  check-portable)
    echo "# Portability check for $SH_DIR:"
    issues=0

    for f in "$SH_DIR/env.sh" "$SH_DIR/aliases.sh" "$SH_DIR/tools.sh" \
             "$SH_DIR/interactive.sh" "$SH_DIR/completion.sh" "$SH_DIR/prompt.sh"; do
      [ -f "$f" ] || continue
      name="${f##*/}"

      if grep -q '\[\[' "$f" 2>/dev/null; then
        echo "  WARN: $name has [[ ]] (not POSIX)"
        issues=$((issues + 1))
      fi
      if grep -q 'source ' "$f" 2>/dev/null; then
        echo "  WARN: $name uses 'source' (use '.' for POSIX)"
        issues=$((issues + 1))
      fi
      if grep -q '	' "$f" 2>/dev/null; then
        echo "  WARN: $name has tab characters"
        issues=$((issues + 1))
      fi
      if grep -q '[[:space:]]$' "$f" 2>/dev/null; then
        echo "  WARN: $name has trailing whitespace"
        issues=$((issues + 1))
      fi
    done

    if [ "$issues" = "0" ]; then
      echo "  All clear."
    fi
    ;;

  platform)
    read -r os arch <<EOF
$(uname -s -m)
EOF
    if [ -n "${TERMUX_VERSION:-}" ]; then
      echo "termux $os $arch pkg"
    elif [ "$os" = "Darwin" ]; then
      echo "macos $os $arch brew"
    else
      if command -v brew >/dev/null 2>&1; then
        echo "linux $os $arch brew"
      elif command -v apt >/dev/null 2>&1; then
        echo "linux $os $arch apt"
      else
        echo "linux $os $arch unknown"
      fi
    fi
    ;;

  pkg-search)
    query="$1"
    [ -z "$query" ] && { echo "Usage: dotfiles-helper.sh pkg-search <name>"; exit 1; }
    if [ -n "${TERMUX_VERSION:-}" ]; then
      echo "# pkg (Termux):"
      pkg search "$query" 2>/dev/null | head -10
    fi
    if command -v brew >/dev/null 2>&1; then
      echo "# brew:"
      brew search "$query" 2>/dev/null | head -10
    fi
    if command -v npm >/dev/null 2>&1; then
      echo "# npm:"
      npm search "$query" --long=false 2>/dev/null | head -5
    fi
    ;;

  validate)
    echo "# Testing shell startup..."
    errs=0
    for sh in bash zsh; do
      if command -v "$sh" >/dev/null 2>&1; then
        if "$sh" -i -c 'echo ok' >/dev/null 2>&1; then
          echo "  $sh: ok"
        else
          echo "  $sh: FAILED"
          errs=$((errs + 1))
        fi
      fi
    done
    exit $errs
    ;;

  *)
    cat <<'EOF'
Usage: dotfiles-helper.sh <action> [args...]

Actions:
  list-tools       Show lazy-install tools and their status
  list-aliases     Show all aliases
  list-env         Show exported env vars from env.sh
  check-portable   Check shared shell files for POSIX issues
  platform         Print platform info (os arch pkgmgr)
  pkg-search NAME  Search for a package across managers
  validate         Test bash and zsh interactive startup
EOF
    ;;
esac
