#!/bin/sh

if [ -e "$(git rev-parse --git-path postinstall-updating)" ]; then
  log-status unchanged "Pull (rewrite) detected, skipping postinstall script during update"
else
  log-status info "Pull (rewrite) detected, running postinstall script"
  ./postinstall.zsh --skip-self-update
fi
