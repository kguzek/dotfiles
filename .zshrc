DISABLE_COMPFIX="true"
ZSH_DISABLE_COMPFIX="true"

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gnzh"

zstyle ':omz:update' mode disabled  # disable automatic updates

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

export NVM_LAZY=1

# Vi mode
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_INSERT=5

# See https://github.com/zsh-users/zsh-autosuggestions#suggestion-strategy
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)

plugins=(git asdf colored-man-pages vi-mode zsh-worktrunk zsh-autosuggestions zsh-syntax-highlighting)

# Cache completions aggressively
autoload -Uz compinit
comp_last=$(stat -c %Y ~/.zcompdump 2>/dev/null || echo 0)
comp_today=$(date +%j)
comp_last_day=$(date -d "@$comp_last" +%j)

if [[ "$comp_today" == "$comp_last_day" ]]; then
    compinit -C
else
    compinit
fi

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

# Lazy-loaded nvm
export NVM_DIR="$HOME/.nvm"

NODE_CMDS=(nvm node npm npx pnpm nvim gemini pm2)

_init_node() {
  unset -f "${NODE_CMDS[@]}" 2>/dev/null
  local nvm_script_path="$NVM_DIR/nvm.sh"
  if [ -f "$nvm_script_path" ]; then
    source "$nvm_script_path"
  fi
}

for cmd in "${NODE_CMDS[@]}"; do
  if command -v $cmd >/dev/null; then
    eval "$cmd() { _init_node; $cmd \"\$@\" }"
  fi
done

# Superfile cd-exit
if command -v spf >/dev/null; then
  spf() {
      os=$(uname -s)

      # Linux
      if [[ "$os" == "Linux" ]]; then
          export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
      fi

      # macOS
      if [[ "$os" == "Darwin" ]]; then
          export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
      fi

      command spf "$@"

      [ ! -f "$SPF_LAST_DIR" ] || {
          . "$SPF_LAST_DIR"
          rm -f -- "$SPF_LAST_DIR" > /dev/null
      }
  }
fi

# script/function completions
compdef _git gclr=git-clone

# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# direnv hook
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# fzf completions
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# worktrunk completions
if command -v wt >/dev/null 2>&1; then
  source <(command wt config shell init zsh)
fi

# Forgejo CLI completions
if command -v fj >/dev/null 2>&1; then
  source <(fj completion zsh)
fi

# Custom functions
for custom_function in "$ZSH_CUSTOM/functions"/*; do
  autoload -U "${custom_function:t}"
done

LOCAL_ZSHRC_PATH="$HOME/.zshrc.local"
if [ -f "$LOCAL_ZSHRC_PATH" ]; then
  source "$LOCAL_ZSHRC_PATH"
fi

