[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if which fzf &> /dev/null; then
  source <(fzf --zsh)
fi

[ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.zsh

AUTO_SUGGESTIONS=/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f $AUTO_SUGGESTIONS ] && source $AUTO_SUGGESTIONS

INTEL_AUTO_SUGGESTIONS=/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f $INTEL_AUTO_SUGGESTIONS ] && source $INTEL_AUTO_SUGGESTIONS

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.zsh
fpath=(~/.zsh "$fpath")
autoload -Uz compinit && compinit

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

# Add to old commit
git_add_to_old() {
  COMMIT=$1
  shift
  git commit --fixup="$COMMIT" "$@" && git rebase --interactive --autosquash "$COMMIT"^ "$@"
}

run_fzf () {
  fzf --reverse "$([[ -n "$TMUX" ]] && echo '--tmux')" "$@"
}

fy () {
  # Use fzf to execute yarn scripts
  if [[ ! -f "package.json" ]]; then
    echo "🚨 No package.json found"
    return
  fi

  selected=$(jq -r '.scripts | keys[]' < package.json | run_fzf "$@")

  if [[ -z "$selected" ]]; then
    echo "🚨 No script selected"
    return
  fi

  yarn run "$selected"
}

tmuxs() {
  ~/.local/share/tmux/bin/sessionizer.sh --git
}

export EDITOR=nvim
