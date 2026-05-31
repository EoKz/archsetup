#!/usr/bin/env bash

backup_existing_file() {
  local path="$1"
  local backup
  local counter=1

  backup="$path.archsetup-backup.$(date +%Y%m%d-%H%M%S)"
  while [[ -e "$backup" ]]; do
    backup="$path.archsetup-backup.$(date +%Y%m%d-%H%M%S).$counter"
    counter=$((counter + 1))
  done

  cp -a -- "$path" "$backup"
  echo "Backup criado: $backup"
}

install_user_file() {
  local src="$1"
  local dst="$2"
  local dst_dir

  [[ -f "$src" ]] || die "arquivo de origem nao encontrado: $src"
  [[ ! -d "$dst" ]] || die "destino e um diretorio, nao um arquivo: $dst"
  dst_dir="$(dirname -- "$dst")"

  if [[ ! -d "$dst_dir" ]]; then
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_GROUP" -- "$dst_dir"
  fi

  if [[ -f "$dst" ]] && cmp -s -- "$src" "$dst"; then
    return 0
  fi

  if [[ -e "$dst" ]]; then
    backup_existing_file "$dst"
  fi

  install -D -m 644 -o "$TARGET_USER" -g "$TARGET_GROUP" -- "$src" "$dst"
}

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

install_shell_files() {
  install_user_file "$SCRIPT_DIR/files/home/.zshrc" "$TARGET_HOME/.zshrc"
  install_user_file "$SCRIPT_DIR/files/home/.config/starship.toml" "$TARGET_HOME/.config/starship.toml"
}

configure_shell() {
  echo "Configurando shell para $TARGET_USER..."
  install_shell_files
  set_default_shell
}
