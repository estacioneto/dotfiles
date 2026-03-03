#!/bin/bash -e

# Link .zprofile
current_dir=$(dirname -- "$(readlink -f "$0")")

if [ ! -e "$HOME"/.zshrc ]; then
  echo "🔗 Linking .zshrc..."
  ln -s "$current_dir"/.zshrc "$HOME"/.zshrc && echo "✅ .zshrc linked" || exit 1
else
  echo "⏭️  .zshrc already exists!"
fi


if [ ! -e "$HOME"/.p10k.zsh ]; then
  echo "🔗 Linking .p10k.zsh..."
  ln -s "$current_dir"/.p10k.zsh "$HOME"/.p10k.zsh && echo "✅ .p10k.zsh linked" || exit 1
else
  echo "⏭️  .p10k.zsh already exists!"
fi

echo

if [ ! -e "$HOME"/.zprofile ]; then
  echo "🔗 Linking .zprofile..."
  ln -s "$current_dir"/.zprofile "$HOME"/.zprofile && echo "✅ .zprofile linked" || exit 1
else
  echo "⏭️  .zprofile already exists!"
fi

echo

if [ ! -e "$HOME"/.api_keys.zsh ] && [ -e "$current_dir"/.api_keys.zsh ]; then
  echo "🔗 Linking .api_keys.zsh..."
  ln -s "$current_dir"/.api_keys.zsh "$HOME"/.api_keys.zsh && echo "✅ .api_keys.zsh linked" || exit 1
else
  echo "⏭️  .api_keys.zsh already exists!"
fi

echo

# Install zsh-autosuggestions
if ! brew list zsh-autosuggestions > /dev/null 2>&1; then
  echo "💿 Installing zsh-autosuggestions (https://github.com/zsh-users/zsh-autosuggestions)..."
  brew install zsh-autosuggestions && echo "✅ zsh-autosuggestions installed" || exit 1
else
  echo "⏭️  zsh-autosuggestions already installed!"
fi

# Setup docker completion
echo

"$current_dir"/../fzf/setup_docker_completion.sh

echo

# Install bat for file previewing
if ! brew list bat > /dev/null 2>&1; then
  echo "💿 Installing bat (https://github.com/sharkdp/bat)..."
  brew install bat && echo "✅ bat installed" || exit 1
else
  echo "⏭️  bat already installed!"
fi

echo

if ! brew list zsh-syntax-highlighting > /dev/null 2>&1; then
  echo "💿 Installing zsh-syntax-highlighting (https://github.com/zsh-users/zsh-syntax-highlighting)..."
  brew install zsh-syntax-highlighting && echo "✅ zsh-syntax-highlighting installed" || exit 1
else
  echo "⏭️  zsh-syntax-highlighting already installed!"
fi

echo

if [ ! -d ~/powerlevel10k ]; then
  echo "💿 Installing powerlevel10k (https://github.com/romkatv/powerlevel10k)..."

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

  # No need to echo 'source ~/powerlevel...' since it's already present on ~/.zshrc
else
  echo "⏭️  powerlevel10k already installed!"
fi

echo "✨ Zsh setup complete!"

echo "⚡️ Run \`source ~/.zshrc\` to update the config."

echo
