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


# GOGS

echo "Setting up Gogs..."
echo "https://gogs.io/"
echo

GOGS_ROOT=$DEV_ROOT/gogs
GOGS_DATA=$GOGS_ROOT/data
GOGS_MYSQL_DATA=$GOGS_ROOT/mysql/data

mkdir -p $GOGS_DATA
mkdir -p $GOGS_MYSQL_DATA

echo "Created volume mounts for Gogs."
echo "GOGS_DATA: $GOGS_DATA"
echo "GOGS_MYSQL_DATA: $GOGS_MYSQL_DATA"
echo

GIT_SRC=$SRC_ROOT/git
cp $GIT_SRC/env.tmpl $GIT_SRC/.env
find $GIT_SRC -type f -name '*.env' -exec sed -i -e 's|@GOGS_DATA|'"$GOGS_DATA"'|g' {} \;
find $GIT_SRC -type f -name '*.env' -exec sed -i -e 's|@GOGS_MYSQL_DATA|'"$GOGS_MYSQL_DATA"'|g' {} \;

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
PROGET_POSTGRESQL_DATA=$PROGET_ROOT/postgresql/data

mkdir -p $PROGET_PACKAGES
mkdir -p $PROGET_EXTENSIONS
mkdir -p $PROGET_POSTGRESQL_DATA

echo "Created volume mounts for ProGet."
echo "PROGET_PACKAGES: $PROGET_PACKAGES"
echo "PROGET_EXTENSIONS: $PROGET_EXTENSIONS"
echo "PROGET_POSTGRESQL_DATA: $PROGET_POSTGRESQL_DATA"
echo

REGISTRY_SRC=$SRC_ROOT/registry
cp $REGISTRY_SRC/env.tmpl $REGISTRY_SRC/.env
find $REGISTRY_SRC -type f -name '*.env' -exec sed -i -e 's|@PROGET_PACKAGES|'"$PROGET_PACKAGES"'|g' {} \;
find $REGISTRY_SRC -type f -name '*.env' -exec sed -i -e 's|@PROGET_EXTENSIONS|'"$PROGET_EXTENSIONS"'|g' {} \;
find $REGISTRY_SRC -type f -name '*.env' -exec sed -i -e 's|@PROGET_POSTGRESQL_DATA|'"$PROGET_POSTGRESQL_DATA"'|g' {} \;

echo "Created .env file at '$REGISTRY_SRC'."
echo

echo "Completed ProGet setup."
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

mkdir -p $VAULT_CONFIG
mkdir -p $VAULT_LOGS
mkdir -p $VAULT_CONSUL_CONFIG
mkdir -p $VAULT_CONSUL_DATA

echo "Created volume mounts for Vault."
echo "VAULT_CONFIG: $VAULT_CONFIG"
echo "VAULT_LOGS: $VAULT_LOGS"
echo "VAULT_CONSUL_CONFIG: $VAULT_CONSUL_CONFIG"
echo "VAULT_CONSUL_DATA: $VAULT_CONSUL_DATA"
echo

VAULT_SRC=$SRC_ROOT/vault
cp $VAULT_SRC/config/vault/config.hcl $VAULT_CONFIG/config.hcl
cp $VAULT_SRC/config/consul/config.json $VAULT_CONSUL_CONFIG/config.json

echo "Created Vault configuration file at '$VAULT_CONFIG/config.hcl'."
echo "Created Consul configuration file at '$VAULT_CONSUL_CONFIG/config.json'."
echo

cp $VAULT_SRC/env.tmpl $VAULT_SRC/.env
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_CONFIG|'"$VAULT_CONFIG"'|g' {} \;
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_LOGS|'"$VAULT_LOGS"'|g' {} \;
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_CONSUL_CONFIG|'"$VAULT_CONSUL_CONFIG"'|g' {} \;
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_CONSUL_DATA|'"$VAULT_CONSUL_DATA"'|g' {} \;

echo "Created '.env' file at '$VAULT_SRC'."
echo

echo "Completed Vault setup."
echo


# DRONE

echo "Setting up Drone CI..."
echo "https://drone.io/"
echo

DRONE_ROOT=$DEV_ROOT/drone
DRONE_DATA=$DRONE_ROOT/data
DRONE_SECRETS=$DRONE_ROOT/secrets.ini
DRONE_MYSQL_DATA=$DRONE_ROOT/mysql/data

mkdir -p $DRONE_DATA
mkdir -p $DRONE_MYSQL_DATA

echo "Created volume mounts for Drone CI."
echo "DRONE_DATA: $DRONE_DATA"
echo "DRONE_MYSQL_DATA: $DRONE_MYSQL_DATA"

if test ! -f "$DRONE_SECRETS"; then
  DRONE_ADMIN_USERNAME=ciadmin
  DRONE_ADMIN_PASSWORD=$(openssl rand 8 -hex)
  DRONE_ADMIN_TOKEN=$(openssl rand 16 -hex)
  echo "DRONE_ADMIN_USERNAME=$DRONE_ADMIN_USERNAME" >> $DRONE_SECRETS
  echo "DRONE_ADMIN_PASSWORD=$DRONE_ADMIN_PASSWORD" >> $DRONE_SECRETS
  echo "DRONE_ADMIN_TOKEN=$DRONE_ADMIN_TOKEN" >> $DRONE_SECRETS
  
  DRONE_GIT_USERNAME=ciagent
  DRONE_GIT_PASSWORD=$(openssl rand 8 -hex)
  DRONE_SECRET_KEY=$(openssl rand 16 -hex)
  echo "DRONE_GIT_USERNAME=$DRONE_GIT_USERNAME" >> $DRONE_SECRETS
  echo "DRONE_GIT_PASSWORD=$DRONE_GIT_PASSWORD" >> $DRONE_SECRETS
  echo "DRONE_SECRET_KEY=$DRONE_SECRET_KEY" >> $DRONE_SECRETS
fi

source $DRONE_SECRETS

echo "Generated secrets for Drone CI."
echo "Drone adimistartor user: $DRONE_ADMIN_USERNAME/$DRONE_ADMIN_PASSWORD"
echo "Drone git user: $DRONE_GIT_USERNAME/$DRONE_GIT_PASSWORD"
echo "Check '$DRONE_SECRETS' for more information."
echo

CI_SRC=$SRC_ROOT/ci
cp $CI_SRC/env.tmpl $CI_SRC/.env

find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_ADMIN_USERNAME|'"$DRONE_ADMIN_USERNAME"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_ADMIN_PASSWORD|'"$DRONE_ADMIN_PASSWORD"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_ADMIN_TOKEN|'"$DRONE_ADMIN_TOKEN"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_GIT_USERNAME|'"$DRONE_GIT_USERNAME"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_GIT_PASSWORD|'"$DRONE_GIT_PASSWORD"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_SECRET_KEY|'"$DRONE_SECRET_KEY"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_DATA|'"$DRONE_DATA"'|g' {} \;
find $CI_SRC -type f -name '*.env' -exec sed -i -e 's|@DRONE_MYSQL_DATA|'"$DRONE_MYSQL_DATA"'|g' {} \;

echo "Created '.env' file at '$CI_SRC'."
echo

echo "Completed Drone CI setup."
echo

echo "Completed containers setup."
echo