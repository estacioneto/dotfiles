#!/bin/bash -e

# Download docker-fzf-completion if ~/.docker-fzf-completion/ does not exist

if [ ! -d "$HOME"/.docker-fzf-completion ]; then
  echo "📦 Downloading docker-fzf-completion..."
  echo

  git clone "https://github.com/kwhrtsk/docker-fzf-completion" "$HOME"/.docker-fzf-completion && echo "✅ docker-fzf-completion downloaded" || exit 1
else
  echo "⏭️  docker-fzf-completion already downloaded!"
fi
