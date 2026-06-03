#!/usr/bin/env bash

install_user_file() {
  local src="$1"
  local dst="$2"
  local mode="${3:-644}"
  local dst_dir

  [[ -f "$src" ]] || die "arquivo de origem nao encontrado: $src"
  [[ ! -d "$dst" ]] || die "destino e um diretorio, nao um arquivo: $dst"
  dst_dir="$(dirname -- "$dst")"

  if [[ ! -d "$dst_dir" ]]; then
    install -d -m 755 -o "$TARGET_USER" -g "$TARGET_GROUP" -- "$dst_dir"
  fi

  if [[ -f "$dst" && ! -L "$dst" ]] && cmp -s -- "$src" "$dst"; then
    chown "$TARGET_USER:$TARGET_GROUP" "$dst"
    chmod "$mode" "$dst"
    return 0
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    rm -f -- "$dst"
  fi

  install -D -m "$mode" -o "$TARGET_USER" -g "$TARGET_GROUP" -- "$src" "$dst"
}
