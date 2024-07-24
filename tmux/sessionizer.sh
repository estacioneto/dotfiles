#!/usr/bin/env bash

# See https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer

# Usage:
# tmux-sessionizer --git
# tmux-sessionizer --root
# tmux-sessionizer --sub-dirs

# Extracting parameters

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -g | --git)
    git_dirs=true
    shift
    ;;
  -r | --root)
    root_dirs=true
    shift
    ;;
  -s | --sub-dirs)
    sub_dirs=true
    shift
    ;;
  *)
    shift
    ;;
  esac
done

exclude_dirs=(
  Applications
  Desktop
  Documents
  Downloads
  Library
  Movies
  Music
  Pictures
  Public
)

# Map exclude_dirs to a -E pattern
# See https://www.shellcheck.net/wiki/SC2207
exclude_dirs_patterns=()
IFS=" " read -r -a exclude_dirs_patterns <<<"$(printf -- '-E %s ' "${exclude_dirs[@]}")"

# In case of git dirs, use fd to find all git dirs
if [[ $git_dirs ]]; then
  selected=$(
    fd -t d -d 3 --no-ignore --hidden "${exclude_dirs_patterns[*]}" \
      .git ~/ | xargs -I {} dirname {} | fzf
  )
elif [[ $root_dirs ]]; then
  echo '⚠️ To be implemented'
  exit 1
else
  echo '⚠️ To be implemented'
  exit 1
fi

if [[ -z $selected ]]; then
  exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t "$selected_name"
