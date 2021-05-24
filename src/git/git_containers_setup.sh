#!/bin/bash
set -euo pipefail

echo "Setting up Gogs..."
echo "https://gogs.io/"
echo


SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2

GIT_SRC=$(dirname $(realpath $0))
SRC_ROOT=$(dirname "$GIT_SRC")

source $SRC_ROOT/ports_prefix.ini
GIT_PORTS_PREFIX=${3:-$GIT_PORTS_PREFIX}

GOGS_ROOT=$SHOEBOX_ROOT/git-gogs
GOGS_SECRETS=$GOGS_ROOT/secrets.ini
GOGS_DATA=$GOGS_ROOT/data
GOGS_POSTGRESQL_DATA=$GOGS_ROOT/postgresql/data

GOGS_SSH_PORT=${GIT_PORTS_PREFIX}22
GOGS_HTTP_PORT=${GIT_PORTS_PREFIX}80
GOGS_POSTGRESQL_PORT=${GIT_PORTS_PREFIX}32

LOCALHOST="127.0.0.1"
GOGS_SSH_PORT_BINDING="$LOCALHOST:$GOGS_SSH_PORT"
GOGS_HTTP_PORT_BINDING="$LOCALHOST:$GOGS_HTTP_PORT"
GOGS_POSTGRESQL_PORT_BINDING="$LOCALHOST:$GOGS_POSTGRESQL_PORT"

mkdir -p $GOGS_DATA
mkdir -p $GOGS_POSTGRESQL_DATA

if test ! -f "$GOGS_SECRETS"; then
  GOGS_POSTGRESQL_DATABASE=gogs
  GOGS_POSTGRESQL_USER=gogs
  GOGS_POSTGRESQL_PASSWORD=$(openssl rand -hex 16 )
  echo "GOGS_POSTGRESQL_DATABASE=$GOGS_POSTGRESQL_DATABASE" >> $GOGS_SECRETS
  echo "GOGS_POSTGRESQL_USER=$GOGS_POSTGRESQL_USER" >> $GOGS_SECRETS
  echo "GOGS_POSTGRESQL_PASSWORD=$GOGS_POSTGRESQL_PASSWORD" >> $GOGS_SECRETS
fi

source $GOGS_SECRETS

GIT_ENV=$GIT_SRC/.env
cp $GIT_SRC/env.tmpl $GIT_ENV

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $GIT_ENV
sed -i 's|@GOGS_DATA$|'"$GOGS_DATA"'|g' $GIT_ENV
sed -i 's|@GOGS_POSTGRESQL_DATA$|'"$GOGS_POSTGRESQL_DATA"'|g' $GIT_ENV
sed -i 's|@GOGS_SSH_PORT_BINDING$|'"$GOGS_SSH_PORT_BINDING"'|g' $GIT_ENV
sed -i 's|@GOGS_HTTP_PORT_BINDING$|'"$GOGS_HTTP_PORT_BINDING"'|g' $GIT_ENV
sed -i 's|@GOGS_POSTGRESQL_PORT_BINDING$|'"$GOGS_POSTGRESQL_PORT_BINDING"'|g' $GIT_ENV
sed -i 's|@GOGS_POSTGRESQL_DATABASE$|'"$GOGS_POSTGRESQL_DATABASE"'|g' $GIT_ENV
sed -i 's|@GOGS_POSTGRESQL_USER$|'"$GOGS_POSTGRESQL_USER"'|g' $GIT_ENV
sed -i 's|@GOGS_POSTGRESQL_PASSWORD$|'"$GOGS_POSTGRESQL_PASSWORD"'|g' $GIT_ENV

echo "Created .env file at '$GIT_SRC'."
echo

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

echo "Completed Gogs setup."
echo