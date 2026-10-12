#!/bin/sh

if [ -e "$(git rev-parse --git-path dotfiles-updating)" ]; then
  log-status unchanged "Pull (rewrite) detected, skipping dotfiles updater during nested update"
else
  log-status info "Pull (rewrite) detected, running dotfiles updater"
  ./bin/update-dotfiles --skip-self-update
fi
