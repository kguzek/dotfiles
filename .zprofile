# Login-only environment setup

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# asdf shims
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

# Coursier
export PATH="$PATH:$HOME/.local/share/coursier/bin"

# Opencode
export PATH="$PATH:$HOME/.opencode/bin"
