#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

CADDYFILE="~/hosting/caddy/Caddyfile"
STARTING_CADDYFILE=""

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

section_split "apt-get install -y --no-install-recommends
  debian-keyring
  debian-archive-keyring
  apt-transport-https"
apt-get install -y --no-install-recommends \
  debian-keyring \
  debian-archive-keyring \
  apt-transport-https

section_split "curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -

section_split "curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

section_split "sudo apt update"
sudo apt update

section_split "sudo apt install caddy"
sudo apt install caddy

section_split "caddy version"
caddy version

mkdir -p ~/hosting/caddy
#echo "Wrote to $CADDYFILE:"
echo "$STARTING_CADDYFILE" | tee "$CADDYFILE"

section_split "Setting up caddy sites"

function add_caddy_site() {
  echo "Please enter the site url (don't include https://):"
  local site_url
  read -r site_url

  echo "Please enter the site nginx entry port:"
  local nginx_entry_port
  read -r nginx_entry_port

  local caddy_entry
  caddy_entry="
$site_url {
    encode gzip zstd
    reverse_proxy /* localhost:$nginx_entry_port
}
"

  echo "Appended to $CADDYFILE:"
  echo "$caddy_entry" | tee -a "$CADDYFILE"

END
}

while true; do
    read  -r -p "Do you wish to add a caddy site?" yn
    case $yn in
        [Yy]* ) add_caddy_site; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

sudo caddy start --config ~/hosting/caddy/Caddyfile
