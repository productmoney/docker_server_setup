#!/bin/bash

DEFAULT_ORG_NAME="productmoney"

GH_URL="https://github.com/"
GH_RAW="https://raw.githubusercontent.com"

BUILD_PROJECT="generate_allomorph"
PROJECT_FOLDER="project"

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
AUTH_SCRIPT_LOCATION="$SETUP_PROJ/default-auth-setup.sh"
if [ ! -f "$DEFAULT_AUTH_FILE" ]; then
  bash <(curl -s "$AUTH_SCRIPT_LOCATION")
fi

echo "Using \$ORG_NAME $ORG_NAME"
echo "Using \$PROJECT_NAME $PROJECT_NAME"

SETUP_PROJ="$GH_RAW/$ORG_NAME/docker_server_setup/main"
section_split "git clone $SETUP_PROJ"
git clone "$SETUP_PROJ"

section_split "mv $BUILD_PROJECT/$PROJECT_FOLDER $PROJECT_NAME"
mv "$BUILD_PROJECT/$PROJECT_FOLDER" "$PROJECT_NAME"

section_split "rm -rf $BUILD_PROJECT"
rm -rf "$BUILD_PROJECT"
