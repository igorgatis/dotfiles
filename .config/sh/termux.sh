#!/bin/sh
# termux.sh - Termux host-only tweaks (no-op elsewhere, including proot guests).

[ -n "${TERMUX_VERSION-}" ] || return 0

if command -v proot-distro >/dev/null 2>&1; then
  debian() {
    __debian_rootfs="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
    if [ -f "$__debian_rootfs/etc/profile" ] && \
       grep -q '/data/data/com.termux/files/usr/bin' "$__debian_rootfs/etc/profile" 2>/dev/null; then
      sed -i 's|:/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin||g' \
        "$__debian_rootfs/etc/profile" "$__debian_rootfs/etc/environment"
    fi
    unset __debian_rootfs
    if [ "$#" -eq 0 ]; then
      proot-distro login debian --isolated --user igorgatis --bind "$PREFIX:$PREFIX"
    else
      proot-distro login debian --isolated --user igorgatis --bind "$PREFIX:$PREFIX" \
        -- env -u __ENV_SOURCED bash -lc "$*"
    fi
  }
fi
