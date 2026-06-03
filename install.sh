#!/bin/sh

set -e

if ! command -v zsh >/dev/null 2>&1; then
	echo "Please install zsh before running this script."
	echo "Example:	sudo apt install zsh"
	echo "Or:	sudo dnf install zsh"
	exit 1
fi

REPOS_DIR="$HOME/repos"
SCRIPTS_DIR="$HOME/repos/scripts"

if [ ! -d "$SCRIPTS_DIR" ]; then
  mkdir -p "$REPOS_DIR"
  git clone git@github.com:kguzek/scripts.git "$SCRIPTS_DIR"
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "After updating your default shell to zsh, please log out and log back in, then run postinstall.zsh"

