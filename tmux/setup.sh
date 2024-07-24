#!/bin/bash

if ! which tmux &> /dev/null; then
  echo "💿 Installing Tmux (https://github.com/tmux/tmux)..."
  brew install tmux && echo "✅ [Dependencies] Tmux installed" || exit 1
else
  echo "⏭️  Tmux already installed!"
fi

current_dir=$(dirname -- "$(readlink -f "$0")")

if [ ! -L "$HOME"/.tmux.conf ]; then
  echo "🔗 Linking .tmux.conf..."
  ln -s "$current_dir"/.tmux.conf "$HOME"/.tmux.conf && echo "✅ .tmux.conf linked" || exit 1
else
  echo "⏭️  .tmux.conf already exists!"
fi

sessionizer_path="$HOME"/.local/share/tmux/bin/sessionizer.sh

if [ ! -L "$sessionizer_path" ]; then
  echo "🔗 Linking Tmux sessionizer..."

  sessionizer_dir=$(dirname -- "$sessionizer_path")
  [ ! -d "$sessionizer_dir" ] && mkdir -p "$sessionizer_dir"

  ln -s "$current_dir"/sessionizer.sh "$sessionizer_path" && echo "✅ Tmux sessionizer linked" || exit 1
else
  echo "⏭️  Tmux sessionizer already exists!"
fi

echo "✨ Tmux setup complete!"
