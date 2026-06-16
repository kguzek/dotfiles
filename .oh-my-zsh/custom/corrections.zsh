correct-on-space() {
  case "$BUFFER" in
    *(docker|podman)' compoes')
      BUFFER="${BUFFER%compoes}compose"
       ;;
  esac
  zle self-insert
}



correct-on-slash() {
  zle self-insert
}

correct-on-both() {
  case "$BUFFER" in
    */reops)
      BUFFER="${BUFFER%reops}repos"
       ;;
    */samab)
      BUFFER="${BUFFER%samab}samba"
       ;;
  esac
  zle self-insert
}

zle -N correct-on-space
zle -N correct-on-slash
zle -N correct-on-both
bindkey ' ' correct-on-space
bindkey '/' correct-on-slash
bindkey ' ' correct-on-both
bindkey '/' correct-on-both
