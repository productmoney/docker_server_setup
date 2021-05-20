#!/bin/bash

USER_PASSWORD_LENGTH=12
ORGANIZATION="productmoney"
GH_CONTENT="https://raw.githubusercontent.com/$ORGANIZATION"

export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

randompw=$(date +%s | sha256sum | base64 | head -c "$USER_PASSWORD_LENGTH" ; echo)

function run_pm_github_script(){
  bash <(curl -s "$GH_CONTENT/$1/main/$2.sh")
}

function run_setup_script(){
  run_pm_github_script "docker_server_setup" "$1"
}

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

section_split "Welcome to 3proxy docker installer!"

section_split_plain
echo "Please enter your desired user name:"
read -r DESIRED_USERNAME
USERS_HOME_FOLDER="/home/$DESIRED_USERNAME"

echo ""
echo "Please enter your github username:"
read -r GITHUB_USERNAME

echo ""
echo "Please enter your github email:"
read -r GITHUB_EMAIL

echo ""
echo "Please enter your github auth token:"
echo "(If you don't have one, can create at https://github.com/settings/tokens being sure to include the right permissions)"
read -r GITHUB_AUTH_TOKEN

section_split_plain
run_setup_script "remove-file-limits"

section_split_plain "Installing standard debian packages"
run_setup_script "install_standard_debian_packages"

section_split "Editing sudoers to include Defaults	env_reset,timestamp_timeout=90"
run_setup_script "increase_sudo_duration"

section_split "Adding user $DESIRED_USERNAME"
curl -s "$GH_CONTENT/docker_server_setup/main/add_user.sh" | \
  bash -s -- "$DESIRED_USERNAME" "$randompw"

section_split "Setting up $DESIRED_USERNAME to be able to download private github repos"

curl -s "$GH_CONTENT/docker_server_setup/main/github_setup.sh" | \
  bash -s "$USERS_HOME_FOLDER" "$GITHUB_USERNAME" "$GITHUB_EMAIL" "$GITHUB_AUTH_TOKEN"

section_split "Setting up docker, docker-compose, and premissions"
curl -s "$GH_CONTENT/docker_server_setup/main/docker_setup.sh" | \
  bash -s -- "$DESIRED_USERNAME"

section_split "Done, please re-login as $DESIRED_USERNAME now using password:"
echo "$randompw"
