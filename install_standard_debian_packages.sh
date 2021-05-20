#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install -y apt-utils
apt-get install -y software-properties-common
apt-get install -y htop wget git ntp zsh apt-transport-https ca-certificates curl rsync
