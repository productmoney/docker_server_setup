#!/bin/bash

cd "$HOME" || exit

OHMYZSH_LOC="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

echo "sh -c \"\$(curl -fsSL $OHMYZSH_LOC)"
sh -c "$(curl -fsSL $OHMYZSH_LOC)"
