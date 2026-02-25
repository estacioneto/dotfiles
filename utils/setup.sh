#!/bin/bash -e

if ! brew list htop > /dev/null 2>&1; then
  echo "💿 Installing htop (https://htop.dev/)..."
  brew install htop && echo "✅ htop installed" || exit 1
else
  echo "⏭️  htop already installed!"
fi

if ! brew list jq > /dev/null 2>&1; then
  echo "💿 Installing jq (https://jqlang.org/)..."
  brew install jq && echo "✅ jq installed" || exit 1
else
  echo "⏭️  jq already installed!"
fi

if ! brew list jless > /dev/null 2>&1; then
  echo "💿 Installing jless (https://jless.io/)..."
  brew install jless && echo "✅ jless installed" || exit 1
else
  echo "⏭️  jless already installed!"
fi
