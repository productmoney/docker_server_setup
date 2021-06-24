#!/bin/bash

# gotop process monitor
git clone --depth 1 "https://github.com/cjbassi/gotop" "/tmp/gotop"
bash "/tmp/gotop/scripts/download.sh"
sudo mv gotop /usr/bin/
rm -rf /tmp/gotop

# bat better cat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Rust programs and lang
curl https://sh.rustup.rs -sSf | sh

# delta diff
cargo install git-delta

# exa ls
cargo install exa

# dust du
cargo install du-dust

# ripgrep grep recursive
cargo install ripgrep

# mcfly term search
mkdir -p ~/src
cd ~/src || exit 1
git clone https://github.com/cantino/mcfly
cd mcfly || exit 1
cargo install --path .
cd "$HOME" || exit 1

# choose splits
cargo install choose

# sd find and replace
cargo install sd

# cheat hints
sudo apt-get install golang-go
go get -u github.com/cheat/cheat/cmd/cheat

# nvm
curl -o- -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install stable

# tldr hints
npm install -g tldr

# hyperfine
cargo install hyperfine

# gping
cargo install gping

# procs
cargo install procs

# zoxide
#curl -sS https://webinstall.dev/zoxide | bash

# micro
curl https://getmic.ro | bash
mv micro "$HOME/.local/bin"

source "$HOME/.zshrc"
