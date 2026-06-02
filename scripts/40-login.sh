#!/usr/bin/env bash

check_login_requirements() {
  command -v cage >/dev/null 2>&1 || die "cage nao encontrado depois da instalacao dos pacotes."
  command -v regreet >/dev/null 2>&1 || die "regreet nao encontrado depois da instalacao dos pacotes."
  command -v dbus-run-session >/dev/null 2>&1 || die "dbus-run-session nao encontrado."
  command -v systemctl >/dev/null 2>&1 || die "systemctl nao encontrado."
  id greeter >/dev/null 2>&1 || die "usuario greeter nao encontrado. O pacote greetd deveria criar esse usuario."
}

install_login_files() {
  install_system_file "$SCRIPT_DIR/files/etc/greetd/config.toml" "/etc/greetd/config.toml" 644
  install_system_file "$SCRIPT_DIR/files/etc/greetd/regreet.toml" "/etc/greetd/regreet.toml" 644
  install_system_file "$SCRIPT_DIR/files/etc/greetd/regreet.css" "/etc/greetd/regreet.css" 644
  install_system_file "$SCRIPT_DIR/files/etc/tmpfiles.d/regreet.conf" "/etc/tmpfiles.d/regreet.conf" 644
  install_system_file "$SCRIPT_DIR/files/usr/share/wayland-sessions/archsetup-river.desktop" "/usr/share/wayland-sessions/archsetup-river.desktop" 644
}

prepare_regreet_state() {
  if command -v systemd-tmpfiles >/dev/null 2>&1; then
    systemd-tmpfiles --create /etc/tmpfiles.d/regreet.conf
  else
    install -d -m 755 -o greeter -g greeter /var/lib/regreet /var/log/regreet
  fi
}

enable_greetd() {
  systemctl enable greetd.service
  echo "greetd.service habilitado para o proximo boot."
}

configure_login() {
  echo "Configurando login grafico com greetd/regreet..."
  check_login_requirements
  install_login_files
  prepare_regreet_state
  enable_greetd
}
