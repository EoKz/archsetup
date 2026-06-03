# ~/.bash_profile

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z "${WAYLAND_DISPLAY:-}" && "${XDG_VTNR:-}" == "1" && -x "$HOME/.config/river/session-river" ]]; then
  exec "$HOME/.config/river/session-river"
fi
