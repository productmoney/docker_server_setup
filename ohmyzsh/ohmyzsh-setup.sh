#!/bin/bash

echo "Installing gotop cause why not XD"
sudo snap install gotop

echo "Changing users shell to /bin/zsh."
echo "Please enter sudo password to do so."
chsh -s /bin/zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

wget -q "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/.zsh_aliases" ~/.zsh_aliases

wget -q "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/.zshrc" ~/.zshrc

wget -q "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/lambda-mod.zsh-theme" ~/.ohmyzsh/themes
