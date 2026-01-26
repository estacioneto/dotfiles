#!/bin/bash

if [ -d "$HOME"/.vim/lua/estacio ]; then
  echo "⏭️  Neovim already setup!"
else
  echo "💿 Fetching Neovim config..."
  git clone git@github.com:estacioneto/dotvim "$HOME"/.vim && echo "✅ Neovim config fetched" || exit 1
fi

echo

sh "$HOME"/.vim/install.sh && echo "✨ Neovim setup complete" || exit 1
