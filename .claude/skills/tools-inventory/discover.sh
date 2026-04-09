#!/bin/sh
set -e

filter="${1:-}"

match() {
  [ -z "$filter" ] && return 0
  case "$1" in
    *"$filter"*) return 0 ;;
  esac
  return 1
}

section() {
  echo ""
  echo "## $1"
}

list_dir() {
  files="$(ls "$1" 2>/dev/null)" || return 1
  [ -n "$files" ] || return 1
  echo "$files"
}

read -r os arch <<EOF
$(uname -s -m)
EOF

if [ -n "${TERMUX_VERSION:-}" ]; then
  platform="termux"
  pkgmgr="pkg"
elif [ "$os" = "Darwin" ]; then
  platform="macos"
  pkgmgr="brew"
else
  platform="linux"
  if command -v brew >/dev/null 2>&1; then
    pkgmgr="brew"
  elif command -v apt >/dev/null 2>&1; then
    pkgmgr="apt"
  else
    pkgmgr="unknown"
  fi
fi

section "Platform"
echo "$os $arch ($platform, $pkgmgr)"

if match "system" || match "package" || match "pkg" || match "brew" || match "apt"; then
  section "System Packages (explicitly installed)"
  if [ "$pkgmgr" = "pkg" ]; then
    pkg list-installed 2>/dev/null | grep -v ',automatic]' | sed 's|/.*||' | sort
  elif [ "$pkgmgr" = "brew" ]; then
    echo "# Formulae (leaves):"
    brew leaves 2>/dev/null | sort
    if [ "$os" = "Darwin" ]; then
      echo "# Casks:"
      brew list --cask 2>/dev/null | sort
    fi
  elif [ "$pkgmgr" = "apt" ]; then
    apt list --manual-installed 2>/dev/null | grep -v '^Listing' | sed 's|/.*||' | sort
  fi
fi

if match "runtime" || match "node" || match "python" || match "go" || match "rust" \
   || match "deno" || match "version" || match "mise"; then
  section "Runtimes"
  for rt in node python3 go rustc deno; do
    if command -v "$rt" >/dev/null 2>&1; then
      ver="$("$rt" --version 2>/dev/null | head -1)" || ver="installed"
      printf "%-10s %s\n" "$rt" "$ver"
    fi
  done

  if command -v mise >/dev/null 2>&1; then
    echo ""
    echo "# mise global:"
    mise ls --global 2>/dev/null || true
    if [ -f .mise.toml ] || [ -f .tool-versions ]; then
      echo "# mise local (cwd):"
      mise ls 2>/dev/null || true
    fi
  fi
fi

if match "global" || match "npm" || match "go" || match "cargo" || match "pip" \
   || match "uv" || match "cli" || match "tool"; then
  section "Global CLI Tools"

  if command -v npm >/dev/null 2>&1; then
    echo "# npm global:"
    npm list -g --depth=0 --parseable 2>/dev/null | tail -n +2 | sed 's|.*/||' || true
  fi

  if files="$(list_dir "$HOME/go/bin")"; then
    echo "# go binaries (~/go/bin):"
    echo "$files"
  fi

  if files="$(list_dir "$HOME/.cargo/bin")"; then
    echo "# cargo binaries (~/.cargo/bin):"
    echo "$files" | grep -Ev '^\.|^(cargo|rustc|rustup|rustfmt|rustdoc|rust-)'
  fi

  if command -v uv >/dev/null 2>&1; then
    echo "# uv tools:"
    uv tool list 2>/dev/null || true
  elif command -v pip >/dev/null 2>&1; then
    echo "# pip packages:"
    pip list --format=columns 2>/dev/null || true
  fi

  if files="$(list_dir "$HOME/.local/bin")"; then
    echo "# ~/.local/bin:"
    echo "$files"
  fi
fi

if match "repo" || match "local" || match "override" || match "version" \
   || match "mise" || match "nvm" || match "uv"; then
  section "Repo-Local Overrides (cwd: $PWD)"
  found=0
  for f in .mise.toml .tool-versions .nvmrc .node-version .python-version \
           .go-version .ruby-version rust-toolchain.toml; do
    if [ -f "$f" ]; then
      found=1
      echo "# $f:"
      cat "$f"
      echo ""
    fi
  done
  if [ -f pyproject.toml ]; then
    rp="$(grep 'requires-python' pyproject.toml 2>/dev/null)" && {
      found=1
      echo "# pyproject.toml: $rp"
    }
  fi
  if [ -f package.json ]; then
    eng="$(grep -A2 '"engines"' package.json 2>/dev/null)" && {
      found=1
      echo "# package.json engines:"
      echo "$eng"
    }
  fi
  if [ -f go.mod ]; then
    gover="$(grep '^go ' go.mod 2>/dev/null)" && {
      found=1
      echo "# go.mod: $gover"
    }
  fi
  [ "$found" = "0" ] && echo "(none)"
fi

if match "shell" || match "alias" || match "lazy" || match "function"; then
  section "Shell Aliases"
  if [ -f "$HOME/.config/sh/aliases.sh" ]; then
    grep '^[[:space:]]*alias ' "$HOME/.config/sh/aliases.sh" | sed 's/^[[:space:]]*//'
  fi

  echo ""
  echo "# Lazy-install stubs (may not be installed yet):"
  if [ -f "$HOME/.config/sh/tools.sh" ]; then
    grep '^__lazy_install "' "$HOME/.config/sh/tools.sh" | sed 's/.*__lazy_install "\([^"]*\)".*/  \1/'
  fi
fi
