#!/bin/bash
set -euo pipefail

REPO_ROOT=$1
YOUR_DOMAIN=$2

DEV_ROOT=/var/dev
SRC_ROOT=$REPO_ROOT/src

echo
echo "Started containers setup."
echo

echo "DEV_ROOT: $DEV_ROOT"
echo "SRC_ROOT: $SRC_ROOT"
echo

source ports_prefix.ini

# GOGS

echo "Setting up Gogs..."
echo "https://gogs.io/"
echo

GOGS_ROOT=$DEV_ROOT/gogs
GOGS_DATA=$GOGS_ROOT/data
GOGS_MYSQL_DATA=$GOGS_ROOT/mysql/data
GOGS_SSH_PORT=${GIT_PORTS_PREFIX}22
GOGS_HTTP_PORT=${GIT_PORTS_PREFIX}80
GOGS_MYSQL_PORT=${GIT_PORTS_PREFIX}36

mkdir -p $GOGS_DATA
mkdir -p $GOGS_MYSQL_DATA

echo "Gogs volume mounts:"
echo "GOGS_DATA: $GOGS_DATA"
echo "GOGS_MYSQL_DATA: $GOGS_MYSQL_DATA"
echo "GOGS_SSH_PORT: $GOGS_SSH_PORT"
echo
echo "Gogs ports:"
echo "GOGS_HTTP_PORT: $GOGS_HTTP_PORT"
echo "GOGS_MYSQL_PORT: $GOGS_MYSQL_PORT"
echo

GIT_SRC=$SRC_ROOT/git
cp $GIT_SRC/env.tmpl $GIT_SRC/.env
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_DATA|'"$GOGS_DATA"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_MYSQL_DATA|'"$GOGS_MYSQL_DATA"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_SSH_PORT|'"$GOGS_SSH_PORT"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_HTTP_PORT|'"$GOGS_HTTP_PORT"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_MYSQL_PORT|'"$GOGS_MYSQL_PORT"'|g' {} \;

echo "Created .env file at '$GIT_SRC'."
echo

echo "Completed Gogs setup."
echo


# PROGET

echo "Setting up ProGet..."
echo "https://inedo.com/proget"
echo

PROGET_ROOT=$DEV_ROOT/proget
PROGET_PACKAGES=$PROGET_ROOT/packages
PROGET_EXTENSIONS=$PROGET_ROOT/extensions
PROGET_CONFIG=$PROGET_ROOT/config
PROGET_POSTGRESQL_DATA=$PROGET_ROOT/postgresql/data
PROGET_HTTP_PORT=${PACKAGES_PORTS_PREFIX}80
PROGET_POSTGRESQL_PORT=${PACKAGES_PORTS_PREFIX}32

mkdir -p $PROGET_PACKAGES
mkdir -p $PROGET_EXTENSIONS
mkdir -p $PROGET_CONFIG
mkdir -p $PROGET_POSTGRESQL_DATA

echo "ProGet volume mounts:"
echo "PROGET_PACKAGES: $PROGET_PACKAGES"
echo "PROGET_EXTENSIONS: $PROGET_EXTENSIONS"
echo "PROGET_CONFIG: $PROGET_CONFIG"
echo "PROGET_POSTGRESQL_DATA: $PROGET_POSTGRESQL_DATA"
echo
echo "ProGet ports:"
echo "PROGET_HTTP_PORT: $PROGET_HTTP_PORT"
echo "PROGET_POSTGRESQL_PORT: $PROGET_POSTGRESQL_PORT"
echo

PACKAGES_SRC=$SRC_ROOT/packages
cp $PACKAGES_SRC/env.tmpl $PACKAGES_SRC/.env
find $PACKAGES_SRC -type f -name '.env' -exec sed -i -e 's|@PROGET_PACKAGES|'"$PROGET_PACKAGES"'|g' {} \;
find $PACKAGES_SRC -type f -name '.env' -exec sed -i -e 's|@PROGET_EXTENSIONS|'"$PROGET_EXTENSIONS"'|g' {} \;
find $PACKAGES_SRC -type f -name '.env' -exec sed -i -e 's|@PROGET_CONFIG|'"$PROGET_CONFIG"'|g' {} \;
find $PACKAGES_SRC -type f -name '.env' -exec sed -i -e 's|@PROGET_POSTGRESQL_DATA|'"$PROGET_POSTGRESQL_DATA"'|g' {} \;
find $PACKAGES_SRC -type f -name '.env' -exec sed -i -e 's|@PROGET_HTTP_PORT|'"$PROGET_HTTP_PORT"'|g' {} \;
find $PACKAGES_SRC -type f -name '.env' -exec sed -i -e 's|@PROGET_POSTGRESQL_PORT|'"$PROGET_POSTGRESQL_PORT"'|g' {} \;

echo "Created .env file at '$PACKAGES_SRC'."
echo

echo "Completed ProGet setup."
echo

# DOCKER REGISTRY

echo "Setting up Docker registry..."
echo "https://hub.docker.com/_/registry"
echo "https://joxit.dev/docker-registry-ui"
echo

REGISTRY_ROOT=$DEV_ROOT/registry
REGISTRY_SECRETS=$REGISTRY_ROOT/secrets.ini
REGISTRY_DATA=$REGISTRY_ROOT/data
REGISTRY_CONFIG=$REGISTRY_ROOT/config
REGISTRY_PORT=${REGISTRY_PORTS_PREFIX}50
REGISTRY_UI_PORT=${REGISTRY_PORTS_PREFIX}80

mkdir -p $REGISTRY_DATA
mkdir -p $REGISTRY_CONFIG

if test ! -f "$REGISTRY_SECRETS"; then
  REGISTRY_USER=registry
  REGISTRY_USER_PASSWORD=$(openssl rand 16 -hex)
  echo "REGISTRY_USER=$REGISTRY_USER" >> $REGISTRY_SECRETS
  echo "REGISTRY_USER_PASSWORD=$REGISTRY_USER_PASSWORD" >> $REGISTRY_SECRETS
fi

source $REGISTRY_SECRETS

REGISTRY_SRC=$SRC_ROOT/registry

htpasswd -bc -C 16 $REGISTRY_SRC/htpasswd $REGISTRY_USER $REGISTRY_USER_PASSWORD
cp $REGISTRY_SRC/config.tmpl $REGISTRY_SRC/config.yml
find $REGISTRY_SRC -type f -name 'config.yml' -exec sed -i -e 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' {} \;

cp $REGISTRY_SRC/config.yml $REGISTRY_CONFIG/config.yml
cp $REGISTRY_SRC/htpasswd $REGISTRY_CONFIG/htpasswd

cp $REGISTRY_SRC/env.tmpl $REGISTRY_SRC/.env
find $REGISTRY_SRC -type f -name '.env' -exec sed -i -e 's|@REGISTRY_DATA|'"$REGISTRY_DATA"'|g' {} \;
find $REGISTRY_SRC -type f -name '.env' -exec sed -i -e 's|@REGISTRY_CONFIG|'"$REGISTRY_CONFIG"'|g' {} \;
find $REGISTRY_SRC -type f -name '.env' -exec sed -i -e 's|@REGISTRY_PORT|'"$REGISTRY_PORT"'|g' {} \;
find $REGISTRY_SRC -type f -name '.env' -exec sed -i -e 's|@REGISTRY_UI_PORT|'"$REGISTRY_UI_PORT"'|g' {} \;

echo "Docker registry mouns:"
echo "REGISTRY_DATA: $REGISTRY_DATA"
echo "REGISTRY_DATA: $REGISTRY_CONFIG"
echo
echo "Docker registry ports:"
echo "REGISTRY_PORT: $REGISTRY_PORT"
echo "REGISTRY_UI_PORT: $REGISTRY_UI_PORT"
echo
echo "Docker registry secrets:"
echo "User: $REGISTRY_USER"
echo "Password: $REGISTRY_USER_PASSWORD"

echo "Created '.env' file at '$REGISTRY_SRC'."
echo

echo "Completed Docker registry setup."
echo

# VAULT

echo "Setting up Vault..."
echo "https://www.vaultproject.io/"
echo

VAULT_ROOT=$DEV_ROOT/vault
VAULT_CONFIG=$VAULT_ROOT/config
VAULT_LOGS=$VAULT_ROOT/logs
VAULT_CONSUL_CONFIG=$VAULT_ROOT/consul/config
VAULT_CONSUL_DATA=$VAULT_ROOT/consul/data
VAULT_PORT=${VAULT_PORTS_PREFIX}80
CONSUL_PORT=${VAULT_PORTS_PREFIX}85

mkdir -p $VAULT_CONFIG
mkdir -p $VAULT_LOGS
mkdir -p $VAULT_CONSUL_CONFIG
mkdir -p $VAULT_CONSUL_DATA

VAULT_SRC=$SRC_ROOT/vault
cp $VAULT_SRC/config/vault/config.hcl $VAULT_CONFIG/config.hcl
cp $VAULT_SRC/config/consul/config.json $VAULT_CONSUL_CONFIG/config.json

cp $VAULT_SRC/env.tmpl $VAULT_SRC/.env
find $VAULT_SRC -type f -name '.env' -exec sed -i -e 's|@VAULT_CONFIG|'"$VAULT_CONFIG"'|g' {} \;
find $VAULT_SRC -type f -name '.env' -exec sed -i -e 's|@VAULT_LOGS|'"$VAULT_LOGS"'|g' {} \;
find $VAULT_SRC -type f -name '.env' -exec sed -i -e 's|@VAULT_CONSUL_CONFIG|'"$VAULT_CONSUL_CONFIG"'|g' {} \;
find $VAULT_SRC -type f -name '.env' -exec sed -i -e 's|@VAULT_CONSUL_DATA|'"$VAULT_CONSUL_DATA"'|g' {} \;
find $VAULT_SRC -type f -name '.env' -exec sed -i -e 's|@VAULT_PORT|'"$VAULT_PORT"'|g' {} \;
find $VAULT_SRC -type f -name '.env' -exec sed -i -e 's|@CONSUL_PORT|'"$CONSUL_PORT"'|g' {} \;

echo "Vault volume mounts:"
echo "VAULT_CONFIG: $VAULT_CONFIG"
echo "VAULT_LOGS: $VAULT_LOGS"
echo "VAULT_CONSUL_CONFIG: $VAULT_CONSUL_CONFIG"
echo "VAULT_CONSUL_DATA: $VAULT_CONSUL_DATA"
echo
echo "Vault ports:"
echo "VAULT_PORT: $VAULT_PORT"
echo "CONSUL_PORT: $CONSUL_PORT"
echo
echo "Configuration files:"
echo "Vault: '$VAULT_CONFIG/config.hcl'."
echo "Consul: '$VAULT_CONSUL_CONFIG/config.json'."
echo

echo "Created '.env' file at '$VAULT_SRC'."
echo

echo "Completed Vault setup."
echo


# DRONE

echo "Setting up Drone..."
echo "https://drone.io/"
echo

DRONE_ROOT=$DEV_ROOT/drone
DRONE_DATA=$DRONE_ROOT/data
DRONE_SECRETS=$DRONE_ROOT/secrets.ini
DRONE_MYSQL_DATA=$DRONE_ROOT/mysql/data
DRONE_HTTP_PORT=${CI_PORTS_PREFIX}80
DRONE_MYSQL_PORT=${CI_PORTS_PREFIX}36
DRONE_VAULT_PLUGIN_PORT=${CI_PORTS_PREFIX}00

mkdir -p $DRONE_DATA
mkdir -p $DRONE_MYSQL_DATA

if test ! -f "$DRONE_SECRETS"; then
  DRONE_ADMIN_USERNAME=ciadmin
  DRONE_ADMIN_TOKEN=$(openssl rand 16 -hex)
  echo "DRONE_ADMIN_USERNAME=$DRONE_ADMIN_USERNAME" >> $DRONE_SECRETS
  echo "DRONE_ADMIN_TOKEN=$DRONE_ADMIN_TOKEN" >> $DRONE_SECRETS
  
  DRONE_GIT_USERNAME=ciagent
  DRONE_GIT_PASSWORD=$(openssl rand 8 -hex)
  DRONE_SECRET_KEY=$(openssl rand 16 -hex)
  echo "DRONE_GIT_USERNAME=$DRONE_GIT_USERNAME" >> $DRONE_SECRETS
  echo "DRONE_GIT_PASSWORD=$DRONE_GIT_PASSWORD" >> $DRONE_SECRETS
  echo "DRONE_SECRET_KEY=$DRONE_SECRET_KEY" >> $DRONE_SECRETS
fi

source $DRONE_SECRETS

CI_SRC=$SRC_ROOT/ci
cp $CI_SRC/env.tmpl $CI_SRC/.env

find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_ADMIN_USERNAME|'"$DRONE_ADMIN_USERNAME"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_ADMIN_TOKEN|'"$DRONE_ADMIN_TOKEN"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_GIT_USERNAME|'"$DRONE_GIT_USERNAME"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_GIT_PASSWORD|'"$DRONE_GIT_PASSWORD"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_SECRET_KEY|'"$DRONE_SECRET_KEY"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_DATA|'"$DRONE_DATA"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_MYSQL_DATA|'"$DRONE_MYSQL_DATA"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_HTTP_PORT|'"$DRONE_HTTP_PORT"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_MYSQL_PORT|'"$DRONE_MYSQL_PORT"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_VAULT_PLUGIN_PORT|'"$DRONE_VAULT_PLUGIN_PORT"'|g' {} \;

echo "Drone volume mounts:"
echo "DRONE_DATA: $DRONE_DATA"
echo "DRONE_MYSQL_DATA: $DRONE_MYSQL_DATA"
echo
echo "Drone ports:"
echo "DRONE_HTTP_PORT: $DRONE_HTTP_PORT"
echo "DRONE_MYSQL_PORT: $DRONE_MYSQL_PORT"
echo "DRONE_VAULT_PLUGIN_PORT: $DRONE_VAULT_PLUGIN_PORT"
echo "Drone secrets:"
echo
echo "Admin user: $DRONE_ADMIN_USERNAME/$DRONE_ADMIN_TOKEN"
echo "Git user: $DRONE_GIT_USERNAME/$DRONE_GIT_PASSWORD"
echo "DRONE_SECRET_KEY: '$DRONE_SECRET_KEY'"
echo

echo "Created '.env' file at '$CI_SRC'."
echo

echo "Completed Drone CI setup."
echo

echo "Completed containers setup."
echo
