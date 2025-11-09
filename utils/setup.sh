#!/bin/bash -e

if ! brew list htop > /dev/null 2>&1; then
  echo "💿 Installing htop (https://htop.dev/)..."
  brew install htop && echo "✅ htop installed" || exit 1
else
  echo "⏭️  htop already installed!"
fi
