#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/packages/packages.txt"
PACMAN_CONF="${PACMAN_CONF:-/etc/pacman.conf}"
TARGET_USER="${TARGET_USER:-${SUDO_USER:-}}"
TARGET_HOME=""
TARGET_GROUP=""

die() {
  echo "erro: $*" >&2
  exit 1
}

on_error() {
  local exit_code=$?
  echo "erro: execucao interrompida na linha $1 (codigo: $exit_code)." >&2
  exit "$exit_code"
}

trap 'on_error "$LINENO"' ERR

[[ -f "$PACKAGE_FILE" ]] || die "arquivo de pacotes nao encontrado: $PACKAGE_FILE"
command -v pacman >/dev/null 2>&1 || die "pacman nao encontrado. Rode este script no Arch Linux."
[[ -f "$PACMAN_CONF" ]] || die "arquivo do pacman nao encontrado: $PACMAN_CONF"

if ((EUID != 0)); then
  command -v sudo >/dev/null 2>&1 || die "sudo nao encontrado. Rode este script como root."
  exec sudo env TARGET_USER="$TARGET_USER" bash "$SCRIPT_DIR/setup.sh" "$@"
fi

resolve_target_user() {
  [[ -n "$TARGET_USER" ]] || die "usuario alvo nao definido. Rode com sudo pelo usuario alvo ou use TARGET_USER=usuario."
  [[ "$TARGET_USER" != "root" ]] || die "nao vou configurar o shell do root como usuario alvo."
  id "$TARGET_USER" >/dev/null 2>&1 || die "usuario alvo nao existe: $TARGET_USER"

  TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
  TARGET_GROUP="$(id -gn "$TARGET_USER")"

  [[ -n "$TARGET_HOME" && -d "$TARGET_HOME" ]] || die "home do usuario alvo nao encontrado: $TARGET_USER"
}

source "$SCRIPT_DIR/scripts/lib.sh"
source "$SCRIPT_DIR/scripts/00-pacman.sh"
source "$SCRIPT_DIR/scripts/10-packages.sh"
source "$SCRIPT_DIR/scripts/20-dotfiles.sh"
source "$SCRIPT_DIR/scripts/30-shell.sh"

resolve_target_user
read_packages
configure_pacman
synchronize_databases
validate_packages
install_packages
install_dotfiles
configure_shell

echo "Setup finalizado com sucesso."
