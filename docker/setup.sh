#!/bin/bash -e

if ! which lazydocker &> /dev/null; then
  echo "💿 Installing lazydocker (https://github.com/jesseduffield/lazydocker)..."
  brew install lazydocker && echo "✅ [Dependencies] lazydocker installed" || exit 1
else
  echo "⏭️  lazydocker already installed!"
fi
