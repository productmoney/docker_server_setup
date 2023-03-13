#!/bin/bash

USER=$1

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

function section_split() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n%s\n\n" "$1" ; }
function section_split_plain() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n" ; }

# Install Dependencies
section_split "apt-get install -y --no-install-recommends
  apt-transport-https
  ca-certificates
  curl
  gnupg
  lsb-release
  net-tools"
apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  net-tools


DOCKER_SOURCES_LIST="/etc/apt/sources.list.d/docker.list"

LSBCS=$(lsb_release -cs)


KEYRING_DISTRO="debian"
if grep "Ubuntu" "/etc/"*release*; then
  KEYRING_DISTRO="ubuntu"
  section_split "Ubuntu operating system detected"
else
  section_split "Debian operating system detected"
fi


GPG_LOCATION="https://download.docker.com/linux/$KEYRING_DISTRO/gpg"
DOCKER_KEYRING="/usr/share/keyrings/docker-archive-keyring.gpg"
DOCKER_DOWNLOAD_LOCATION="https://download.docker.com/linux/$KEYRING_DISTRO"
DOCKER_VERSION="stable"

section_split "curl -fsSL $GPG_LOCATION | gpg --dearmor -o $DOCKER_KEYRING"
curl -fsSL "$GPG_LOCATION" | gpg --dearmor -o "$DOCKER_KEYRING"

section_split "deb [arch=amd64 signed-by=$DOCKER_KEYRING] $DOCKER_DOWNLOAD_LOCATION $LSBCS $DOCKER_VERSION | tee $DOCKER_SOURCES_LIST > /dev/null"
echo \
  "deb [arch=amd64 signed-by=$DOCKER_KEYRING] \
  $DOCKER_DOWNLOAD_LOCATION \
  $LSBCS $DOCKER_VERSION" \
  | tee "$DOCKER_SOURCES_LIST" > /dev/null

section_split "apt-get update -y"
apt-get update -y

section_split "apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io"
apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io

section_split "docker run hello-world"
docker run hello-world

section_split "usermod -aG docker $USER"
usermod -aG docker "$USER"
