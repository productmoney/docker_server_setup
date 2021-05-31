
#UNAME=$(uname | tr "[:upper:]" "[:lower:]")
UNS=$(uname -s)
UNM=$(uname -m)
LSBCS=$(lsb_release -cs)

COMPOSE_GITHUB="https://github.com/docker/compose"
DOCKER_COMPOSE_VERSION=$(git ls-remote "$COMPOSE_GITHUB" | grep refs/tags | grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | sort --version-sort | tail -n 1)
DOCKER_COMPOSE_LOCATION="$COMPOSE_GITHUB/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$UNS-$UNM"
DOCKER_COMPOSE_INSTALL_LOCATION="/usr/local/bin/docker-compose"

function section_split() {
  printf "\n----------------------------------------\n%s\n\n" "$1"
}

section_split "curl -s -L $DOCKER_COMPOSE_LOCATION -o $DOCKER_COMPOSE_INSTALL_LOCATION"
curl -s -L "$DOCKER_COMPOSE_LOCATION" -o "$DOCKER_COMPOSE_INSTALL_LOCATION"

section_split "chmod +x $DOCKER_COMPOSE_INSTALL_LOCATION"
chmod +x "$DOCKER_COMPOSE_INSTALL_LOCATION"

section_split "docker-compose --version"
docker-compose --version
