#!/bin/bash

if ! which tmux &> /dev/null; then
  echo "💿 Installing Tmux (https://github.com/tmux/tmux)..."
  brew install tmux && echo "✅ [Dependencies] Tmux installed" || exit 1
else
  echo "⏭️  Tmux already installed!"
fi
