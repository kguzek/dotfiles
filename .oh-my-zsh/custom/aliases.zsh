alias df='df --human-readable --local -x tmpfs -x devtmpfs -x squashfs'
alias gfp='git fetch --prune'
alias gdc='git diff --cached'
alias gpt='git push --follow-tags'
alias ls='ls --color=auto'
alias get="curl --fail --no-progress-meter --location --write-out '\n'"
alias rsync="rsync --archive --verbose --exclude=.DS_Store"
alias ud='~/repos/dotfiles/postinstall.zsh'
alias mip='get ifconfig.me'
alias grbim='git rebase --interactive $(git_main_branch)'
alias grpo='git remote prune origin'
