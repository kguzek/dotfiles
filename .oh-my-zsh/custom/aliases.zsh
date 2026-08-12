# default options for common commands
alias ls='ls --color=auto'
alias df='df --human-readable --local -x tmpfs -x devtmpfs -x squashfs'
alias rsync='rsync --archive --verbose --exclude=.DS_Store'
alias glow='glow --pager'

# custom commands and wrappers
alias ud='~/repos/dotfiles/postinstall.zsh'         # Update Dotfiles
alias get="curl --fail --location --write-out '\n'" # perform http GET
alias mip='get ifconfig.me'                         # obtain My IP address
alias wts='wt switch'                               # WorkTrunk Switch

# custom git subcommand aliases
alias gfp='git fetch --prune'
alias gdc='git diff --cached'
alias gt='git tag'
alias gtd='git tag --delete'
alias gpt='git push --follow-tags'
alias grpo='git remote prune origin'
alias grbim='git rebase --interactive $(git_main_branch)'
