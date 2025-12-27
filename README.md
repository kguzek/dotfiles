# kguzek/dotfiles

Welcome to my personal terminal configuration!

## Overview

This repository contains a basic configuration of vim, a more advanced configuration of neovim based on [NvChad](https://github.com/nvchad/starter), and Zsh dotfiles specific to my use cases as a web developer. One of my optimizations is to [lazy-load Node.js](./.zshrc#L136) by deferring the initialization of `nvm` until the first invocation of a Node.js-related binary in a given shell session, which significantly improves terminal startup.

## Installation

1. Clone the repo into a folder of your choice and `cd` into it
2. [Install Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#install-and-set-up-zsh-as-default)
3. Run `./install.sh`
4. Logout and log in again (or start a new terminal session)
5. `cd` back into the folder and run `./postinstall.sh`

## Post-installation script

The `postinstall.sh` script creates symlinks pointing to the appropriate dotfiles in your home directory, so they work regardless of wherever you clone this repository and allow the files to be version controlled without having a git repo in `~`.

Most files are mirrored in terms of directory structure, except for the `hooks` folder: that folder contains shell scripts which are symlinked in the `.git/hooks` directory (without the `.sh` extension).

Additionally, if the `postinstall.sh` script is invoked with the `ZSH_CUSTOM` variable set (requires exporting it as Zsh does not forward it to scripts by default), it will create the symlinks to the respective oh-my-zsh custom zsh scripts in the provided path as opposed to `~/.oh-my-zsh/custom`.

The script is safe to run several times as it will skip configuration it has already detected. In fact, it is recommended to periodically re-run it, as it updates plugins and adds symlinks to files added since the last time running the file. By default, the `post-write` hook (which runs after executing a rebase, such as when using `git pull --rebase`) runs `postinstall.sh` meaning that it's sufficient to pull this repository in order to update the dotfile configuration.

