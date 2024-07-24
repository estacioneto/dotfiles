#!/usr/bin/env bash

current_dir=$(dirname -- "$(readlink -f "$0")")

# First, check if we're in a tmux session
if [[ -z $TMUX ]]; then
  echo "🚨 Not in a tmux session. Please start a tmux session first."
  exit 1
fi

# Get all tmux sessions
tmux_session=$(tmux list-sessions -F "#{session_name}" | fzf --tmux --reverse --preview "$current_dir"'/tmux_tree.sh {}')

# If no session is selected, exit
if [[ -z $tmux_session ]]; then
  # Print the error message in the stderr
  echo "🚨 No session selected. Exiting now." >&2
  # Ignore the error and exit to avoid tmux showing the script ended with status 1
  exit 0
fi

# Switch to the selected session
tmux switch-client -t "$tmux_session"
