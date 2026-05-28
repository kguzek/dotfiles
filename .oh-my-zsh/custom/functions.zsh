# Git post-merge script
function gpm() {
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
function grc() {
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
