#!/bin/bash

# Uncomment out the following line to remove old docker stuff
#sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update -y

# Install Dependencies
sudo apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add to the sources.list file for docker
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the system to suck in docker
sudo apt-get update -y

# Install docker
sudo apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io

# Test docker
sudo docker run hello-world

# Give the current user permission to use docker
sudo usermod -aG docker "$USER"

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Give proper permission to docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Test docker-compose
docker-compose --version

echo ""
echo "*** IMPORTANT ***"
echo "Now re log out and relog in to test docker installation as a user!"
