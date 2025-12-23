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
