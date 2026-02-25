if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# autoload -Uz compinit && compinit
calendar_info() {
  echo "%F{225}{ %D{%a %b %d %H:%M} }%f"
}

user_info() {
  echo "%F{119}%n%f@%F{184}%m%f"
}

directory_info() {
  echo "%F{87}[%~]%f"
}

# Add git branch if its present to PS1
parse_git_branch() {
 echo `git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
}

print_git_branch() {
  branch=$(parse_git_branch)
  if [[ -n "$branch" ]]; then
    echo "{ GIT: $branch }"
  fi
}

git_info() {
  echo "%F{8}\$(print_git_branch)%f"
}

NEW_LINE=$'\n'

setopt PROMPT_SUBST
export PROMPT="$(calendar_info) $(user_info)%F{white}:%f$(directory_info)${NEW_LINE}$(git_info):\$ "

export LANG=en_US.UTF-8

source ~/.zprofile

eval "$('/opt/homebrew/bin/brew' shellenv)"

if [[ -f ~/.api_keys.zsh ]]; then
  source ~/.api_keys.zsh
fi

# Somehow with the new change of setting powerlevel10k, `readlink -f "$0"` doesn't work as expected on startup.
# $0 apparently equals to '-zsh' instead of the actual script file path. Don't want to investigate why, so...
enterprise_dir=$(fd --base-directory $HOME -t d -d 2 -I -H .enterprise)
if [[ ! -z "$enterprise_dir" && -f "$HOME"/"$enterprise_dir"/.zshrc ]]; then
  source "$HOME"/"$enterprise_dir"/.zshrc
fi


# While plist logic doesn't work, run it when opening the terminal
REMAP_KEYS_SCRIPT_PATH="$HOME/.dotfiles/LaunchDaemons/scripts/remapkeys.sh"
if [[ -f $REMAP_KEYS_SCRIPT_PATH ]]; then
  source $REMAP_KEYS_SCRIPT_PATH
fi

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

if [[ -d ~/$HOME/.n ]]; then
  mkdir $HOME/.n
fi

export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$HOME/.local/bin:$(brew --prefix)/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Auto-load .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

source ~/powerlevel10k/powerlevel10k.zsh-theme
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
