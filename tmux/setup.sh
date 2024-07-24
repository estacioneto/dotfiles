#!/bin/bash

if ! which tmux &> /dev/null; then
  echo "💿 Installing Tmux (https://github.com/tmux/tmux)..."
  brew install tmux && echo "✅ [Dependencies] Tmux installed" || exit 1
else
  echo "⏭️  Tmux already installed!"
fi

echo

current_dir=$(dirname -- "$(readlink -f "$0")")

if [ ! -L "$HOME"/.tmux.conf ]; then
  echo "🔗 Linking .tmux.conf..."
  ln -s "$current_dir"/.tmux.conf "$HOME"/.tmux.conf && echo "✅ .tmux.conf linked" || exit 1
else
  echo "⏭️  .tmux.conf already exists!"
fi

echo

tmux_bin_path="$HOME"/.local/share/tmux/bin

if [ ! -d "$tmux_bin_path" ]; then
  echo "🔗 Linking Tmux scripts..."

  mkdir -p "$tmux_bin_path"

  ln -s "$current_dir"/bin/* "$tmux_bin_path" && echo "✅ Tmux scripts linked" || exit 1
else
  echo "⏭️  Tmux scripts already linked!"
fi

echo

echo "✨ Tmux setup complete!"
