#!/bin/bash -e

if ! which brew &> /dev/null; then
  echo "💿 Installing Homebrew (https://brew.sh/)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && echo "✅ [Dependencies] Homebrew installed" || exit 1
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo
else
  echo "⏭️  Homebrew already installed!"
  echo
fi

current_dir=$(dirname -- "$(readlink -f "$0")")

sh "$current_dir"/zsh/setup.sh
echo
sh "$current_dir"/tmux/setup.sh
echo

if ! which node &> /dev/null; then
  echo "💿 Installing Node.js (https://nodejs.org/en)..."

  if ! which n &> /dev/null; then
    echo "💿 Installing n (https://github.com/tj/n)..."
    brew install n && echo "✅ [Dependencies] n installed" || exit 1
  else
    echo "⏭️  n already installed!"
  fi
  echo

  n lts && echo "✅ [Dependencies] Node.js installed" || exit 1
else
  echo "⏭️  Node.js already installed!"
fi
echo

if [ ! -e "$HOME"/.gitconfig ]; then
  echo "🔗 Linking .gitconfig..."
  ln -s "$current_dir"/.gitconfig "$HOME"/.gitconfig && echo "✅ .gitconfig linked" || exit 1
else
  echo "⏭️  .gitconfig already exists!"
fi
echo

sh "$current_dir"/neovim/setup.sh
sh "$current_dir"/docker/setup.sh
