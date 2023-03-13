#!/bin/bash

GH_URL="https://github.com/"
#GH_RAW="https://raw.githubusercontent.com"
GH_API="https://api.github.com"

BUILD_PROJECT="generate_allomorph"
PROJECT_FOLDER="project"

function section_split() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n%s\n\n" "$1" ; }
function section_split_plain() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n" ; }

AUTH_FOLDER="$HOME/auth"
DEFAULT_AUTH_FILE="$AUTH_FOLDER/default_auth.txt"
DEFUALT_ORG="productmoney"
SETUP_PROJ="$GH_URL/$DEFUALT_ORG/$BUILD_PROJECT.git"
AUTH_SCRIPT_LOCATION="$SETUP_PROJ/default-auth-setup.sh"
if [ ! -f "$DEFAULT_AUTH_FILE" ]; then
  section_split "bash <(curl -s $AUTH_SCRIPT_LOCATION)"
  bash <(curl -s "$AUTH_SCRIPT_LOCATION")
fi

ORG_NAME="$(grep "ORG_NAME" "$DEFAULT_AUTH_FILE" | cut -d'=' -f2-)"

section_split "What should the github name of this project be?"
read -r PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
  echo "Error: no github project name"
  exit 1
fi

echo "Using \$ORG_NAME $ORG_NAME"
echo "Using \$PROJECT_NAME $PROJECT_NAME"

if [ -d "$SETUP_PROJ" ]; then
  section_split "cd $SETUP_PROJ"
  cd "$SETUP_PROJ" || exit 1
  echo "git pull"
  git pull
  echo "cd .."
  cd .. || exit 1
else
  SETUP_PROJ="$GH_URL/$ORG_NAME/$BUILD_PROJECT.git"
  section_split "git clone $SETUP_PROJ"
  git clone "$SETUP_PROJ"
fi

section_split "cp -r $BUILD_PROJECT/$PROJECT_FOLDER $PROJECT_NAME"
mv "$BUILD_PROJECT/$PROJECT_FOLDER" "$PROJECT_NAME"

section_split "cd $PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

section_split "git init"
git init

section_split "git add README.md"
git add README.md

section_split 'git commit -m "first commit"'
git commit -m "first commit"

section_split "git remote add origin \"git@github.com:$ORG_NAME/$PROJECT_NAME.git\""
git remote add origin "git@github.com:$ORG_NAME/$PROJECT_NAME.git"

GITHUB_AUTH_TOKEN="$(grep "_AUTH_TOKEN" "$DEFAULT_AUTH_FILE" | cut -d'=' -f2-)"
REPO_Q_STRING="{\"name\":\"$PROJECT_NAME\", \"private\": true}"
REPO_Q_URL="$GH_API/orgs/$ORG_NAME/repos"
REPO_AUTH="Authorization: token $GITHUB_AUTH_TOKEN"
section_split "-H \"$REPO_AUTH\" --data \"$REPO_Q_STRING\" \"$REPO_Q_URL\""
curl -H "$REPO_AUTH" --data "$REPO_Q_STRING" "$REPO_Q_URL"

section_split "git push -u origin master"
git push -u origin master

section_split "Updating project"
