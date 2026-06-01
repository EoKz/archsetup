#!/usr/bin/env bash

install_river_config_files() {
  local src
  local name

  for src in "$SCRIPT_DIR"/files/home/.config/river/config.d/[0-9][0-9]-*.sh; do
    [[ -e "$src" ]] || continue
    name="$(basename -- "$src")"
    install_user_file "$src" "$TARGET_HOME/.config/river/config.d/$name" 644
  done
}

configure_river() {
  echo "Configurando river para $TARGET_USER..."
  install_user_file "$SCRIPT_DIR/files/home/.config/river/init" "$TARGET_HOME/.config/river/init" 755
  install_user_file "$SCRIPT_DIR/files/home/.config/river/session-river" "$TARGET_HOME/.config/river/session-river" 755
  install_river_config_files
}
