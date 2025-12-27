#!/usr/bin/env zsh

set -e
setopt nullglob
start_time=$(date +%s.%N)
script_path=${(%):-%x}
script_dir=$(dirname "$script_path")
install_path=$(realpath "$script_dir")

if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "Please set zsh as your default shell before running this script."
  echo "Current default shell: $SHELL"
  echo "If you have already done this, you might need to log out and log back in."
  exit 1
fi

OMZ_CUSTOM_DIR='.oh-my-zsh/custom'
ZSH_CUSTOM="${ZSH_CUSTOM:-"$HOME/$OMZ_CUSTOM_DIR"}"

clone_plugin() {
  local repo=$1
  local repo_name=$(basename "$repo" .git)
  local repo_url="https://github.com/$repo"
  local destination="$ZSH_CUSTOM/plugins/$repo_name"

  if [[ -d "$destination/.git" ]]; then
    echo -n "✓ Plugin $repo_name already exists, checking for updates... "
    (
      cd "$destination" || return
      git fetch --quiet
      LOCAL=$(git rev-parse @)
      REMOTE=$(git rev-parse @{u})
      if [[ $LOCAL != $REMOTE ]]; then
        echo "update available!"
        git pull --ff-only
      else
        echo "up to date!"
      fi
    )
  else
    git clone "$repo_url" "$destination"
  fi
}

clone_plugin "zsh-users/zsh-autosuggestions"
clone_plugin "zsh-users/zsh-syntax-highlighting"

create_symlink() {
  local symlink_target="$1"
  local symlink_path="$2"

  if [[ -L "$symlink_path" ]]; then
    local current_target
    current_target=$(readlink "$symlink_path")

    if [[ "$current_target" == "$symlink_target" ]]; then
      echo "✓ Symlink $symlink_path -> $symlink_target already exists, skipping creation"
      return
    fi
  fi

  # Backup existing file/dir/symlink if it exists
  if [ -e "$symlink_path" ] || [ -L "$symlink_path" ]; then
    local backup_filename="$symlink_path.bak.$(date +%s)"
    mv "$symlink_path" "$backup_filename"
    echo "✓ Backed up $symlink_path to $backup_filename"
  fi

  # Ensure parent directories exist
  mkdir -p "$(dirname "$symlink_path")"

  # Create the symlink
  ln -sn "$symlink_target" "$symlink_path"
  echo "✓ Created symlink: $symlink_path -> $symlink_target"
}

# List of files and directories to symlink
DOTFILES=(.zshrc .zprofile .vimrc .vim .config/nvim)

# Main configurations and run commands
for dotfile in "${DOTFILES[@]}"; do
  create_symlink "$install_path/$dotfile" "$HOME/$dotfile"
done

# Additional zsh configuration files, such as global aliases
for custom_file in "$OMZ_CUSTOM_DIR"/*.zsh; do
  # Allow configuration of a different OMZ custom path via ZSH_CUSTOM
  create_symlink "$install_path/$custom_file" "$ZSH_CUSTOM/$(basename "$custom_file")"
done

# Git hooks (for automatic reconfiguration on pull)
for hook_file in "$install_path/hooks"/*.sh; do
  local hook_name=$(basename "$hook_file" .sh)
  create_symlink "$hook_file" "$install_path/.git/hooks/$hook_name"
done

end_time=$(date +%s.%N)
elapsed=$(echo "($end_time - $start_time)" | bc -l)
printf "✓ Configuration complete in %.3f s!\n" "$elapsed"

