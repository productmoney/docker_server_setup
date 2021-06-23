#!/bin/bash

mkdir -p ~/src
cd ~/src
git clone "https://github.com/ryanoasis/nerd-fonts.git"
cd nerd-fonts
./install.sh
cd "$HOME"
