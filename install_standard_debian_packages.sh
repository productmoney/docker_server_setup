#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

section_split "apt-get update"
apt-get update
section_split "apt-get upgrade -y"
apt-get upgrade -y

section_split "apt-get install -y apt-utils"
apt-get install -y apt-utils

section_split "apt-get install -y software-properties-common"
apt-get install -y software-properties-common

section_split "apt-get install -y
  htop
  wget
  git
  ntp
  zsh
  apt-transport-https
  ca-certificates
  curl
  rsync
  sudo
  dnsutils"
apt-get install -y \
  htop \
  wget \
  git \
  ntp \
  zsh \
  apt-transport-https \
  ca-certificates \
  curl \
  rsync \
  sudo \
  dnsutils
