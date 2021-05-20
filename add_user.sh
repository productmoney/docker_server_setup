#!/bin/bash

adduser --disabled-password --gecos "" "$DESIRED_USERNAME"
yes "$2" | passwd "$1"

echo "Added $DESIRED_USERNAME with the randomized password: "
echo "$2"

adduser "$DESIRED_USERNAME" sudo
