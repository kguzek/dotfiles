# Login-only environment setup

# Homebrew
HOMEBREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
if [ -e "$HOMEBREW_PATH" ]; then
	eval "$("$HOMEBREW_PATH" shellenv)"
fi

# asdf shims
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

# Coursier
export PATH="$PATH:$HOME/.local/share/coursier/bin"

# Opencode
export PATH="$PATH:$HOME/.opencode/bin"

# Snap
export PATH="$PATH:/snap/bin"

# Bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# pnpm
PNPM_HOME="$HOME/.local/share/pnpm"
if [ -d "$PNPM_HOME" ]; then
  export PNPM_HOME
  case ":$PATH:" in
    *":$PNPM_HOME/bin:"*) ;;
    *) export PATH="$PNPM_HOME/bin:$PATH" ;;
  esac
fi

# Go
GOPATH="$HOME/go"
if [ -d "$GOPATH" ]; then
  export GOPATH
  export GOBIN="$GOPATH/bin"
  export PATH="$GOBIN:$PATH"
fi

# Ruby
RUBY_GEM_PATH="$HOME/.local/share/gem/ruby"
if [ -d "$RUBY_GEM_PATH" ]; then
  RUBY_GEM_BIN_PATH=("$RUBY_GEM_PATH"/*/bin)
  if [ -d "$RUBY_GEM_BIN_PATH" ]; then
    export PATH="$RUBY_GEM_BIN_PATH:$PATH"
  fi
fi

# Local scripts
LOCAL_SCRIPTS_PATH="$HOME/repos/scripts/$(hostname -s)"
if [ -d "$LOCAL_SCRIPTS_PATH" ]; then
  export PATH="$LOCAL_SCRIPTS_PATH:$PATH"
fi

LOCAL_ZPROFILE_PATH="$HOME/.zprofile.local"
if [ -f "$LOCAL_ZPROFILE_PATH" ]; then
  source "$LOCAL_ZPROFILE_PATH"
fi

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && command -v start-hyprland >/dev/null; then
  exec start-hyprland
fi
