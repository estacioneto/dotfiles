#!/bin/bash -e

if ! brew list colima > /dev/null 2>&1; then
  echo "💿 Installing colima (https://github.com/abiosoft/colima)..."
  brew install colima && echo "✅ colima installed" || exit 1
else
  echo "⏭️  colima already installed!"
fi

if ! which lazydocker &> /dev/null; then
  echo "💿 Installing lazydocker (https://github.com/jesseduffield/lazydocker)..."
  brew install lazydocker && echo "✅ [Dependencies] lazydocker installed" || exit 1
else
  echo "⏭️  lazydocker already installed!"
fi
