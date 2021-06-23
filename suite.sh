#!/bin/bash

# gotop
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
/tmp/gotop/scripts/download.sh
sudo mv gotop /usr/bin/
rm -rf /tmp/gotop

# bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# lsd
wget "https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd-musl_0.20.1_amd64.deb"
sudo dpkg -i lsd*
rm -f "lsd-"*
mkdir -p ~/conf/lsd
wget "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/utilities/lsd/config.yaml" -P ~/conf/lsd

