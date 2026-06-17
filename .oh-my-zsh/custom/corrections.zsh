correct-on-both() {
  case "$BUFFER" in
    */reops)
      BUFFER="${BUFFER%reops}repos"
       ;;
    */samab)
      BUFFER="${BUFFER%samab}samba"
       ;;
  esac
}

correct-on-space() {
  correct-on-both
  case "$BUFFER" in
    *(docker|podman)' compoes')
      BUFFER="${BUFFER%compoes}compose"
       ;;
  esac
  zle magic-space
}



correct-on-slash() {
  correct-on-both
  zle self-insert
}

zle -N correct-on-space
zle -N correct-on-slash
bindkey ' ' correct-on-space
bindkey '/' correct-on-slash
