#!/bin/sh
# termux.sh - Termux host-only tweaks (no-op elsewhere, including proot guests).
# Sourced from env.sh so functions reach non-interactive shells too.
# BROWSER is set in env.sh by routing to ~/.config/sh/termux/xdg-open, which
# hands URLs to xdg-open-server (started on demand here).

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

    __debian_bind="--bind $PREFIX"
    if command -v xdg-open-server >/dev/null 2>&1; then
      __fifo=$(xdg-open-server start 2>/dev/null) || __fifo=""
      [ -n "$__fifo" ] && __debian_bind="$__debian_bind --bind $__fifo:/tmp/xdg-open.fifo"
      unset __fifo
    fi
    if [ "$#" -eq 0 ]; then
      proot-distro login debian --isolated --user igorgatis $__debian_bind
    elif [ "$#" -eq 1 ]; then
      proot-distro login debian --isolated --user igorgatis $__debian_bind \
        -- env -u __ENV_SOURCED bash -lc "$1"
    else
      proot-distro login debian --isolated --user igorgatis $__debian_bind \
        -- env -u __ENV_SOURCED bash -lc 'exec "$@"' bash "$@"
    fi
    __debian_rc=$?
    unset __debian_bind
    return $__debian_rc
  }
fi
