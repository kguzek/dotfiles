DISABLE_AUTO_UPDATE="true"
DISABLE_COMPFIX="true"
ZSH_DISABLE_COMPFIX="true"

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gnzh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
export NVM_LAZY=1
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Cache completions aggressively
autoload -Uz compinit
if [[ "$(uname)" == "Darwin" ]]; then
    comp_last=$(stat -f %m ~/.zcompdump 2>/dev/null || echo 0)
    comp_today=$(date +%j)
    comp_last_day=$(date -r "$comp_last" +%j)
else
    comp_last=$(stat -c %Y ~/.zcompdump 2>/dev/null || echo 0)
    comp_today=$(date +%j)
    comp_last_day=$(date -d "@$comp_last" +%j)
fi

if [[ "$comp_today" == "$comp_last_day" ]]; then
    compinit -C
else
    compinit
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
# [[ ! -r '/home/konrad/.opam/opam-init/init.zsh' ]] || source '/home/konrad/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

export PATH="$PATH:/opt/nvim/bin"
export EDITOR='nvim'
alias vi=nvim

# Lazy-loaded nvm
export NVM_DIR="$HOME/.nvm"

NODE_CMDS=(nvm node npm npx pnpm nvim gemini pm2)

_init_node() {
  unset -f "${NODE_CMDS[@]}"
  local nvm_script_path="$NVM_DIR/nvm.sh"
  if [ -f "$nvm_script_path" ]; then
    source "$nvm_script_path"
  fi
}

for cmd in "${NODE_CMDS[@]}"; do
  eval "$cmd() { _init_node; $cmd \"\$@\" }"
done

# Git post-merge script
gpm() {
  local branch=$(git_current_branch)
  local main_branch=$(git_main_branch)
  if [ "$branch" = "$main_branch" ]; then
    echo "Already on branch $main_branch."
  else
    git fetch
    git pull --rebase # in case the feature branch was rebased via GitHub's UI
    git checkout "$main_branch"
    git pull --rebase
    git branch --delete "$branch" # this should work while the feature branch's origin ref is present
    git remote prune origin # prune it at the end, so deleting doesn't require confirmation
  fi
}

# Git repository clone script
grc() {
  if [ -z "$1" ]; then
    echo "Usage: grc <repo> or <author/repo>"
    return 1
  fi

  local repo="$1"
  local author="kguzek"

  # If input contains a slash, assume it's author/repo
  if [[ "$repo" == */* ]]; then
    author="${repo%%/*}"
    repo="${repo##*/}"
  fi

  git clone "git@github.com:$author/$repo.git" && cd "$repo"
}

# bun completions
[ -s "/home/konrad/.bun/_bun" ] && source "/home/konrad/.bun/_bun"

# direnv hook
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
