#!/bin/sh

if [ -e "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/updating" ]; then
  log-status unchanged "Pull (merge) detected, skipping dotfiles updater during nested update"
else
  log-status info "Pull (merge) detected, running dotfiles updater"
  ./bin/update-dotfiles --skip-self-update
fi
