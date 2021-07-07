#!/bin/bash

AUTH_FOLDER="$HOME/auth"
DEFAULT_AUTH_FILE="$AUTH_FOLDER/default_auth.txt"

AUTH_SCRIPT_LOCATION="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/default-auth-setup.sh"

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

mkdir -p "$AUTH_FOLDER"

if test -f "$DEFAULT_AUTH_FILE"; then

  section_split "$DEFAULT_AUTH_FILE file already present."
  cat "$DEFAULT_AUTH_FILE"

  section_split "Would you like to reset/rm this auth file? y/n"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) rm "$DEFAULT_AUTH_FILE"; break;;
          No ) break;;
      esac
  done

fi

if test -f "$DEFAULT_AUTH_FILE"; then

  echo "Using pre-existing default auth file."

else

  section_split "Generating new default auth file"

  echo "What is your github login email address?"
  read -r GH_EMAIL
  if [ -z "$GH_EMAIL" ]; then
    echo "Error: no GH_EMAIL"
    exit 1
  fi

  echo "What is your github username?"
  read -r GH_USERNAME
  if [ -z "$GH_USERNAME" ]; then
    echo "Error: no GH_USERNAME"
    exit 1
  fi

  echo "What is your github auth token?"
  echo "(If you don't have one, can create at https://github.com/settings/tokens being sure to include the right permissions)"
  read -r GH_AUTH_TOKEN
  if [ -z "$GH_AUTH_TOKEN" ]; then
    echo "Error: no GH_AUTH_TOKEN"
    exit 1
  fi

  echo "What is your current jwt auth parent key for davs apis?"
  read -r JWT_SIGNING_KEY
  if [ -z "$JWT_SIGNING_KEY" ]; then
    echo "Error: no JWT_SIGNING_KEY"
    exit 1
  fi

  DEFAULT_ORG_NAME="productmoney"
  section_split "What is your github organization (like in the url)?"
  echo "If blank, will default to $DEFAULT_ORG_NAME"
  read -r ORG_NAME
  if [ -z "$ORG_NAME" ]; then
    ORG_NAME="$DEFAULT_ORG_NAME"
  fi

  DF_AUTH_FILE_TEXT="GH_EMAIL=$GH_EMAIL
GH_USERNAME=$GH_USERNAME
ORG_NAME=$ORG_NAME
GH_AUTH_TOKEN=$GH_AUTH_TOKEN
JWT_SIGNING_KEY=$JWT_SIGNING_KEY"

  section_split "Writing $DEFAULT_AUTH_FILE with:"
  echo "$DF_AUTH_FILE_TEXT" | tee -a "$DEFAULT_AUTH_FILE"

fi

section_split "$DEFAULT_AUTH_FILE written as:"
cat "$DEFAULT_AUTH_FILE"

section_split "Is this ok? y/n"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) bash <(curl -s "$AUTH_SCRIPT_LOCATION"); break;;
    esac
done
