correct-on-space() {
  case "$BUFFER" in
    *(docker|podman)' compoes')
      BUFFER="${BUFFER%compoes}compose"
       ;;
  esac

  zle self-insert
}

zle -N correct-on-space
bindkey ' ' correct-on-space
