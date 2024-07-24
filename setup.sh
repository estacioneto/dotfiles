#!/bin/bash -e

# Link .zprofile
current_dir=$(dirname -- "$(readlink -f "$0")")

sh "$current_dir"/zsh/setup.sh
echo
sh "$current_dir"/tmux/setup.sh
echo
# TODO: Setup node
# TODO: Setup symlinks
# TODO: Setup Gitconfig
sh "$current_dir"/neovim/setup.sh
