if [[ $- == *i* ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
