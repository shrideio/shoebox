#!/bin/bash
set -euo pipefail

echo "Setting up ProGet..."
echo "https://inedo.com/proget"
echo

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2

PACKAGES_SRC=$(dirname $(realpath $0))
SRC_ROOT=$(dirname "$PACKAGES_SRC")

source $SRC_ROOT/ports_prefix.ini
PACKAGES_PORTS_PREFIX=${3:-$PACKAGES_PORTS_PREFIX}

PROGET_ROOT=$SHOEBOX_ROOT/packages-proget
PROGET_SECRETS=$PROGET_ROOT/secrets.ini
PROGET_PACKAGES=$PROGET_ROOT/packages
PROGET_EXTENSIONS=$PROGET_ROOT/extensions
PROGET_CONFIG=$PROGET_ROOT/config
PROGET_POSTGRESQL_DATA=$PROGET_ROOT/postgresql/data

PROGET_HTTP_PORT=${PACKAGES_PORTS_PREFIX}80
PROGET_POSTGRESQL_PORT=${PACKAGES_PORTS_PREFIX}32

LOCALHOST="127.0.0.1"
PROGET_HTTP_PORT_BINDING="$LOCALHOST:$PROGET_HTTP_PORT"
PROGET_POSTGRESQL_PORT_BINDING="$LOCALHOST:$PROGET_POSTGRESQL_PORT"

mkdir -p $PROGET_PACKAGES
mkdir -p $PROGET_EXTENSIONS
mkdir -p $PROGET_CONFIG
mkdir -p $PROGET_POSTGRESQL_DATA

if test ! -f "$PROGET_SECRETS"; then
  PROGET_POSTGRESQL_DATABASE=proget
  PROGET_POSTGRESQL_USER=proget
  PROGET_POSTGRESQL_PASSWORD=$(openssl rand -hex 16 )
  echo "PROGET_POSTGRESQL_DATABASE=$PROGET_POSTGRESQL_DATABASE" >> $PROGET_SECRETS
  echo "PROGET_POSTGRESQL_USER=$PROGET_POSTGRESQL_USER" >> $PROGET_SECRETS
  echo "PROGET_POSTGRESQL_PASSWORD=$PROGET_POSTGRESQL_PASSWORD" >> $PROGET_SECRETS
fi

source $PROGET_SECRETS

PACKAGES_ENV=$PACKAGES_SRC/.env
cp $PACKAGES_SRC/env.tmpl $PACKAGES_ENV

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_PACKAGES$|'"$PROGET_PACKAGES"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_EXTENSIONS$|'"$PROGET_EXTENSIONS"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_CONFIG$|'"$PROGET_CONFIG"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_POSTGRESQL_DATA$|'"$PROGET_POSTGRESQL_DATA"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_HTTP_PORT_BINDING$|'"$PROGET_HTTP_PORT_BINDING"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_POSTGRESQL_PORT_BINDING$|'"$PROGET_POSTGRESQL_PORT_BINDING"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_POSTGRESQL_DATABASE$|'"$PROGET_POSTGRESQL_DATABASE"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_POSTGRESQL_USER$|'"$PROGET_POSTGRESQL_USER"'|g' $PACKAGES_ENV
sed -i 's|@PROGET_POSTGRESQL_PASSWORD$|'"$PROGET_POSTGRESQL_PASSWORD"'|g' $PACKAGES_ENV

echo "Created .env file at '$PACKAGES_SRC'."
echo

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
echo "ProGet secrets:"
echo "PROGET_POSTGRESQL_DATABASE: $PROGET_POSTGRESQL_DATABASE"
echo "PROGET_POSTGRESQL_USER: $PROGET_POSTGRESQL_USER"
echo "PROGET_POSTGRESQL_PASSWORD: $PROGET_POSTGRESQL_PASSWORD"
echo

echo "Completed ProGet setup."
echo