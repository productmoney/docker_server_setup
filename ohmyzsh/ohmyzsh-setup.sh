#!/bin/bash

echo "Changing users shell to /bin/zsh."
echo "Please enter sudo password to do so."
chsh -s /bin/zsh

REPO_LOC="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh"

echo "sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "wget -q -O \"$HOME/.zsh_aliasfile:///snap/bitwarden/46/resources/app.asar/index.html#es\" \"$REPO_LOC/.zsh_aliases\" ~/.zsh_aliases"
wget -q -O "$HOME/.zsh_aliases" "$REPO_LOC/.zsh_aliases"

echo "wget -q -O \"\$HOME/.zshrc\" \"$REPO_LOC/.zshrc\" ~/.zshrc"
wget -q -O "$HOME/.zshrc" "$REPO_LOC/.zshrc"

THEME_NAME="lambda-mod.zsh-theme"
echo "wget -O \"\$HOME/.oh-my-zsh/themes/$THEME_NAME\" \"$REPO_LOC/$THEME_NAME\""
wget -O "$HOME/.oh-my-zsh/themes/$THEME_NAME" "$REPO_LOC/$THEME_NAME"
