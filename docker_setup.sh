#!/bin/bash

USER=$1

DEBIAN_OS_DISTRO="debian os"
UBUNTU_OS_DISTRO="Ubuntu"

UNAME=$(uname | tr "[:upper:]" "[:lower:]")
UNS=$(uname -s)
UNM=$(uname -m)
LSBCS=$(lsb_release -cs)

DOCKER_COMPOSE_VERSION="1.28.6"
DOCKER_COMPOSE_LOCATION="https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$UNS-$UNM"
DOCKER_COMPOSE_INSTALL_LOCATION="/usr/local/bin/docker-compose"

DOCKER_SOURCES_LIST="/etc/apt/sources.list.d/docker.list"

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

# Get "Ubuntu" or "debian os"
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
unset UNAME

# Install Dependencies
section_split "apt-get install -y --no-install-recommends
    apt-transport-https
    ca-certificates
    curl
    gnupg
    lsb-release"
apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

KEYRING_DISTRO="debian"

if [ "$DISTRO" == "$UBUNTU_OS_DISTRO" ]; then
  section_split "Ubuntu operating system detected"
  KEYRING_DISTRO="ubuntu"

elif [ "$DISTRO" == "$DEBIAN_OS_DISTRO" ]; then
  section_split "Debian operating system detected"

fi

GPG_LOCATION="https://download.docker.com/linux/$KEYRING_DISTRO/gpg"
DOCKER_KEYRING="/usr/share/keyrings/docker-archive-keyring.gpg"
DOCKER_DOWNLOAD_LOCATION="https://download.docker.com/linux/$KEYRING_DISTRO"
DOCKER_VERSION="stable"

section_split "curl -fsSL $GPG_LOCATION | sudo gpg --dearmor -o $DOCKER_KEYRING"
curl -fsSL "$GPG_LOCATION" | sudo gpg --dearmor -o "$DOCKER_KEYRING"

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

section_split "curl -s -L $DOCKER_COMPOSE_LOCATION -o $DOCKER_COMPOSE_INSTALL_LOCATION"
curl -s -L "$DOCKER_COMPOSE_LOCATION" -o "$DOCKER_COMPOSE_INSTALL_LOCATION"

section_split "chmod +x $DOCKER_COMPOSE_INSTALL_LOCATION"
sudo chmod +x "$DOCKER_COMPOSE_INSTALL_LOCATION"

section_split_plain
docker-compose --version
