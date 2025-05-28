[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if which fzf &> /dev/null; then
  source <(fzf --zsh)
fi

[ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.zsh
[ -f ~/.dotfiles/fzf/setup_completions.zsh ] && source ~/.dotfiles/fzf/setup_completions.zsh

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

  # Replace the current command line with the yarn run command
  print -z "yarn run $selected"
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

chain_rebase() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: chain_rebase BRANCH1 [BRANCH2 [BRANCH3 ...]]"
    return 1
  fi

  # Collect all provided branches
  local branches=("$@")
  local base="master"   # The first branch is rebased onto 'master'

  # Iterate over all branches
  for (( i=1; i<=${#branches[@]}; i++ )); do
    local branch="${branches[$i]}"
    # Prevent empty branch names from causing trouble
    if [[ -z "$branch" ]]; then
      echo "⚠️  Empty branch name detected. Skipping..."
      continue
    fi

    echo "================================================================"
    echo "→ Rebasing branch '$branch' onto '$base' (interactive)"
    echo "================================================================"

    # Check out the current branch
    git checkout "$branch" || return $?

    # Perform an interactive rebase onto the base branch
    git rebase -i "$base"
    if [[ $? -ne 0 ]]; then
      echo
      echo "⚠️  A conflict occurred while rebasing '$branch' onto '$base'."
      echo "   Resolve the conflict in your files, then run:"
      echo "       git rebase --continue"
      echo

      # Figure out which branches are left to process after this one
      local next_index=$((i + 1))
      if [[ $next_index -lt ${#branches[@]} ]]; then
        local remaining=("${branches[@]:$next_index}")
        echo "Once you've successfully continued the rebase, you can resume with:"
        echo "       chain_rebase ${remaining[*]}"
      else
        echo "There are no more branches after '$branch'—you're done once this rebase is resolved."
      fi
      return 1
    fi

    echo
    echo "✅  Rebase of '$branch' onto '$base' succeeded. Now pushing..."
    echo

    # Push the rebased branch with --force-with-lease
    git push --force-with-lease origin "$branch" || return $?

    # The next branch will be rebased on top of the one we just finished
    base="$branch"
  done

  echo
  echo "All done! Every branch has been rebased and pushed."
  echo
}

ocp_docker() {
  # Get the command and the ocp_session_id from the arguments
  if [[ $# -lt 2 ]]; then
    echo "Usage: ocp_docker COMMAND [OCP_SESSION_ID] [ARGS...]"
    return 1
  fi

  local command="$1"
  shift

  local ocp_session_id="$1"
  shift

  # If the command is logs, add the --follow flag and pipe it into tspin
  if [[ "$command" == "logs"  ]] && which tspin &> /dev/null; then
    docker logs one-click-purchase-client-"$ocp_session_id" -f 2>&1 | tspin
    return $?
  fi

  # Execute docker command
  docker "$command" one-click-purchase-client-"$ocp_session_id" "$@"
}
