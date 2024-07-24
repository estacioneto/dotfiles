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

# Perform cd on subdirectories
cds () {
  selected=$(fd -t d -d 5 --no-ignore --hidden -E .git . | run_fzf "$@")

  if [[ -z "$selected" ]]; then
    echo "🚨 No directory selected"
    return
  fi

  cd "$selected" || return
}

tmuxs() {
  ~/.local/share/tmux/bin/sessionizer.sh --git
}

export EDITOR=nvim
