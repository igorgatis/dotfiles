#!/bin/sh
# termux.sh - Termux host-only tweaks (no-op elsewhere, including proot guests).
# Sourced from env.sh so functions reach non-interactive shells too.
# BROWSER is set in env.sh by routing to ~/.local/bin/open-url, which
# handles both native Termux and proot-guest-with-bridge cases.

[ -n "${TERMUX_VERSION-}" ] || return 0

# Per-session URL bridge: a FIFO that opens URLs via termux-open-url when
# written to. Use $URL_BRIDGE_PIPE as a --bind source for guests that
# can't call termux-open-url directly (e.g. proot Debian).
#
# Usage:
#   url_bridge_start || return 1
#   # ... use $URL_BRIDGE_PIPE ...
#   url_bridge_stop
#
# A phantom-writer FD in the caller keeps the reader alive across guest
# processes opening/closing the pipe; url_bridge_stop closes it so the
# reader drains and exits without needing a kill.
url_bridge_start() {
  command -v termux-open-url >/dev/null 2>&1 || {
    echo "url_bridge_start: termux-open-url not installed" >&2
    return 1
  }
  [ -n "${URL_BRIDGE_PIPE:-}" ] && url_bridge_stop
  URL_BRIDGE_PIPE=$(mktemp -u "$PREFIX/tmp/url-bridge.XXXXXX") || return 1
  mkfifo "$URL_BRIDGE_PIPE" || { unset URL_BRIDGE_PIPE; return 1; }
  exec 9<>"$URL_BRIDGE_PIPE"
  (
    exec 9>&-
    __ub_last=""; __ub_last_ts=0
    while IFS= read -r url || [ -n "$url" ]; do
      [ -z "$url" ] && continue
      __ub_now=$(date +%s)
      if [ "$url" = "$__ub_last" ] && [ $((__ub_now - __ub_last_ts)) -lt 2 ]; then
        continue
      fi
      __ub_last="$url"; __ub_last_ts=$__ub_now
      termux-open-url "$url"
    done < "$URL_BRIDGE_PIPE"
  ) &
  URL_BRIDGE_READER=$!
}

url_bridge_stop() {
  [ -n "${URL_BRIDGE_PIPE:-}" ] || return 0
  exec 9>&-
  [ -n "${URL_BRIDGE_READER:-}" ] && wait "$URL_BRIDGE_READER" 2>/dev/null
  rm -f "$URL_BRIDGE_PIPE"
  unset URL_BRIDGE_PIPE URL_BRIDGE_READER
}

if command -v proot-distro >/dev/null 2>&1; then
  debian() {
    __debian_rootfs="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
    if [ -f "$__debian_rootfs/etc/profile" ] && \
       grep -q '/data/data/com.termux/files/usr/bin' "$__debian_rootfs/etc/profile" 2>/dev/null; then
      sed -i 's|:/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin||g' \
        "$__debian_rootfs/etc/profile" "$__debian_rootfs/etc/environment"
    fi
    unset __debian_rootfs

    __debian_bind=""
    url_bridge_start && __debian_bind="--bind $URL_BRIDGE_PIPE:/url-bridge"
    if [ "$#" -eq 0 ]; then
      proot-distro login debian --isolated --user igorgatis $__debian_bind
    else
      proot-distro login debian --isolated --user igorgatis $__debian_bind \
        -- env -u __ENV_SOURCED bash -lc "$*"
    fi
    __debian_rc=$?
    url_bridge_stop
    unset __debian_bind
    return $__debian_rc
  }
fi
