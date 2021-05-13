#!/bin/bash

echo ""
echo "----------"
echo "Please enter your desired hosts name"
read -r HNAME

sudo hostnamectl set-hostname "$HNAME"

echo ""
echo "sudo nano /etc/hosts"
echo "Please replace hosts names where approiate here"
sleep 4
sudo nano /etc/hosts
