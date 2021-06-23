#!/bin/bash

# gotop
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
/tmp/gotop/scripts/download.sh
sudo mv gotop /usr/bin/
rm -rf /tmp/gotop

# bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Rust
curl https://sh.rustup.rs -sSf | sh

# delta
cargo install git-delta

# exa
cargo install exa

# dust
cargo install du-dust

# ripgrep
cargo install ripgrep

# mcfly
mkdir -p ~/src
cd ~/src || exit 1
git clone https://github.com/cantino/mcfly
cd mcfly || exit 1
cargo install --path .
cd "$HOME" || exit 1

# choose
cargo install choose

# sd
cargo install sd

# cheat
sudo apt-get install golang-go
go get -u github.com/cheat/cheat/cmd/cheat

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install ESTABLISHED

# hyperfine
cargo install hyperfine

# gping
cargo install gping

# procs
cargo install procs

# zoxide
curl -sS https://webinstall.dev/zoxide | bash
