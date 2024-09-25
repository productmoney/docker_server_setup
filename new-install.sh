#!/bin/bash

# Script setup
function section_split() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n%s\n\n" "$1" ; }
function section_split_plain() { printf "\n$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')\n" ; }

# Timezone
export TZ="America/Denver"
if grep -Rq "$TZ" /etc/timezone; then
  section_split "Timezone already set"
else
  section_split "timedatectl set-timezone $TZ"
  timedatectl set-timezone "$TZ"
fi

# Script setup
ORGANIZATION="productmoney"
GH_CONTENT="https://raw.githubusercontent.com/$ORGANIZATION"
function run_setup_script(){
  run_pm_github_script "docker_server_setup" "$1"
}

# My directories
mkdir ~/code ~/src ~/tmp ~/auth

# Bw key
nano ~/auth/bw

# Upgrade
sudo apt update && sudo apt upgrade
# install with visual apt thingy
# change sources to include all os update versions
# change to only download updates
# proprietary drivers
# reboot if necessary

# Deb packages
sudo apt-get install -y apt-utils
sudo apt-get install -y software-properties-common
sudo apt-get install -y \
  htop \
  wget \
  git \
  ntp \
  zsh \
  apt-transport-https \
  ca-certificates \
  curl \
  rsync \
  sudo \
  dnsutils \
  bat \
  build-essential \
  fd-find

# zsh
cd "$HOME" || exit
eval "$(ssh-agent)"
OHMYZSH_LOC="https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
echo "sh -c \"\$(curl -fsSL $OHMYZSH_LOC)"
sh -c "$(curl -fsSL $OHMYZSH_LOC)"
cd "$HOME" || exit
eval "$(ssh-agent)"
REPO_LOC="https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh"
THEME_NAME="lambda-mod.zsh-theme"
echo "wget -q -O $HOME/.zsh_alias $REPO_LOC/.zsh_aliases"
wget -q -O "$HOME/.zsh_aliases" "$REPO_LOC/.zsh_aliases"
echo "wget -q -O $HOME/.zshrc $REPO_LOC/.zshrc"
wget -q -O "$HOME/.zshrc" "$REPO_LOC/.zshrc"
echo "wget -q -O $HOME/.oh-my-zsh/themes/$THEME_NAME $REPO_LOC/$THEME_NAME"
wget -q -O "$HOME/.oh-my-zsh/themes/$THEME_NAME" "$REPO_LOC/$THEME_NAME"
omz update
omz reload

# Install Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update
sudo apt-get install google-chrome-stable
# Open chrome and setup login and bw

# ssh
sudo apt install openssh-server
sudo systemctl status ssh
sudo ufw allow ssh
#scp or ssh in and cp keys
chmod -R go= ~/.ssh

# Increase sudo duration
TS_TIMEOUT="timestamp_timeout"
ENVRT="env_reset"
SUDOERS_FILE="/etc/sudoers"
NEW_TIMEOUT="90"
TIMEOUT_REPLACE_STRING="s/$ENVRT/$ENVRT,$TS_TIMEOUT=$NEW_TIMEOUT/"
if sudo grep -q "$TS_TIMEOUT" "$SUDOERS_FILE"; then
  : # timestamp_timeout already written
else
  echo "sed -i $TIMEOUT_REPLACE_STRING $SUDOERS_FILE"
  sudo sed -i "$TIMEOUT_REPLACE_STRING" "$SUDOERS_FILE"
fi

# setup wallet
# install kgpg
# create in kde wallet manager

# Auth
AUTH_FOLDER="$HOME/auth"
DEFAULT_AUTH_FILE="$AUTH_FOLDER/default_auth.txt"
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

# Github setup
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

# increase sudo duration
TS_TIMEOUT="timestamp_timeout"
ENVRT="env_reset"
SUDOERS_FILE="/etc/sudoers"
NEW_TIMEOUT="90"
TIMEOUT_REPLACE_STRING="s/$ENVRT/$ENVRT,$TS_TIMEOUT=$NEW_TIMEOUT/"
if sudo grep -q "$TS_TIMEOUT" "$SUDOERS_FILE"; then
  : # timestamp_timeout already written
else
  echo "sudo sed -i $TIMEOUT_REPLACE_STRING $SUDOERS_FILE"
  sudo sed -i "$TIMEOUT_REPLACE_STRING" "$SUDOERS_FILE"
fi

# toilet
if ! [ -x "$(command -v toilet)" ]; then
  sudo apt install toilet -y --no-install-recommends -q
fi
toilet "$PROJECT_NAME Installer" -f future --gay

# Docker
if [ -x "$(command -v docker)" ]; then
  section_split "Docker already installed"
else
  section_split "Setting up docker"
  DOCKER_SOURCES_LIST="/etc/apt/sources.list.d/docker.list"
  LSBCS=$(lsb_release -cs)
  echo "LSBCS: ${LSBCS}"
  KEYRING_DISTRO="debian"
  if grep "Ubuntu" "/etc/"*release*; then
    KEYRING_DISTRO="ubuntu"
    section_split "Ubuntu operating system detected"
  else
    section_split "Debian operating system detected"
  fi
  echo "KEYRING_DISTRO: ${KEYRING_DISTRO}"
  GPG_LOCATION="https://download.docker.com/linux/$KEYRING_DISTRO/gpg"
  DOCKER_KEYRING="/usr/share/keyrings/docker-archive-keyring.gpg"
  DOCKER_DOWNLOAD_LOCATION="https://download.docker.com/linux/$KEYRING_DISTRO"
  DOCKER_VERSION="stable"
  if test -f "$DOCKER_KEYRING"; then
    echo "$DOCKER_KEYRING already exists"
  else
    echo "$DOCKER_KEYRING does not exist"
    echo "url -fsSL $GPG_LOCATION | sudo gpg --dearmor -o $DOCKER_KEYRING"
    curl -fsSL "$GPG_LOCATION" | sudo gpg --dearmor -o "$DOCKER_KEYRING"
  fi
  echo "deb [arch=amd64 signed-by=$DOCKER_KEYRING] $DOCKER_DOWNLOAD_LOCATION $LSBCS $DOCKER_VERSION | sudo tee $DOCKER_SOURCES_LIST > /dev/null"
  echo "deb [arch=amd64 signed-by=$DOCKER_KEYRING] $DOCKER_DOWNLOAD_LOCATION $LSBCS $DOCKER_VERSION"  | sudo tee "$DOCKER_SOURCES_LIST" > /dev/null
  section_split "apt-get update -y"
  sudo apt-get update -y
  section_split "apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io"
  sudo apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io
  section_split "docker run hello-world"
  sudo docker run hello-world
  section_split "usermod -aG docker $USER"
  sudo usermod -aG docker "$USER"
fi
# Re login maybe

# Doppler setup
if [ -x "$(command -v doppler)" ]; then
  section_split "Doppler already installed"
else
  section_split "Setting up doppler"
  # Doppler
  echo "-sLf --retry 3 --tlsv1.2 --proto \"=https\" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -"
  curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -
  echo "\"deb https://packages.doppler.com/public/cli/deb/debian any-version main\" | sudo tee /etc/apt/sources.list.d/doppler-cli.list"
  echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
  echo "sudo apt-get update && sudo apt-get install doppler"
  sudo apt-get update && sudo apt-get install doppler
fi

# Gotop
if [ -x "$(command -v gotop)" ]; then
  : # gotop already setup
else
  echo "bash <(curl -s \"https://raw.githubusercontent.com/productmoney/docker_server_setup/main/monitors/gotop-setup.sh\")"
  bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/monitors/gotop-setup.sh")
fi

# Authorized Keys
section_split curl https://github.com/dhigginbotham.keys >> ~/.ssh/authorized_keys && curl https://github.com/goban.keys >> ~/.ssh/authorized_keys
mkdir -p ~/.ssh \
  && curl https://github.com/dhigginbotham.keys >> ~/.ssh/authorized_keys \
  && curl https://github.com/goban.keys >> ~/.ssh/authorized_keys

# bat better cat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Rust programs and lang
curl https://sh.rustup.rs -sSf | sh

# delta diff
cargo install git-delta

# exa ls
cargo install exa

# dust du
cargo install du-dust

# ripgrep grep recursive
cargo install ripgrep

# mcfly term search
mkdir -p ~/src
cd ~/src || exit 1
git clone https://github.com/cantino/mcfly
cd mcfly || exit 1
cargo install --path .
cd "$HOME" || exit 1

# choose splits
cargo install choose

# sd find and replace
cargo install sd

# cheat hints
sudo apt-get install golang-go
go get -u github.com/cheat/cheat/cmd/cheat

# nvm
curl -o- -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install stable

# tldr hints
npm install -g tldr

# hyperfine
cargo install hyperfine

# gping
cargo install gping

# procs
cargo install procs

# zoxide
#curl -sS https://webinstall.dev/zoxide | bash

# micro
curl https://getmic.ro | bash
mv micro "$HOME/.local/bin"

source "$HOME/.zshrc"

