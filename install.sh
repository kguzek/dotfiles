#!/bin/sh

set -e

if ! command -v zsh >/dev/null 2>&1; then
	echo 'Please install zsh before running this script. Try one of the following commands, depending on your system:' >&2
	echo '# Arch Linux, Omarchy, Manjaro or similar' >&2
	echo 'sudo pacman -S zsh' >&2
	echo '# Debian, Ubuntu, Raspberry Pi OS or similar' >&2
	echo 'sudo apt update && sudo apt install zsh' >&2
	echo '# Fedora, CentOS, RHEL or similar' >&2
	echo 'sudo dnf install zsh' >&2
	exit 1
fi

REPOS_DIR="$HOME/repos"
SCRIPTS_DIR="$REPOS_DIR/scripts"
GIT_SERVER_HOST='git.guzek.uk'

if [ ! -d "$SCRIPTS_DIR" ]; then
  mkdir -p "$REPOS_DIR"
  git clone "https://$GIT_SERVER_HOST/kguzek/scripts.git" "$SCRIPTS_DIR"
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo 'After updating your default shell to zsh, please log out and log back in, then run postinstall.zsh'

