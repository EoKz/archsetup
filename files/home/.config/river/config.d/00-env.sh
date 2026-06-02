#!/usr/bin/env sh

sync_vars="XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE DESKTOP_SESSION MOZ_ENABLE_WAYLAND MOZ_DBUS_REMOTE GDK_BACKEND QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME QT_WAYLAND_DISABLE_WINDOWDECORATION CLUTTER_BACKEND SDL_VIDEODRIVER _JAVA_AWT_WM_NONREPARENTING GTK_THEME"

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  sync_vars="WAYLAND_DISPLAY $sync_vars"
fi

if [ -n "${DISPLAY:-}" ]; then
  sync_vars="DISPLAY $sync_vars"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user import-environment $sync_vars 2>/dev/null || true
fi

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
  dbus-update-activation-environment --systemd $sync_vars 2>/dev/null || true
fi

unset sync_vars
