#!/bin/bash

SSH_DIR="$HOME/.ssh"
SSH_ID_RSA="$SSH_DIR/id_rsa"
SSH_ID_RSA_PUB="$SSH_ID_RSA.pub"
SSH_CONFIG="$SSH_DIR/config"
GITCONFIG="$HOME/.gitconfig"

GITHUB_KEYS="https://api.github.com/user/keys"

mkdir -p "$SSH_DIR"

AUTH_FOLDER="$HOME/auth"
DEFAULT_AUTH_FILE="$AUTH_FOLDER/default_auth.txt"
AUTH_SCRIPT_LOCATION="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/default-auth-setup.sh"
if [ ! -f "$DEFAULT_AUTH_FILE" ]; then
  bash <(curl -s "$AUTH_SCRIPT_LOCATION")
fi

function section_split() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n%s\n\n" "$1" ; }
function section_split_plain() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n" ; }

GITHUB_USERNAME="$(grep "_USERNAME" "$DEFAULT_AUTH_FILE" | cut -d'=' -f2-)"

GITHUB_EMAIL="$(grep "_EMAIL" "$DEFAULT_AUTH_FILE" | cut -d'=' -f2-)"

GITHUB_AUTH_TOKEN="$(grep "_AUTH_TOKEN" "$DEFAULT_AUTH_FILE" | cut -d'=' -f2-)"

HOSTNAME=$(hostname)
echo "Key will have the name: $HOSTNAME (from using command hostname)"

section_split "ssh-keygen -q -t rsa -N '' -f $SSH_ID_RSA -C \"$GITHUB_USERNAME\" <<<y 2>&1 >/dev/null"
ssh-keygen -q -t rsa -N '' -f "$SSH_ID_RSA" -C "$GITHUB_USERNAME" <<<y 2>&1 >/dev/null
echo "eval \$(ssh-agent -s)"
eval "$(ssh-agent -s)"
echo "ssh-add $SSH_ID_RSA"
ssh-add "$SSH_ID_RSA"
echo "pub=\$(cat $SSH_ID_RSA_PUB)"
pub=$(cat "$SSH_ID_RSA_PUB")
# shellcheck disable=SC2016
echo "curl -H Authorization: token $GITHUB_AUTH_TOKEN -X POST -d {\"title\":\"$HOSTNAME\",\"key\":\"$pub\"} $GITHUB_KEYS"
curl -H "Authorization: token $GITHUB_AUTH_TOKEN" -X POST -d "{\"title\":\"$HOSTNAME\",\"key\":\"$pub\"}" "$GITHUB_KEYS"

section_split "echo 'StrictHostKeyChecking no' > $SSH_CONFIG"
echo "StrictHostKeyChecking no " > "$SSH_CONFIG"

mkdir -p ~/.config/git
section_split "Writing ~/.config/git/.gitignore_global"
cat > "$HOME/.config/git/.gitignore_global" << EOL
.idea
tmp
venv
srecret
**/__pycache__/*
**/*.pyc
*.pyc
*.db.sqlite3
EOL

section_split "Writing .gitconfig"
cat > "$GITCONFIG" << EOL
[user]
	email = $GITHUB_EMAIL
[core]
  mergeoptions = --no-commit
  excludesfile = $HOME/.config/git/.gitignore_global
  autocrlf = input
[alias]
  pff = pull --ff-only
  quick = log -1 --format='%h - %an - %ad - %s' --date=local --name-status
  squash = merge --squash
  blog = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative
  bdiff = show --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --name-only --date=relative origin/master..HEAD
  files = git show --pretty=\"format:\" --name-only
  hist = show --pretty=\"format:\" --name-only
  ci = commit
  co = checkout
  st = status
  mom = !git fetch && git merge origin/master
  rom = !git fetch && git reset --hard origin/master
  pom = push origin master
  ammend = commit --amend -C HEAD
  ll = log --stat --abbrev-commit
  pob = !git fetch && git merge origin/$1 && git push
  z = reset --soft HEAD^
  c = !git add . --all && git commit -m
[merge]
  commit = no
[color]
  branch = auto
  diff = auto
  status = auto
[color "branch"]
  current = yellow reverse
  local = yellow
  remote = green
[color "diff"]
  meta = yellow bold
  frag = magenta bold
  old = red bold
  new = green bold
[color "status"]
  added = yellow
  changed = green
  untracked = cyan
[push]
	default = upstream
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[url "https://$GITHUB_AUTH_TOKEN:@github.com/"]
	insteadOf = https://github.com/
EOL

eval "$(ssh-agent)"
