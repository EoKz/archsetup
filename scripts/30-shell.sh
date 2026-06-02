#!/usr/bin/env bash

ensure_zsh_in_shells() {
  local zsh_path="$1"

  [[ -f /etc/shells ]] || die "arquivo nao encontrado: /etc/shells"

  if ! grep -Fxq "$zsh_path" /etc/shells; then
    backup_existing_file /etc/shells
    printf '%s\n' "$zsh_path" >> /etc/shells
  fi
}

set_default_shell() {
  local zsh_path
  local current_shell

  command -v chsh >/dev/null 2>&1 || die "chsh nao encontrado."
  zsh_path="$(command -v zsh)" || die "zsh nao encontrado depois da instalacao dos pacotes."
  ensure_zsh_in_shells "$zsh_path"

  current_shell="$(getent passwd "$TARGET_USER" | cut -d: -f7)"
  if [[ "$current_shell" != "$zsh_path" ]]; then
    chsh -s "$zsh_path" "$TARGET_USER"
  fi
}

configure_shell() {
  echo "Configurando shell para $TARGET_USER..."
  set_default_shell
}
