ORGANIZATION="productmoney"
GH_CONTENT="https://raw.githubusercontent.com/$ORGANIZATION"
export DEBIAN_FRONTEND=noninteractive
DEBIAN_FRONTEND=noninteractive

export PROJECT_NAME="ipv6er"
export PROJECT_DIR="$HOME/$PROJECT_NAME"
export ENV_FILE="$PROJECT_DIR/.env"

export DIVIDER=$(seq -s= $(($COLUMNS-1))|tr -d '[:digit:]')
function section_split() { printf "\n$DIVIDER\n%s\n\n" "$1" ; }
function section_split_plain() { printf "\n$DIVIDER\n" ; }

section_split "Welcome to $PROJECT_NAME installer setup!"

sysctl -w vm.max_map_count=1677720
timedatectl set-timezone America/Denver

IP4=$(curl -4 -s icanhazip.com)
section_split "IPV4 address: ${IP4}"

section_split "apt-get update"
apt-get update

section_split "apt-get upgrade -y"
apt-get upgrade -y

section_split "apt-get install -y --no-install-recommends curl jq ifupdown git ntp apt-transport-https ca-certificates dnsutils apt-transport-https gnupg lsb-release"
apt-get install -y --no-install-recommends curl jq git ntp ifupdown apt-transport-https ca-certificates dnsutils apt-transport-https gnupg lsb-release

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

if test -f "$DOCKER_KEYRING"; then
  echo "$DOCKER_KEYRING already exists"
else
  echo "$DOCKER_KEYRING does not exist"
  echo "url -fsSL $GPG_LOCATION | gpg --dearmor -o $DOCKER_KEYRING"
  curl -fsSL "$GPG_LOCATION" | gpg --dearmor -o "$DOCKER_KEYRING"
fi

echo "deb [arch=amd64 signed-by=$DOCKER_KEYRING] $DOCKER_DOWNLOAD_LOCATION $LSBCS $DOCKER_VERSION | tee $DOCKER_SOURCES_LIST > /dev/null"
echo "deb [arch=amd64 signed-by=$DOCKER_KEYRING] $DOCKER_DOWNLOAD_LOCATION $LSBCS $DOCKER_VERSION"  | tee "$DOCKER_SOURCES_LIST" > /dev/null
  
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

# nvm
section_split "nvm and node setup"
echo "curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash"
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
echo "export NVM_DIR=$HOME/.nvm"
export NVM_DIR="$HOME/.nvm"
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'  # This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
echo "nvm install 16"
nvm install 16
echo "nvm use 16"
nvm use 16
echo "nvm run default --version"
nvm run default --version
echo "npm install pm2 -g"
npm install pm2 -g

section_split "apt autoremove"
apt autoremove

echo "cd $HOME"
cd "$HOME"

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

# echo "What is your github login email address?"
# read -r GITHUB_EMAIL
# if [ -z "$GITHUB_EMAIL" ]; then
#   echo "Error: no GITHUB_EMAIL"
#   exit 1
# fi
GITHUB_EMAIL='everynothing@gmail.com'

# echo "What is your github username?"
# read -r GITHUB_USERNAME
# if [ -z "$GITHUB_USERNAME" ]; then
#   echo "Error: no GITHUB_USERNAME"
#   exit 1
# fi
GITHUB_USERNAME='goban'

# echo "What is your organization name?"
# read -r ORG_NAME
# if [ -z "$ORG_NAME" ]; then
#   echo "Error: no ORG_NAME"
#   exit 1
# fi
ORG_NAME="productmoney"

if test -f "$ENV_FILE"; then
  echo "$ENV_FILE already exists"
else
  echo "$ENV_FILE does not exist"
  echo "What is your doppler token?"
  read -r DOPPLER_TOKEN
  if [ -z "$DOPPLER_TOKEN" ]; then
    echo "Error: no DOPPLER_TOKEN"
    exit 1
  fi
fi

# Doppler
echo "-sLf --retry 3 --tlsv1.2 --proto \"=https\" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -"
curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo apt-key add -
echo "\"deb https://packages.doppler.com/public/cli/deb/debian any-version main\" | sudo tee /etc/apt/sources.list.d/doppler-cli.list"
echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
echo "sudo apt-get update && sudo apt-get install doppler"
sudo apt-get update && sudo apt-get install doppler

# Gotop
if [ -x "$(command -v gotop)" ]; then
  : # gotop already setup
else
  echo "bash <(curl -s \"https://raw.githubusercontent.com/productmoney/docker_server_setup/main/monitors/gotop-setup.sh\")"
  bash <(curl -s "https://raw.githubusercontent.com/productmoney/docker_server_setup/main/monitors/gotop-setup.sh")
fi

HOSTNAME=$(hostname)
echo "Key will have the name: $HOSTNAME (from using command hostname)"

if test -f "$SSH_ID_RSA"; then
  echo "$SSH_ID_RSA already exists"
else
  echo "What is your github auth token?"
  echo "(If you don't have one, can create at https://github.com/settings/tokens being sure to include the right permissions)"
  read -r GITHUB_AUTH_TOKEN
  if [ -z "$GITHUB_AUTH_TOKEN" ]; then
    echo "Error: no GITHUB_AUTH_TOKEN"
    exit 1
  fi

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
fi

mkdir -p ~/.config/git
section_split "Writing ~/.config/git/.gitignore_global"
cat > "$HOME/.config/git/.gitignore_global" << EOL
.env
tmp
node_modules
EOL

section_split "Writing .gitconfig"
cat > "$GITCONFIG" << EOL
[user]
	email = $GITHUB_EMAIL
[core]
  mergeoptions = -docker_3proxy_installer
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
  status = autodocker_3proxy_installer
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

mkdir -p ~/.ssh \
    && curl https://github.com/dhigginbotham.keys >> ~/.ssh/authorized_keys \
    && curl https://github.com/goban.keys >> ~/.ssh/authorized_keys

eval "$(ssh-agent)"

section_split "Cloning project"

echo "cd $HOME"
cd "$HOME"
test -d "$PROJECT_DIR"; then
  echo "echo $PROJECT_DIR already exists"
else
  echo "git clone git@github.com:productmoney/$PROJECT_NAME.git"
  git clone "git@github.com:productmoney/$PROJECT_NAME.git"
fi

echo "cd $HOME/$PROJECT_NAME"
cd "$HOME/$PROJECT_NAME"

LOGSD="/root/ipv6er/logs"
echo "mkdir -p $HOME/$PROJECT_NAME/logs"
mkdir -p "$HOME/$PROJECT_NAME/logs"
echo "mkdir -p $HOME/$PROJECT_NAME/generated"
mkdir -p "$HOME/$PROJECT_NAME/generated"
echo "mkdir -p $HOME/$PROJECT_NAME/3proxy"
mkdir -p "$HOME/$PROJECT_NAME/3proxy"
echo "touch $LOGSD/3proxy.log"
touch "$LOGSD/3proxy.log $LOGSD/whitelist.log $LOGSD/reporting.log $LOGSD/iptables.log"
echo "touch $LOGSD/3proxy.log $LOGSD/whitelist.log $LOGSD/reporting.log $LOGSD/iptables.log"
touch /root/ipv6er/generated/3proxy.cfg

npm install

if test -f "$ENV_FILE"; then
  echo "$ENV_FILE already exists"
else
  section_split "Writing .env"
  echo "DOPPLER_TOKEN=$DOPPLER_TOKEN"
  echo "TZ=America/Denver"
  cat > "$ENV_FILE" << EOL
DOPPLER_TOKEN=$DOPPLER_TOKEN
TZ="America/Denver"
export DOPPLER_TOKEN
export TZ
EOL
fi

shutdown -r now
