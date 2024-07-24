#!/bin/bash -e

# Link .zshrc
current_dir=$(dirname -- "$(readlink -f "$0")")

if [ ! -e "$HOME"/.zshrc ]; then
  echo "🔗 Linking .zshrc..."
  ln -s "$current_dir"/.zshrc "$HOME"/.zshrc && echo "✅ .zshrc linked" || exit 1
else
  echo "⏭️  .zshrc already exists!"
fi

echo

# Install zsh-autosuggestions
if ! brew list zsh-autosuggestions > /dev/null 2>&1; then
  echo "💿 Installing zsh-autosuggestions (https://github.com/zsh-users/zsh-autosuggestions)..."
  brew install zsh-autosuggestions && echo "✅ zsh-autosuggestions installed" || exit 1
else
  echo "⏭️  zsh-autosuggestions already installed!"
fi

echo

echo "✨ Zsh setup complete!"
