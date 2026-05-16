#!/usr/bin/env zsh

set -e
start_time=$(date +%s.%N)

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

if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "Please set zsh as your default shell before running this script."
  echo "Current default shell: $SHELL"
  echo "If you have already done this, you might need to log out and log back in."
  exit 1
fi

setopt nullglob
script_path=${(%):-%x}
script_dir=$(dirname "$script_path")
install_path=$(realpath "$script_dir")
DRY_RUN=false
FORCE=false

print_help() {
  cat <<'EOF'
Usage: ./postinstall.zsh [options]

Options:
  --dry-run      Preview actions without changing files.
  --force        Skip creating backups only for conflicting symlinks.
                 Real files/directories are still backed up.
  -h, --help     Show this help message and exit.
EOF
}

OMZ_CUSTOM_DIR='.oh-my-zsh/custom'
ZSH_CUSTOM="${ZSH_CUSTOM:-"$HOME/$OMZ_CUSTOM_DIR"}"

# Plugins to clone/update into $ZSH_CUSTOM/plugins
PLUGIN_REPOS=(zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting)

# List of files and directories to symlink
DOTFILES=(.zshrc .zprofile .zshenv .vimrc .vim .config/nvim .config/ghostty .config/fontconfig .config/hypr .config/waybar)

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --force)
      FORCE=true
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      print_help
      exit 1
      ;;
  esac
done

log_step() {
  local level="$1"
  local message="$2"
  local prefix color

  case "$level" in
    changed)
      prefix='[+]'
      color="$C_GREEN"
      ;;
    complete)
      prefix='[✓]'
      color="$C_GREEN"
      ;;
    warn)
      prefix='[!]'
      color="$C_YELLOW"
      ;;
    unchanged)
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

is_dry_run() {
  [[ "$DRY_RUN" == true ]]
}

is_force() {
  [[ "$FORCE" == true ]]
}

run_step() {
  local action="$1"
  local level="$2"
  local success_message="$3"
  shift 3

  if is_dry_run; then
    log_step "$level" "Would $action"
    return 0
  fi

  if "$@"; then
    if [ -n "$success_message" ]; then
      log_step "$level" "$success_message"
    fi
    return 0
  fi

  log_step failed "Failed to $action"
  return 1
}

ensure_plugin() {
  local repo=$1
  local repo_name=$(basename "$repo" .git)
  local repo_url="https://github.com/$repo"
  local destination="$ZSH_CUSTOM/plugins/$repo_name"

  if [[ -d "$destination/.git" ]]; then
    (
      cd "$destination" || return 1
      # check for updates in dry run as well
      DRY_RUN=false run_step "fetch updates for plugin $repo_name" unchanged "Checking for updates for plugin $repo_name" git fetch --quiet

      local local_ref remote_ref
      local_ref=$(git rev-parse @)
      remote_ref=$(git rev-parse @{u})

      if [[ $local_ref != $remote_ref ]]; then
        run_step "update plugin $repo_name" changed "Updated plugin $repo_name" git pull --ff-only
      else
        log_step unchanged "Plugin $repo_name already configured (up to date)"
      fi
    )
  else
    run_step "clone plugin $repo_name" changed "Added plugin $repo_name" git clone "$repo_url" "$destination"
  fi
}

create_symlink() {
  local symlink_target="$1"
  local symlink_path="$2"

  symlink_exists() {
    [ -L "$symlink_path" ]
  }

  if symlink_exists; then
    local current_target
    current_target=$(readlink "$symlink_path")

    if [[ "$current_target" == "$symlink_target" ]]; then
      log_step unchanged "Symlink already configured: $symlink_path -> $symlink_target"
      return
    fi
  fi

  # Handle existing file/dir/symlink
  if [ -e "$symlink_path" ] || symlink_exists; then
    if is_force && symlink_exists; then
      run_step "remove conflicting symlink $symlink_path" warn "Removed conflicting symlink: $symlink_path" rm "$symlink_path"
    else
      local backup_filename="$symlink_path.bak.$(date +%s)"
      run_step "back up $symlink_path" warn "Backed up existing path: $symlink_path -> $backup_filename" mv "$symlink_path" "$backup_filename"
    fi
  fi

  # Ensure parent directories exist
  parent_dir=$(dirname "$symlink_path")
  if [ ! -d "$parent_dir" ]; then
    run_step "create directory $parent_dir" changed "Created directory $parent_dir" mkdir -p "$parent_dir"
  fi

  # Create the symlink
  run_step "create symlink: $symlink_path -> $symlink_target" changed "Created symlink: $symlink_path -> $symlink_target" ln -sn "$symlink_target" "$symlink_path"
}

for plugin in "${PLUGIN_REPOS[@]}"; do
  ensure_plugin "$plugin"
done

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
for hook_path in "$install_path/hooks"/*.sh; do
  hook_file=$(basename "$hook_path")
  hook_name=$(basename "$hook_file" .sh)
  create_symlink "../../hooks/$hook_file" "$install_path/.git/hooks/$hook_name"
done

end_time=$(date +%s.%N)
elapsed=$(($end_time - $start_time))
printf -v elapsed_fmt '%.3f' "$elapsed"
if is_dry_run; then
  log_step complete "Dry run complete in ${elapsed_fmt}s (no filesystem changes made)"
else
  log_step complete "Configuration complete in ${elapsed_fmt}s"
fi
