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

# Local scripts
LOCAL_SCRIPTS_PATH="$HOME/scripts/$(hostname -s)"
if [ -d "$LOCAL_SCRIPTS_PATH" ]; then
  export PATH="$LOCAL_SCRIPTS_PATH:$PATH"
fi

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && command -v start-hyprland >/dev/null; then
  exec start-hyprland
fi
