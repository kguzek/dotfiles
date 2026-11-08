# Cross-environment shell setup
 
typeset -U path

_add_to_path() {
  if [ -d "$1" ]; then
    path+=("$1")
  fi
}

DOTFILES_PATH="${$(readlink "$HOME/.zshrc"):h}"
LOCAL_SCRIPTS_PATH="${DOTFILES_PATH:h}/scripts"

VOLTA_HOME="$HOME/.volta"
if [ -d "$VOLTA_HOME" ]; then
  export VOLTA_HOME
  export VOLTA_FEATURE_PNPM=1
  path+=("$VOLTA_HOME/bin")
fi

CARGO_ENV="$HOME/.cargo/env"
if [ -f "$CARGO_ENV" ]; then
  source "$CARGO_ENV"
fi

_add_to_path "$HOME/.local/bin"

# Local scripts
if [ -n "$DOTFILES_PATH" ]; then
  _add_to_path "$DOTFILES_PATH/bin"
fi

if [ -n "$LOCAL_SCRIPTS_PATH" ]; then
  _add_to_path "$LOCAL_SCRIPTS_PATH/$(hostname -s)"
  _add_to_path "$LOCAL_SCRIPTS_PATH/common"
fi

LOCAL_ZSHENV_PATH="$HOME/.zshenv.local"
if [ -f "$LOCAL_ZSHENV_PATH" ]; then
  source "$LOCAL_ZSHENV_PATH"
fi

export PATH
