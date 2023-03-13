#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

CADDY_DIR="$HOME/hosting/caddy"
CADDYFILE="$CADDY_DIR/Caddyfile"
STARTING_CADDYFILE=""

function section_split() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n%s\n\n" "$1" ; }
function section_split_plain() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n" ; }

# Make sure docker properly installed
if [ -x "$(command -v caddy)" ]; then
  echo "caddy already installed"
else
  section_split "apt-get install -y --no-install-recommends
    debian-keyring
    debian-archive-keyring
    apt-transport-https"
  sudo apt-get install -y --no-install-recommends \
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
fi

mkdir -p "$CADDY_DIR"
touch "$CADDYFILE"
echo "Do you wish to wipe caddy config @$CADDYFILE?"
select yn in "Yes" "No"; do
  case $yn in
      Yes ) echo "$STARTING_CADDYFILE" | tee "$CADDYFILE"; break;;
      No ) break;;
  esac
done

section_split "Setting up caddy sites"

function add_caddy_site() {
  echo "Please enter the site url (don't include https://):"
  local site_url
  read -r site_url

  echo "Please enter the site nginx entry port:"
  local nginx_entry_port
  read -r nginx_entry_port

  local caddy_entry
  caddy_entry="$site_url {
    encode gzip zstd
    reverse_proxy /* localhost:$nginx_entry_port
}
"

  echo "Appended to $CADDYFILE:"
  echo "$caddy_entry" | tee -a "$CADDYFILE"
}

function start_caddy() {

  echo "cat $CADDYFILE"
  cat "$CADDYFILE"

  sudo caddy stop

  echo "To start caddy:"
  echo "sudo caddy start --config $CADDYFILE"
  exit
}

function write_caddy_config() {
  while true; do
    section_split "Do you wish to add a caddy site?"
    select yn in "Yes" "No"; do
      case $yn in
          Yes ) add_caddy_site; break;;
          No ) start_caddy;;
      esac
    done
  done
}

echo "Do you wish to edit caddy config @$CADDYFILE?"
select yn in "Yes" "No"; do
  case $yn in
      Yes ) write_caddy_config; break;;
      No ) start_caddy;;
  esac
done
