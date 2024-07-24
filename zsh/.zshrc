# autoload -Uz compinit && compinit

calendar_info() {
  echo "%F{225}{ %D{%a %b %d %H:%M} }%f"
}

user_info() {
  echo "%F{119}%n%f@%F{184}%m%f"
}

directory_info() {
  echo "%F{87}[%~]%f"
}

# Add git branch if its present to PS1
parse_git_branch() {
 echo `git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
}

print_git_branch() {
  branch=$(parse_git_branch)
  if [[ -n "$branch" ]]; then
    echo "{ GIT: $branch }"
  fi
}

git_info() {
  echo "%F{8}\$(print_git_branch)%f"
}

NEW_LINE=$'\n'

setopt PROMPT_SUBST
export PROMPT="$(calendar_info) $(user_info)%F{white}:%f$(directory_info)${NEW_LINE}$(git_info):\$ "

export LANG=en_US.UTF-8

source ~/.zprofile

eval "$('/opt/homebrew/bin/brew' shellenv)"
