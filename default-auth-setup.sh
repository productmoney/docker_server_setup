#!/bin/bash

DEFAULT_AUTH_FILE="$HOME/auth/default_auth.txt"

AUTH_SCRIPT_LOCATION="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/default-auth-setup.sh"

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

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
  if [[ "$GH_EMAIL" == *"="* ]]; then
    section_split "Error: = found in \$GH_EMAIL $GH_EMAIL"
    echo "What is your github login email address?"
    read -r GH_EMAIL
  fi

  echo "What is your github username?"
  read -r GH_USERNAME
  if [ -z "$GH_USERNAME" ]; then
    echo "Error: no GH_USERNAME"
    exit 1
  fi
  if [[ "$GH_USERNAME" == *=* ]]; then
    section_split "Error: = found in \$GH_USERNAME $GH_USERNAME"
    echo "What is your github username?"
    read -r GH_USERNAME
  fi

  echo "What is your github auth token?"
  read -r GH_AUTH_TOKEN
  if [ -z "$GH_AUTH_TOKEN" ]; then
    echo "Error: no GH_AUTH_TOKEN"
    exit 1
  fi
  if [[ "$GH_AUTH_TOKEN" == *=* ]]; then
    section_split "Error: = found in \$GH_AUTH_TOKEN $GH_AUTH_TOKEN"
    echo "What is your github auth token?"
    read -r GH_AUTH_TOKEN
  fi

  echo "What is your current jwt auth parent key for davs apis?"
  read -r JWT_SIGNING_KEY
  if [ -z "$JWT_SIGNING_KEY" ]; then
    echo "Error: no JWT_SIGNING_KEY"
    exit 1
  fi
  if [[ "$JWT_SIGNING_KEY" == *=* ]]; then
    section_split "Error: = found in \$JWT_SIGNING_KEY $JWT_SIGNING_KEY"
    echo "What is your current jwt auth parent key for davs apis?"
    read -r JWT_SIGNING_KEY
  fi

  DF_AUTH_FILE_TEXT="JWT_SIGNING_KEY=$JWT_SIGNING_KEY
GH_AUTH_TOKEN=$GH_AUTH_TOKEN
GH_EMAIL=$GH_EMAIL
GH_USERNAME=$GH_USERNAME"

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
