#!/bin/bash

set -e

if [ "$(basename "$SHELL")" != "zsh" ]; then
	echo "Please set zsh as your default shell before running this script."
	echo "Current default shell: $SHELL"
	echo "If you have already done this, you might need to log out and log back in."
	exit 1
fi

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

for file in .zshrc .vimrc .vim; do
	HOME_FILE="$HOME/$file"
	if [ -f "$HOME_FILE" ]; then
		mv "$HOME_FILE" "$HOME_FILE.bak"
	fi
	ln -sn "$(pwd)/$file" "$HOME_FILE"
done
source ~/.zshrc

