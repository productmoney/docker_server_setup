ORGANIZATION="productmoney"
GH_CONTENT="https://raw.githubusercontent.com/$ORGANIZATION"
export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

function section_split_plain() {
  printf "\n----------------------------------------\n"
}

section_split "Welcome to docker server installer setup!"

IP4=$(curl -4 -s icanhazip.com)
section_split "IPV4 address: ${IP4}"

section_split "apt-get update"
apt-get update

section_split "apt-get upgrade -y"
apt-get upgrade -y

section_split "apt-get install -y --no-install-recommends curl jq ifupdown git ntp zsh apt-transport-https ca-certificates dnsutils apt-transport-https gnupg lsb-release"
apt-get install -y --no-install-recommends curl jq git ntp zsh ifupdown apt-transport-https ca-certificates dnsutils apt-transport-https gnupg lsb-release

section_split "Setting file limits"

LIMITS_FILE="/etc/security/limits.conf"
FILE_LIMIT="97816"

if grep -q "$FILE_LIMIT" "$LIMITS_FILE"; then
  : # File limits already written
else
  echo "Appended to $LIMITS_FILE:"
  printf "* hard nofile %s\n* soft nofile %s\n" "$FILE_LIMIT" "$FILE_LIMIT" | sudo tee -a "$LIMITS_FILE"
fi

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

echo "curl -fsSL $GPG_LOCATION | gpg --dearmor -o $DOCKER_KEYRING"
curl -fsSL "$GPG_LOCATION" | gpg --dearmor -o "$DOCKER_KEYRING"

echo "deb [arch=amd64 signed-by=$DOCKER_KEYRING] $DOCKER_DOWNLOAD_LOCATION $LSBCS $DOCKER_VERSION | tee $DOCKER_SOURCES_LIST > /dev/null"
echo \
  "deb [arch=amd64 signed-by=$DOCKER_KEYRING] \
  $DOCKER_DOWNLOAD_LOCATION \
  $LSBCS $DOCKER_VERSION" \
  | tee "$DOCKER_SOURCES_LIST" > /dev/null
  
section_split "apt-get update -y"
apt-get update -y

section_split "apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io"
apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io

section_split "docker run hello-world"
docker run hello-world

section_split "usermod -aG docker $USER"
usermod -aG docker "$USER"

section_split "Setting up docker-compose"

UNS=$(uname -s)
UNM=$(uname -m)
DOCKER_COMPOSE_LOCATION="https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$UNS-$UNM"
DOCKER_COMPOSE_INSTALL_LOCATION="/usr/local/bin/docker-compose"
echo "curl -L $DOCKER_COMPOSE_LOCATION -o $DOCKER_COMPOSE_INSTALL_LOCATION"
curl -L "$DOCKER_COMPOSE_LOCATION" -o "$DOCKER_COMPOSE_INSTALL_LOCATION"
echo "chmod +x $DOCKER_COMPOSE_INSTALL_LOCATION"
chmod +x "$DOCKER_COMPOSE_INSTALL_LOCATION"

section_split "docker-compose --version"
docker-compose --version

# section_split "ohmyzsh setup"

# echo 'bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/ohmyzsh-setup.sh)'
# bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/ohmyzsh-setup.sh")

# echo 'bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/zsh_config.sh")'
# bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/ohmyzsh/zsh_config.sh")

# echo 'source ~/.zshrc &>/dev/null'
# source ~/.zshrc &>/dev/null

cd $HOME

section_split "Github setup"

SSH_DIR="$HOME/.ssh"
SSH_ID_RSA="$SSH_DIR/id_rsa"
SSH_ID_RSA_PUB="$SSH_ID_RSA.pub"
SSH_CONFIG="$SSH_DIR/config"
GITCONFIG="$HOME/.gitconfig"
GITHUB_KEYS="https://api.github.com/user/keys"

echo "mkdir -p $SSH_DIR"
mkdir -p "$SSH_DIR"

section_split "auth setup"

AUTH_FOLDER="$HOME/auth"
DEFAULT_AUTH_FILE="$AUTH_FOLDER/default_auth.txt"

echo "mkdir -p $AUTH_FOLDER"
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
  
  # echo "What is your github login email address?"
  # read -r GH_EMAIL
  # if [ -z "$GH_EMAIL" ]; then
  #   echo "Error: no GH_EMAIL"
  #   exit 1
  # fi
  GH_EMAIL='everynothing@gmail.com'
  
  # echo "What is your github username?"
  # read -r GH_USERNAME
  # if [ -z "$GH_USERNAME" ]; then
  #   echo "Error: no GH_USERNAME"
  #   exit 1
  # fi
  GH_USERNAME='goban'
  
  echo "What is your github auth token?"
  echo "(If you don't have one, can create at https://github.com/settings/tokens being sure to include the right permissions)"
  read -r GH_AUTH_TOKEN
  if [ -z "$GH_AUTH_TOKEN" ]; then
    echo "Error: no GH_AUTH_TOKEN"
    exit 1
  fi
  
  # echo "What is your current jwt auth parent key for davs apis?"
  # read -r JWT_SIGNING_KEY
  # if [ -z "$JWT_SIGNING_KEY" ]; then
  #   echo "Error: no JWT_SIGNING_KEY"
  #   exit 1
  # fi
  JWT_SIGNING_KEY='foo'
  
  # DEFAULT_ORG_NAME="productmoney"
  # section_split "What is your github organization (like in the url)?"
  # echo "If blank, will default to $DEFAULT_ORG_NAME"
  # read -r ORG_NAME
  # if [ -z "$ORG_NAME" ]; then
  #   ORG_NAME="$DEFAULT_ORG_NAME"
  # fi
  ORG_NAME="productmoney"
  
  DF_AUTH_FILE_TEXT="GH_EMAIL=$GH_EMAIL
GH_USERNAME=$GH_USERNAME
ORG_NAME=$ORG_NAME
GH_AUTH_TOKEN=$GH_AUTH_TOKEN
JWT_SIGNING_KEY=$JWT_SIGNING_KEY"
  
  section_split "Writing $DEFAULT_AUTH_FILE with:"
  echo "$DF_AUTH_FILE_TEXT" | tee -a "$DEFAULT_AUTH_FILE"

fi

echo "$DEFAULT_AUTH_FILE written as:"
cat "$DEFAULT_AUTH_FILE"

section_split "Resuming github setup"

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

section_split "Cloning project"

echo "git clone https://github.com/productmoney/docker_3proxy_installer.git"
git clone "https://github.com/productmoney/docker_3proxy_installer.git"

cd docker_3proxy_installer

#Doppler
echo "-sLf --retry 3 --tlsv1.2 --proto \"=https\" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -"
curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -
echo "\"deb https://packages.doppler.com/public/cli/deb/debian any-version main\" | sudo tee /etc/apt/sources.list.d/doppler-cli.list"
echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
echo "sudo apt-get update && sudo apt-get install doppler"
sudo apt-get update && sudo apt-get install doppler

if [ -x "$(command -v gotop)" ]; then
  : # gotop already setup
else
  echo "bash <(curl -s \"https://raw.githubusercontent.com/productmoney/docker_server_setup/main/monitors/gotop-setup.sh\")"
  bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/monitors/gotop-setup.sh")
fi
