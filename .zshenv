typeset -U path

_add_to_path() {
  if [ -d "$1" ]; then
    path+=("$1")
  fi
}

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
LOCAL_SCRIPTS_ROOT="$HOME/repos/scripts"
_add_to_path "$LOCAL_SCRIPTS_ROOT/$(hostname -s)"
_add_to_path "$LOCAL_SCRIPTS_ROOT/common"

LOCAL_ZSHENV_PATH="$HOME/.zshenv.local"
if [ -f "$LOCAL_ZSHENV_PATH" ]; then
  source "$LOCAL_ZSHENV_PATH"
fi

export PATH
