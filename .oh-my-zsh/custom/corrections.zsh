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
      BUFFER="${BUFFER%compoes}compose";;
    vi|*' vi')
      BUFFER="${BUFFER%vi}nvim";;
    ud|*' ud')
      BUFFER="${BUFFER%ud}update-dotfiles";;
  esac
  CURSOR=${#BUFFER} # update cursor position when buffer length changes
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
