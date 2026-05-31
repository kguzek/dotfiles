#!/bin/sh

if [ -e "$(git rev-parse --git-path postinstall-updating)" ]; then
  log-status unchanged "Pull (merge) detected, skipping postinstall script during update"
else
  log-status info "Pull (merge) detected, running postinstall script"
  ./postinstall.zsh --skip-self-update
fi
