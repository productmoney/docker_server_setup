#!/bin/bash

curl -s https://api.github.com/repos/ClementTsang/bottom/releases/latest | grep browser_download_url | grep amd64.deb | cut -d '"' -f 4 | wget -qi -

sudo dpkg -i bottom*.deb

rm bottom*.deb
