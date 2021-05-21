#!/bin/bash

ALLOMORPH_GLOBAL_DIR="/var/lib/allomorph"
ALLOMORPH_LOGS_DIR="$ALLOMORPH_GLOBAL_DIR/logs"
ALLOMORPH_CACHE_DIR="$ALLOMORPH_GLOBAL_DIR/.cache/pip"
NETWORK_NAME="allomorph"

if [ -d "$ALLOMORPH_LOGS_DIR" ]; then
  :
else
  echo "sudo mkdir -p $ALLOMORPH_LOGS_DIR"
  sudo mkdir -p "$ALLOMORPH_LOGS_DIR"
  echo "sudo chown -R $USER:$USER /var/lib/allomorph/"
  sudo chown -R "$USER:$USER" /var/lib/allomorph/
fi

if [ -d "$ALLOMORPH_CACHE_DIR" ]; then
  :
else
  echo "sudo mkdir -p $ALLOMORPH_CACHE_DIR"
  sudo mkdir -p "$ALLOMORPH_CACHE_DIR"
  echo "sudo chown -R $USER:$USER /var/lib/allomorph/"
  sudo chown -R "$USER:$USER" /var/lib/allomorph/
fi

network_search="$(docker network ls --filter name=^${NETWORK_NAME}$ --format="{{ .Name }}")"
if [ -z "$network_search" ] ; then
  echo "docker network create $NETWORK_NAME"
  docker network create $NETWORK_NAME
else
#  echo "Network $NETWORK_NAME alredy exists"
  :
fi
