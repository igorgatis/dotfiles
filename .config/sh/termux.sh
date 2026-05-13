#!/bin/sh
# termux.sh - Termux host-only tweaks (no-op elsewhere, including proot guests).

[ -n "${TERMUX_VERSION-}" ] || return 0

if command -v proot-distro >/dev/null 2>&1; then
  debian() {
    if [ "$#" -eq 0 ]; then
      proot-distro login debian --isolated --user igorgatis
    else
      proot-distro login debian --isolated --user igorgatis -- bash -lc "$*"
    fi
  }
fi
