#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y

apt-get install apt-utils
apt-get install software-properties-common
apt-get install -y htop wget git ntp zsh apt-transport-https ca-certificates curl rsync

password_length=12
randompw=$(date +%s | sha256sum | base64 | head -c "$password_length" ; echo)

echo ""
echo "----------"
echo "Please enter your desired user name"
read -r DESIRED_USERNAME

echo ""
adduser --disabled-password --gecos "" "$DESIRED_USERNAME"
sleep 2
yes "$randompw" | passwd "$DESIRED_USERNAME"
echo "Added $DESIRED_USERNAME with the randomized password:"
echo "$randompw"

adduser "$DESIRED_USERNAME" sudo

echo ""
echo "----------"
echo "Increasing sudo timeout duration"
echo "sed -i 's/env_reset/env_reset,timestamp_timeout=90/' /etc/sudoers"
sed -i 's/env_reset/env_reset,timestamp_timeout=90/' "/etc/sudoers"

echo ""
echo "----------"
echo "Done, please re-login as $DESIRED_USERNAME using password $randompw now."
