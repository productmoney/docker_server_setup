#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install apt-utils
apt-get install software-properties-common
apt-get install -y htop wget git ntp zsh apt-transport-https ca-certificates curl rsync
