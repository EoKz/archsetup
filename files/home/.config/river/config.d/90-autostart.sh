#!/usr/bin/env sh

autostart_once() {
  pattern="$1"
  shift

  if command -v pgrep >/dev/null 2>&1 && pgrep -u "$(id -u)" -f "$pattern" >/dev/null 2>&1; then
    return 0
  fi

  "$@" &
}

restart_clipboard_watchers() {
  command -v wl-paste >/dev/null 2>&1 || return 0
  command -v cliphist >/dev/null 2>&1 || return 0

  if command -v pkill >/dev/null 2>&1; then
    pkill -u "$(id -u)" -f "wl-paste .*cliphist store" 2>/dev/null || true
  fi

  wl-paste --type text --watch cliphist store &
  wl-paste --type image --watch cliphist store &
}

restart_portals() {
  command -v systemctl >/dev/null 2>&1 || return 0

  systemctl --user restart \
    xdg-desktop-portal.service \
    xdg-desktop-portal-wlr.service \
    xdg-desktop-portal-gtk.service \
    >/dev/null 2>&1 || true
}

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  xdg-user-dirs-update
fi

if command -v lxqt-policykit-agent >/dev/null 2>&1; then
  autostart_once "lxqt-policykit-agent" lxqt-policykit-agent
fi

if command -v udiskie >/dev/null 2>&1; then
  autostart_once "udiskie" udiskie --tray
fi

restart_clipboard_watchers
restart_portals
