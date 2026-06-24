# Login-only environment setup

typeset -U path

_add_to_path() {
  if [ -d "$1" ]; then
    path+=("$1")
  fi
}

# Homebrew
HOMEBREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
if [ -e "$HOMEBREW_PATH" ]; then
	eval "$("$HOMEBREW_PATH" shellenv)"
fi

# asdf shims
_add_to_path "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
_add_to_path "$ANDROID_HOME/platform-tools"

# Coursier
_add_to_path "$HOME/.local/share/coursier/bin"

# Opencode
_add_to_path "$HOME/.opencode/bin"

# Snap
_add_to_path "/snap/bin"

# Bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  path+=("$BUN_INSTALL/bin")
fi

# pnpm
PNPM_HOME="$HOME/.local/share/pnpm"
if [ -d "$PNPM_HOME" ]; then
  export PNPM_HOME
  # pnpm v10 uses "$PNPM_HOME" as the binary container, but v11 uses a `bin` subdirectory
  # including both because different projects use different version of pnpm
  path+=("$PNPM_HOME" "$PNPM_HOME/bin")
fi

# Go
GOPATH="$HOME/go"
if [ -d "$GOPATH" ]; then
  export GOPATH
  export GOBIN="$GOPATH/bin"
  path+=("$GOBIN")
fi

# Ruby
RUBY_GEM_PATH="$HOME/.local/share/gem/ruby"
if [ -d "$RUBY_GEM_PATH" ]; then
  path+=("$RUBY_GEM_PATH"/*/bin(N))
fi

LOCAL_ZPROFILE_PATH="$HOME/.zprofile.local"
if [ -f "$LOCAL_ZPROFILE_PATH" ]; then
  source "$LOCAL_ZPROFILE_PATH"
fi

export PATH

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && command -v start-hyprland >/dev/null; then
  exec start-hyprland
fi
