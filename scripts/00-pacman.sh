#!/usr/bin/env bash

write_pacman_conf_tmp() {
  local tmp="$1"

  if cmp -s -- "$tmp" "$PACMAN_CONF"; then
    rm -f -- "$tmp"
    return 0
  fi

  install -m 644 -- "$tmp" "$PACMAN_CONF"
  rm -f -- "$tmp"
}

set_pacman_option() {
  local key="$1"
  local desired="$2"
  local tmp

  tmp="$(mktemp)"
  awk -v key="$key" -v desired="$desired" '
    BEGIN {
      found_options = 0
      in_options = 0
      done = 0
    }
    /^[[:space:]]*\[options\][[:space:]]*$/ {
      found_options = 1
      in_options = 1
      print
      next
    }
    /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
      if (in_options && !done) {
        print desired
        done = 1
      }
      in_options = 0
      print
      next
    }
    in_options && $0 ~ "^[[:space:]#]*" key "([[:space:]=]|$)" {
      if (!done) {
        print desired
        done = 1
      }
      next
    }
    in_options && key == "ILoveCandy" && !done && $0 ~ /^[[:space:]]*Color[[:space:]]*$/ {
      print
      print desired
      done = 1
      next
    }
    { print }
    END {
      if (!found_options) {
        print ""
        print "[options]"
        print desired
      } else if (in_options && !done) {
        print desired
      }
    }
  ' "$PACMAN_CONF" > "$tmp"

  write_pacman_conf_tmp "$tmp"
}

ensure_multilib() {
  local tmp

  tmp="$(mktemp)"
  awk '
    function ensure_include() {
      if (in_multilib && !include_seen) {
        print "Include = /etc/pacman.d/mirrorlist"
      }
    }
    BEGIN {
      found = 0
      in_multilib = 0
      include_seen = 0
    }
    /^[[:space:]]*#?[[:space:]]*\[multilib\][[:space:]]*$/ {
      ensure_include()
      print "[multilib]"
      found = 1
      in_multilib = 1
      include_seen = 0
      next
    }
    /^[[:space:]]*#?[[:space:]]*\[[^]]+\][[:space:]]*$/ {
      ensure_include()
      in_multilib = 0
      include_seen = 0
      print
      next
    }
    in_multilib && /^[[:space:]#]*Include[[:space:]]*=[[:space:]]*\/etc\/pacman\.d\/mirrorlist[[:space:]]*$/ {
      if (!include_seen) {
        print "Include = /etc/pacman.d/mirrorlist"
        include_seen = 1
      }
      next
    }
    { print }
    END {
      ensure_include()
      if (!found) {
        print ""
        print "[multilib]"
        print "Include = /etc/pacman.d/mirrorlist"
      }
    }
  ' "$PACMAN_CONF" > "$tmp"

  write_pacman_conf_tmp "$tmp"
}

configure_pacman() {
  echo "Configurando pacman..."
  set_pacman_option "Color" "Color"
  set_pacman_option "VerbosePkgLists" "VerbosePkgLists"
  set_pacman_option "ParallelDownloads" "ParallelDownloads = 5"
  set_pacman_option "ILoveCandy" "ILoveCandy"
  ensure_multilib
}

synchronize_databases() {
  echo "Sincronizando bancos de pacotes..."
  pacman -Sy
}
