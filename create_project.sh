#!/bin/bash

DEFAULT_ORG_NAME="productmoney"

BUILD_PROJECT="generate_allomorph"
PROJECT_FOLDER="project"
PROJECT_DOWNLOAD_LOCATION="https://github.com/productmoney/$PROJECT_NAME.git"

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

section_split "What is your github organization?"
echo "If blank, will default to $DEFAULT_ORG_NAME"
read -r ORG_NAME
if [ -z "$ORG_NAME" ]; then
  ORG_NAME="$DEFAULT_ORG_NAME"
fi

section_split "What should the github name of this project be?"
read -r PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
  echo "Error: no github project name"
  exit 1
fi

AUTH_FOLDER="$HOME/auth"
DEFAULT_AUTH_FILE="$AUTH_FOLDER/default_auth.txt"
AUTH_SCRIPT_LOCATION="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/default-auth-setup.sh"
if [ ! -f "$DEFAULT_AUTH_FILE" ]; then
  bash <(curl -s "$AUTH_SCRIPT_LOCATION")
fi

echo "Using \$ORG_NAME $ORG_NAME"
echo "Using \$PROJECT_NAME $PROJECT_NAME"

git clone "$PROJECT_DOWNLOAD_LOCATION"
mv "$BUILD_PROJECT/$PROJECT_FOLDER" "$PROJECT_NAME"
rm -rf "$BUILD_PROJECT"