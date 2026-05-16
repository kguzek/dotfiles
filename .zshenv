VOLTA_HOME="$HOME/.volta"
if [ -d "$VOLTA_HOME" ]; then
  export VOLTA_HOME
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

CARGO_ENV="$HOME/.cargo/env"
if [ -f "$CARGO_ENV" ]; then
  source "$CARGO_ENV"
fi
