#!/usr/bin/env bash

packages=()

trim() {
  local value="$1"
  value="${value//$'\r'/}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

normalize_package_line() {
  local raw="$1"
  local repo pkg

  raw="${raw%%#*}"
  raw="$(trim "$raw")"
  [[ -n "$raw" ]] || return 1

  if [[ "$raw" == */* ]]; then
    repo="${raw%%/*}"
    pkg="${raw#*/}"
    repo="$(trim "$repo")"
    pkg="$(trim "$pkg")"
    repo="${repo,,}"

    case "$repo" in
      core|extra|multilib) ;;
      *) die "repositorio invalido na lista de pacotes: $raw" ;;
    esac

    [[ -n "$pkg" ]] || die "pacote vazio na lista de pacotes: $raw"
    printf '%s/%s\n' "$repo" "$pkg"
    return 0
  fi

  printf '%s\n' "$raw"
}

read_packages() {
  local line
  local normalized
  local -A seen_packages=()

  packages=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    if ! normalized="$(normalize_package_line "$line")"; then
      continue
    fi

    if [[ -z "${seen_packages[$normalized]+x}" ]]; then
      packages+=("$normalized")
      seen_packages["$normalized"]=1
    fi
  done < "$PACKAGE_FILE"

  ((${#packages[@]} > 0)) || die "nenhum pacote encontrado em $PACKAGE_FILE"
}

validate_packages() {
  local missing=()
  local pkg

  echo "Verificando pacotes nos repositorios..."
  for pkg in "${packages[@]}"; do
    if ! pacman -Si "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if ((${#missing[@]} > 0)); then
    echo "erro: pacotes nao encontrados nos repositorios:" >&2
    printf '  %s\n' "${missing[@]}" >&2
    exit 1
  fi
}

install_packages() {
  echo "Instalando ${#packages[@]} pacotes..."
  pacman -S --needed "${packages[@]}"
  echo "Pacotes instalados com sucesso."
}
