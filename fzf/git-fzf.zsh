FZF_GIT_PREVIEW_DEFAULT_OPTS="
  --preview-window='right:60%'
"

FZF_GIT_DEFAULT_OPTS="
  --bind='alt-k:preview-up,alt-p:preview-up'
  --bind='alt-j:preview-down,alt-n:preview-down'
  --bind='ctrl-r:toggle-all'
  --bind='ctrl-s:toggle-sort'
  --bind='?:toggle-preview'
  --bind='alt-w:toggle-preview-wrap'
  $FZF_GIT_PREVIEW_DEFAULT_OPTS
"

FZF_GIT_PREVIEW_BRANCH_OPTS="
  $FZF_GIT_DEFAULT_OPTS
  --preview='git log --color=always --oneline --graph --decorate {}'
"

FZF_GIT_PREVIEW_FILE_DIFF_OPTS="
  $FZF_GIT_DEFAULT_OPTS
  --preview='if git diff --exit-code --quiet {2}; then (bat --style=numbers,header --color=always --theme ansi --paging=never {2} || cat {2}); else git diff --color=always {2}; fi | less -R'
"

FZF_GIT_PREVIEW_FILE_DIFF_OPTS="
  $FZF_GIT_DEFAULT_OPTS
  --preview='bat --style=numbers,header --color=always --theme ansi --paging=never {} || cat {}'
"

_fzf_git_list_all_branches() {
  git branch -a | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | \
    sed 's|remotes/||' | \
    sort | uniq
}

_fzf_complete_git_tag() {
  _fzf_complete "$FZF_GIT_PREVIEW_BRANCH_OPTS" "$@" < <(
    git tag | sort
  )
}

_fzf_git_list_changes() {
  git status --porcelain | sort
}

_fzf_complete_git() {
  local tokens git_command
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins
  tokens=(${(z)LBUFFER})

  if [ ${#tokens} -le 2 ]; then
    return
  fi

  git_command=${tokens[2]}
  case "$git_command" in
    switch|rebase|branch|s)
      _fzf_complete "$FZF_GIT_PREVIEW_BRANCH_OPTS" "$@" < <(
        _fzf_git_list_all_branches
      )
      return
      ;;
    checkout|co)
      # In case of checkout, if -- is not present, autocomplete with branch. If it's present, autocomplete with file

      if [[ "${tokens[@]}" == *"--"* ]]; then
        _fzf_complete "$FZF_GIT_PREVIEW_FILE_OPTS" "$@" < <(
          git ls-files | sort
        )
      else
        _fzf_complete "$FZF_GIT_PREVIEW_BRANCH_OPTS" "$@" < <(
          _fzf_git_list_all_branches
        )
      fi
      return
      ;;
    tag)
      _fzf_complete_git_tag "$@"
      return
      ;;
    add)
      _fzf_complete "$FZF_GIT_PREVIEW_FILE_DIFF_OPTS" "$@" < <(
        _fzf_git_list_changes
      )
      return
      ;;
  esac
}
