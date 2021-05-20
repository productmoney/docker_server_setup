#!/bin/bash

echo "adduser --disabled-password --gecos "" $1"
adduser --disabled-password --gecos "" "$1"

echo ""
echo "yes $2 | passwd $1"
yes "$2" | passwd "$1"

echo ""
echo "adduser $1 sudo"
adduser "$1" sudo
