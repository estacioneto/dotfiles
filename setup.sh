#!/bin/bash -e

sh ./setup_zsh.sh
echo
sh ./tmux/setup.sh
echo
# TODO: Setup node
# TODO: Setup symlinks
# TODO: Setup Gitconfig
sh ./neovim/setup.sh
