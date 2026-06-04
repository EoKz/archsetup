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

prepare_target_home() {
  install -d -m 700 -o "$TARGET_USER" -g "$TARGET_GROUP" -- \
    "$TARGET_HOME/.config" \
    "$TARGET_HOME/.cache" \
    "$TARGET_HOME/.local" \
    "$TARGET_HOME/.local/state"

  install -d -m 755 -o "$TARGET_USER" -g "$TARGET_GROUP" -- \
    "$TARGET_HOME/.local/bin" \
    "$TARGET_HOME/.local/share"
}

install_dotfiles() {
  local src
  local rel_path
  local dst
  local mode

  [[ -d "$SCRIPT_DIR/files/home" ]] || die "diretorio de dotfiles nao encontrado: $SCRIPT_DIR/files/home"

  echo "Instalando dotfiles para $TARGET_USER..."

  prepare_target_home

  while IFS= read -r -d '' src; do
    rel_path="${src#"$SCRIPT_DIR/files/home/"}"
    dst="$TARGET_HOME/$rel_path"
    mode="$(dotfile_mode "$rel_path")"
    install_user_file "$src" "$dst" "$mode"
  done < <(find "$SCRIPT_DIR/files/home" -type f -print0 | sort -z)
}
