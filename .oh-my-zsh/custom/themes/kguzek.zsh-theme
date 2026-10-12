# Based on the gnzh theme (which is based on the bira theme)

setopt prompt_subst

() {
  local PR_USER PR_PROMPT PR_HOST

  # Check the UID
  if [[ $UID -eq 0 ]]; then # root
    PR_USER='%F{red}%n%f'
    PR_PROMPT='%F{red}$%f'
  else # normal user
    PR_USER='%F{green}%n%f'
    PR_PROMPT='%F{blue}$%f'
  fi

  # Check if we are on SSH or not
  if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
    PR_HOST='%F{red}%M%f' # SSH
  else
    PR_HOST='%F{green}%m%f' # no SSH
  fi

  local return_code="%(?..%F{red}%? ↵%f)"

  local prefix='%F{blue}#%f'
  local user_host="${PR_USER}%F{cyan}@${PR_HOST}"
  local current_dir="%B%F{blue}%~%f%b"
  local git_branch='$(git_prompt_info)'
  local venv_prompt='$(virtualenv_prompt_info)'

  PROMPT="${prefix} ${venv_prompt}${user_host} ${current_dir} ${git_branch}
$PR_PROMPT "
  RPROMPT="${return_code}"

  ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}‹"
  ZSH_THEME_GIT_PROMPT_SUFFIX="› %f"
  ZSH_THEME_VIRTUALENV_PREFIX="%F{red}("
  ZSH_THEME_VIRTUALENV_SUFFIX=")%f "
}
