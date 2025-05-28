#!/bin/bash -e

current_dir=$(dirname -- "$(readlink -f "$0")")

[ -f ~/.docker-fzf-completion/docker-fzf.zsh ] && source ~/.docker-fzf-completion/docker-fzf.zsh
source "$current_dir"/git-fzf.zsh
