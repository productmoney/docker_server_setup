#!/bin/bash

cd "$HOME" || exit

eval "$(ssh-agent)"

REPO_LOC="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh"
THEME_NAME="lambda-mod.zsh-theme"

echo "wget -q -O $HOME/.zsh_alias $REPO_LOC/.zsh_aliases"
wget -q -O "$HOME/.zsh_aliases" "$REPO_LOC/.zsh_aliases"

echo "wget -q -O $HOME/.zshrc $REPO_LOC/.zshrc"
wget -q -O "$HOME/.zshrc" "$REPO_LOC/.zshrc"

echo "wget -q -O $HOME/.oh-my-zsh/themes/$THEME_NAME $REPO_LOC/$THEME_NAME"
wget -q -O "$HOME/.oh-my-zsh/themes/$THEME_NAME" "$REPO_LOC/$THEME_NAME"

# shellcheck disable=SC1090
source ~/.zshrc &>/dev/null
