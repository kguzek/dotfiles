#!/usr/bin/env zsh

set -e

export UPDATING_DOTFILES=true
SCRIPTS_REPO_PATH="$HOME/repos/scripts"
PROGRAM_NAME="$(basename $0)"

GIT_SERVER_HOST='git.guzek.uk'

typeset -U path
path+=("$SCRIPTS_REPO_PATH/common")
for required_command in log-status time-script; do
  if command -v "$required_command" >/dev/null 2>&1; then
    continue
  fi

  echo "[x] Missing required command: $required_command" >&2
  echo "[x] Install the scripts repo and ensure $SCRIPTS_REPO_PATH/common is on PATH:" >&2
  echo >&2
  echo 'mkdir -p ~/repos' >&2
  echo "git clone https://$GIT_SERVER_HOST/kguzek/scripts.git $SCRIPTS_REPO_PATH" >&2
  exit 1
done

if [ "$(basename "$SHELL")" != "zsh" ]; then
  log-status failed "Please set zsh as your default shell before running this script."
  log-status failed "Current default shell: $SHELL"
  log-status info "If you have already done this, you might need to log out and log back in. Otherwise, consult chsh(1)." >&2
  exit 1
fi

time-script --start

setopt nullglob
script_path=${(%):-%x}
script_dir=$(dirname "$script_path")
install_path=$(realpath "$script_dir")
DOTFILES_UPDATE_SENTINEL=$(git -C "$install_path" rev-parse --path-format=absolute --git-path postinstall-updating)
touch "$DOTFILES_UPDATE_SENTINEL"
trap 'rm -f "$DOTFILES_UPDATE_SENTINEL"' EXIT
DRY_RUN=false
FORCE=false
SKIP_SELF_UPDATE=false

print_help() {
  cat <<EOF
Usage: $PROGRAM_NAME [OPTION]...

Options:
  -n, --dry-run            preview actions without changing files
  -f, --force              skip creating backups only for conflicting symlinks (real files/directories are still backed up)
  -s, --skip-self-update   skip updating the dotfiles repo itself
  -h, --help               show this help message and exit
EOF
}

OMZ_CUSTOM_DIR='.oh-my-zsh/custom'
ZSH="${ZSH:-"$HOME/.oh-my-zsh"}"
ZSH_CUSTOM="${ZSH_CUSTOM:-"$HOME/$OMZ_CUSTOM_DIR"}"

# Plugins to clone/update into $ZSH_CUSTOM/plugins
PLUGIN_REPOS=(
  "$GIT_SERVER_HOST/kguzek/zsh-worktrunk"
  'github.com/zsh-users/zsh-autosuggestions'
  'github.com/zsh-users/zsh-syntax-highlighting'
)

# List of files and directories to symlink
DOTFILES=(.zshrc .zprofile .zshenv .vimrc .vim)

# Each directory listed below will create a symlink to each of its children
DOTFILE_DIRS=(.config)

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    --force)
      FORCE=true
      ;;
    --skip-self-update)
      SKIP_SELF_UPDATE=true
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

is_dry_run() {
  [[ "$DRY_RUN" == true ]]
}

is_force() {
  [[ "$FORCE" == true ]]
}

is_skip_self_update() {
  [[ "$SKIP_SELF_UPDATE" == true ]]
}

run_step() {
  local action="$1"
  local level="$2"
  local success_message="$3"
  shift 3

  if is_dry_run; then
    log-status "$level" "Would $action"
    return 0
  fi

  if "$@"; then
    if [ -n "$success_message" ]; then
      log-status "$level" "$success_message"
    fi
    return 0
  fi

  log-status failed "Failed to $action"
  return 1
}

update_git_repo() {
  local destination="$1"

  (
    cd "$destination" || return 1
    local remote_name="$(git remote | head -1)"
    local repo_url="$(git remote get-url "$remote_name")"
    local subject="$(basename "$repo_url" .git)"
    # Check for updates in dry run as well so the status is accurate.
    log-status info "Checking for updates for $subject"
    if ! git fetch --quiet; then
      log-status failed "Failed to fetch updates for $subject"
    fi

    local local_ref remote_ref
    local_ref=$(git rev-parse @)
    remote_ref=$(git rev-parse @{u})

    if [[ $local_ref != $remote_ref ]]; then
      run_step "update $subject" changed "Updated $subject" git pull --ff-only
    else
      log-status unchanged "Repository $subject is up to date"
    fi
  )
}

ensure_plugin() {
  local repo="$1"
  local repo_name=$(basename "$repo" .git)
  local destination="$ZSH_CUSTOM/plugins/$repo_name"
  local repo_url="https://$1.git"

  if [[ -d "$destination/.git" ]]; then
    update_git_repo "$destination"
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
      log-status unchanged "Symlink already configured: $symlink_path -> $symlink_target"
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

create_symlinks() {
  for dotfile in "$@"; do
    create_symlink "$install_path/$dotfile" "$HOME/$dotfile"
  done
}

queue_job() {
  ("$@") &
  update_job_pids+=($!)
  update_job_descriptions+=("$*")
}

wait_for_jobs() {
  local failed=0

  for i in {1..${#update_job_pids[@]}}; do
    if ! wait "${update_job_pids[$i]}"; then
      log-status failed "Failed to process ${update_job_descriptions[$i]}"
      failed=1
    fi
  done

  return $failed
}

update_job_pids=()
update_job_descriptions=()

if ! is_skip_self_update; then
  queue_job update_git_repo "$install_path"
fi

queue_job update_git_repo "$ZSH"
queue_job update_git_repo "$SCRIPTS_REPO_PATH"

for plugin in "${PLUGIN_REPOS[@]}"; do
  queue_job ensure_plugin "$plugin"
done

if ! wait_for_jobs; then
  exit 1
fi

# Main configurations and run commands
create_symlinks "${DOTFILES[@]}"

for dotfile_dir in "${DOTFILE_DIRS[@]}"; do
  items=("$script_dir/$dotfile_dir"/*)
  basenames=("${items[@]##*/}")
  targets=("${basenames[@]/#/$dotfile_dir/}")

  create_symlinks "${targets[@]}"
done

# Additional zsh configuration files, such as global aliases
for custom_file in "$install_path/$OMZ_CUSTOM_DIR"/*; do
  # Allow configuration of a different OMZ custom path via ZSH_CUSTOM
  create_symlink "$custom_file" "$ZSH_CUSTOM/$(basename "$custom_file")"
done

# Git hooks (for automatic reconfiguration on pull)
for hook_path in "$install_path/hooks"/*.sh; do
  hook_file=$(basename "$hook_path")
  hook_name=$(basename "$hook_file" .sh)
  create_symlink "../../hooks/$hook_file" "$install_path/.git/hooks/$hook_name"
done

if is_dry_run; then
  log-status complete "Dry run complete in $(time-script --end)s (no filesystem changes made)"
else
  log-status complete "Configuration complete in $(time-script --end)s"
fi
