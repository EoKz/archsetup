#!/usr/bin/env sh

dbus_vars="XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE DESKTOP_SESSION MOZ_ENABLE_WAYLAND GDK_BACKEND QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME GTK_THEME"
systemd_vars="$dbus_vars"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  dbus_vars="WAYLAND_DISPLAY $dbus_vars"
  systemd_vars="WAYLAND_DISPLAY $systemd_vars"
fi

if [ -n "${DISPLAY:-}" ]; then
  dbus_vars="DISPLAY $dbus_vars"
  systemd_vars="DISPLAY $systemd_vars"
fi

if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  dbus_vars="XDG_RUNTIME_DIR $dbus_vars"
  systemd_vars="XDG_RUNTIME_DIR $systemd_vars"
fi

if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
  systemd_vars="DBUS_SESSION_BUS_ADDRESS $systemd_vars"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user import-environment $systemd_vars >/dev/null 2>&1 || true
fi

if command -v dbus-update-activation-environment >/dev/null 2>&1 && { [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ] || [ -n "${XDG_RUNTIME_DIR:-}" ]; }; then
  dbus-update-activation-environment $dbus_vars >/dev/null 2>&1 || true
fi

unset dbus_vars systemd_vars
