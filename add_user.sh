#!/bin/bash

adduser --disabled-password --gecos "" "$1"
yes "$2" | passwd "$1"

echo "Added $DESIRED_USERNAME with the randomized password: "
echo "$2"

adduser "$1" sudo
