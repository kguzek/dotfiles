#!/bin/bash

set -e

if ! command -v zsh >/dev/null 2>&1; then
	echo "Please install zsh before running this script."
	echo "Example:	sudo apt install zsh"
	echo "Or:	sudo dnf install zsh"
	exit 1
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ "$(basename "$SHELL")" != "zsh" ]; then
	echo "Please set zsh as your default shell."
	echo "Current default shell: $SHELL"
	exit 1
fi

source ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

cd
git checkout dotfiles
source ~/.zshrc
