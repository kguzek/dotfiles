#!/usr/bin/env zsh

set -e
setopt nullglob
start_time=$(date +%s.%N)
script_path=${(%):-%x}
script_dir=$(dirname "$script_path")
install_path=$(realpath "$script_dir")

# Output formatting
if [[ -t 1 ]]; then
  C_RESET=$'\e[0m'
  C_GREEN=$'\e[32m'
  C_YELLOW=$'\e[33m'
  C_BLUE=$'\e[34m'
  C_RED=$'\e[31m'
else
  C_RESET=''
  C_GREEN=''
  C_YELLOW=''
  C_BLUE=''
  C_RED=''
fi

log_step() {
  local level="$1"
  local message="$2"
  local prefix color

  case "$level" in
    added)
      prefix='[+]'
      color="$C_GREEN"
      ;;
    complete)
      prefix='[✓]'
      color="$C_GREEN"
      ;;
    backup)
      prefix='[!]'
      color="$C_YELLOW"
      ;;
    present)
      prefix='[=]'
      color="$C_BLUE"
      ;;
    failed)
      prefix='[x]'
      color="$C_RED"
      ;;
    *)
      prefix='[?]'
      color="$C_YELLOW"
      ;;
  esac

  printf '%b%s%b %s\n' "$color" "$prefix" "$C_RESET" "$message"
}

run_or_fail() {
  local description="$1"
  shift

  if "$@"; then
    return 0
  fi

  log_step failed "$description"
  return 1
}

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
    (
      cd "$destination" || return 1
      run_or_fail "Failed to fetch updates for plugin $repo_name" git fetch --quiet

      local local_ref remote_ref
      local_ref=$(git rev-parse @)
      remote_ref=$(git rev-parse @{u})

      if [[ $local_ref != $remote_ref ]]; then
        run_or_fail "Failed to update plugin $repo_name" git pull --ff-only
        log_step added "Updated plugin $repo_name"
      else
        log_step present "Plugin $repo_name already configured (up to date)"
      fi
    )
  else
    run_or_fail "Failed to clone plugin $repo_name" git clone "$repo_url" "$destination"
    log_step added "Added plugin $repo_name"
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
      log_step present "Symlink already configured: $symlink_path -> $symlink_target"
      return
    fi
  fi

  # Backup existing file/dir/symlink if it exists
  if [ -e "$symlink_path" ] || [ -L "$symlink_path" ]; then
    local backup_filename="$symlink_path.bak.$(date +%s)"
    run_or_fail "Failed to back up $symlink_path" mv "$symlink_path" "$backup_filename"
    log_step backup "Backed up existing path: $symlink_path -> $backup_filename"
  fi

  # Ensure parent directories exist
  run_or_fail "Failed to create parent directory for $symlink_path" mkdir -p "$(dirname "$symlink_path")"

  # Create the symlink
  run_or_fail "Failed to create symlink: $symlink_path -> $symlink_target" ln -sn "$symlink_target" "$symlink_path"
  log_step added "Created symlink: $symlink_path -> $symlink_target"
}

# List of files and directories to symlink
DOTFILES=(.zshrc .zprofile .zshenv .vimrc .vim .config/nvim .config/ghostty .config/fontconfig .config/hypr .config/waybar)

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
  hook_name=$(basename "$hook_file" .sh)
  create_symlink "$hook_file" "$install_path/.git/hooks/$hook_name"
done

end_time=$(date +%s.%N)
elapsed=$(($end_time - $start_time))
printf -v elapsed_fmt '%.3f' "$elapsed"
log_step complete "Configuration complete in ${elapsed_fmt}s"
