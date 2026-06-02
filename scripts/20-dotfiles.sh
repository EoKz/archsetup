#!/usr/bin/env bash

dotfile_mode() {
  local rel_path="$1"

  case "$rel_path" in
    .config/river/init|.config/river/session-river|.local/bin/*)
      printf '755\n'
      ;;
    *)
      printf '644\n'
      ;;
  esac
}

install_dotfiles() {
  local src
  local rel_path
  local dst
  local mode

  [[ -d "$SCRIPT_DIR/files/home" ]] || die "diretorio de dotfiles nao encontrado: $SCRIPT_DIR/files/home"

  echo "Instalando dotfiles para $TARGET_USER..."

  while IFS= read -r -d '' src; do
    rel_path="${src#"$SCRIPT_DIR/files/home/"}"
    dst="$TARGET_HOME/$rel_path"
    mode="$(dotfile_mode "$rel_path")"
    install_user_file "$src" "$dst" "$mode"
  done < <(find "$SCRIPT_DIR/files/home" -type f -print0 | sort -z)
}
