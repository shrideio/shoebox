#!/bin/bash
set -euo pipefail

# GOGS

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
PORTS_PREFIX=$3

GIT_SRC=$(dirname "$0")

echo "Setting up Gogs..."
echo "https://gogs.io/"
echo

GOGS_ROOT=$SHOEBOX_ROOT/gogs
GOGS_SECRETS=$GOGS_ROOT/secrets.ini
GOGS_DATA=$GOGS_ROOT/data
GOGS_POSTGRESQL_DATA=$GOGS_ROOT/postgresql/data
GOGS_SSH_PORT=${PORTS_PREFIX}22
GOGS_HTTP_PORT=${PORTS_PREFIX}80
GOGS_POSTGRESQL_PORT=${PORTS_PREFIX}32

mkdir -p $GOGS_DATA
mkdir -p $GOGS_POSTGRESQL_DATA

if test ! -f "$GOGS_SECRETS"; then
  GOGS_POSTGRESQL_DATABASE=gogs
  GOGS_POSTGRESQL_USER=gogs
  GOGS_POSTGRESQL_PASSWORD=$(openssl rand 16 -hex)
  echo "GOGS_POSTGRESQL_DATABASE=$GOGS_POSTGRESQL_DATABASE" >> $GOGS_SECRETS
  echo "GOGS_POSTGRESQL_USER=$GOGS_POSTGRESQL_USER" >> $GOGS_SECRETS
  echo "GOGS_POSTGRESQL_PASSWORD=$GOGS_POSTGRESQL_PASSWORD" >> $GOGS_SECRETS
fi

source $GOGS_SECRETS

echo "Gogs volume mounts:"
echo "GOGS_DATA: $GOGS_DATA"
echo "GOGS_POSTGRESQL_DATA: $GOGS_POSTGRESQL_DATA"
echo "GOGS_SSH_PORT: $GOGS_SSH_PORT"
echo
echo "Gogs ports:"
echo "GOGS_HTTP_PORT: $GOGS_HTTP_PORT"
echo "GOGS_POSTGRESQL_PORT: $GOGS_POSTGRESQL_PORT"
echo
echo "Gogs secrets:"
echo "GOGS_POSTGRESQL_DATABASE: $GOGS_POSTGRESQL_DATABASE"
echo "GOGS_POSTGRESQL_USER: $GOGS_POSTGRESQL_USER"
echo "GOGS_POSTGRESQL_PASSWORD: $GOGS_POSTGRESQL_PASSWORD"
echo

cp $GIT_SRC/env.tmpl $GIT_SRC/.env
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_DATA|'"$GOGS_DATA"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_POSTGRESQL_DATA|'"$GOGS_POSTGRESQL_DATA"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_SSH_PORT|'"$GOGS_SSH_PORT"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_HTTP_PORT|'"$GOGS_HTTP_PORT"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_POSTGRESQL_PORT|'"$GOGS_POSTGRESQL_PORT"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_POSTGRESQL_DATABASE|'"$GOGS_POSTGRESQL_DATABASE"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_POSTGRESQL_USER|'"$GOGS_POSTGRESQL_USER"'|g' {} \;
find $GIT_SRC -type f -name '.env' -exec sed -i -e 's|@GOGS_POSTGRESQL_PASSWORD|'"$GOGS_POSTGRESQL_PASSWORD"'|g' {} \;

echo "Created .env file at '$GIT_SRC'."
echo

echo "Completed Gogs setup."
echo