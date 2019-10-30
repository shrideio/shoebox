#!/bin/bash
set -euo pipefail

BOX_ROOT=$1
YOUR_DOMAIN=$2
PORTS_PREFIX=$3

# DRONE

CI_SRC=$(dirname "$0")

echo "Setting up Drone..."
echo "https://drone.io/"
echo

DRONE_ROOT=$DEV_ROOT/drone
DRONE_DATA=$DRONE_ROOT/data
DRONE_SECRETS=$DRONE_ROOT/secrets.ini
DRONE_POSTGRESQL_DATA=$DRONE_ROOT/postgresql/data
DRONE_HTTP_PORT=${PORTS_PREFIX}80
DRONE_POSTGRESQL_PORT=${PORTS_PREFIX}32
DRONE_VAULT_PLUGIN_PORT=${PORTS_PREFIX}30

mkdir -p $DRONE_DATA
mkdir -p $DRONE_POSTGRESQL_DATA

if test ! -f "$DRONE_SECRETS"; then
  DRONE_ADMIN_USERNAME=ciadmin
  DRONE_ADMIN_TOKEN=$(openssl rand 16 -hex)
  echo "DRONE_ADMIN_USERNAME=$DRONE_ADMIN_USERNAME" >> $DRONE_SECRETS
  echo "DRONE_ADMIN_TOKEN=$DRONE_ADMIN_TOKEN" >> $DRONE_SECRETS
  
  DRONE_GIT_USERNAME=ciagent
  DRONE_GIT_PASSWORD=$(openssl rand 8 -hex)
  DRONE_SECRET=$(openssl rand 16 -hex)
  DRONE_RPC_SECRET=$(openssl rand 16 -hex)
  echo "DRONE_GIT_USERNAME=$DRONE_GIT_USERNAME" >> $DRONE_SECRETS
  echo "DRONE_GIT_PASSWORD=$DRONE_GIT_PASSWORD" >> $DRONE_SECRETS
  echo "DRONE_SECRET=$DRONE_SECRET" >> $DRONE_SECRETS
  echo "DRONE_RPC_SECRET=$DRONE_RPC_SECRET" >> $DRONE_SECRETS

  DRONE_POSTGRESQL_DATABASE=drone
  DRONE_POSTGRESQL_USER=drone
  DRONE_POSTGRESQL_PASSWORD=$(openssl rand 16 -hex)
  echo "DRONE_POSTGRESQL_DATABASE=$DRONE_POSTGRESQL_DATABASE" >> $DRONE_SECRETS
  echo "DRONE_POSTGRESQL_USER=$DRONE_POSTGRESQL_USER" >> $DRONE_SECRETS
  echo "DRONE_POSTGRESQL_PASSWORD=$DRONE_POSTGRESQL_PASSWORD" >> $DRONE_SECRETS
fi

source $DRONE_SECRETS

cp $CI_SRC/env.tmpl $CI_SRC/.env
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_ADMIN_USERNAME|'"$DRONE_ADMIN_USERNAME"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_ADMIN_TOKEN|'"$DRONE_ADMIN_TOKEN"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_GIT_USERNAME|'"$DRONE_GIT_USERNAME"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_GIT_PASSWORD|'"$DRONE_GIT_PASSWORD"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_SECRET|'"$DRONE_SECRET"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_RPC_SECRET|'"$DRONE_RPC_SECRET"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_DATA|'"$DRONE_DATA"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_POSTGRESQL_DATA|'"$DRONE_POSTGRESQL_DATA"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_HTTP_PORT|'"$DRONE_HTTP_PORT"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_VAULT_PLUGIN_PORT|'"$DRONE_VAULT_PLUGIN_PORT"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_POSTGRESQL_PORT|'"$DRONE_POSTGRESQL_PORT"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_POSTGRESQL_DATABASE|'"$DRONE_POSTGRESQL_DATABASE"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_POSTGRESQL_USER|'"$DRONE_POSTGRESQL_USER"'|g' {} \;
find $CI_SRC -type f -name '.env' -exec sed -i -e 's|@DRONE_POSTGRESQL_PASSWORD|'"$DRONE_POSTGRESQL_PASSWORD"'|g' {} \;

echo "Drone volume mounts:"
echo "DRONE_DATA: $DRONE_DATA"
echo "DRONE_POSTGRESQL_DATA: $DRONE_POSTGRESQL_DATA"
echo
echo "Drone ports:"
echo "DRONE_HTTP_PORT: $DRONE_HTTP_PORT"
echo "DRONE_POSTGRESQL_PORT: $DRONE_POSTGRESQL_PORT"
echo "DRONE_VAULT_PLUGIN_PORT: $DRONE_VAULT_PLUGIN_PORT"
echo
echo "Drone secrets:"
echo "DRONE_ADMIN_USERNAME/DRONE_ADMIN_TOKEN: $DRONE_ADMIN_USERNAME/$DRONE_ADMIN_TOKEN"
echo "DRONE_GIT_USERNAME/DRONE_GIT_PASSWORD: $DRONE_GIT_USERNAME/$DRONE_GIT_PASSWORD"
echo "DRONE_SECRET: '$DRONE_SECRET'"
echo "DRONE_RPC_SECRET: '$DRONE_RPC_SECRET'"
echo "DRONE_POSTGRESQL_DATABASE: $DRONE_POSTGRESQL_DATABASE"
echo "DRONE_POSTGRESQL_USER: $DRONE_POSTGRESQL_USER"
echo "DRONE_POSTGRESQL_PASSWORD: $DRONE_POSTGRESQL_PASSWORD"
echo

echo "Created '.env' file at '$CI_SRC'."
echo

echo "Completed Drone CI setup."
echo