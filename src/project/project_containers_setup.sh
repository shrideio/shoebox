#!/bin/bash
set -euo pipefail

# TAIGA

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
PORTS_PREFIX=$3

PROJECT_SRC=$(dirname "$0")

echo "Setting up Taiga..."
echo "https://taiga.io/"
echo

TAIGA_ROOT=$SHOEBOX_ROOT/taiga
TAIGA_SECRETS=$TAIGA_ROOT/secrets.ini
TAIGA_DATA=$TAIGA_ROOT/data

TAIGA_BACK_CONF=$TAIGA_DATA/back
TAIGA_BACK_MEDIA=$TAIGA_DATA/back_media
TAIGA_FRONT_CONF=$TAIGA_DATA/front
TAIGA_POSTGRESQL_DATA=$TAIGA_DATA/postgresql/data
TAIGA_PROXY_CONF=$TAIGA_DATA/proxy

TAIGA_POSTGRESQL_PORT=${PORTS_PREFIX}32
TAIGA_PROXY_PORT=${PORTS_PREFIX}80

mkdir -p $TAIGA_DATA
mkdir -p $TAIGA_BACK_CONF
mkdir -p $TAIGA_BACK_MEDIA
mkdir -p $TAIGA_FRONT_CONF
mkdir -p $TAIGA_POSTGRESQL_DATA
mkdir -p $TAIGA_PROXY_CONF

if test ! -f "$TAIGA_SECRETS"; then
  TAIGA_SECRET=$(openssl rand 16 -hex)
  TAIGA_POSTGRESQL_USER=taiga
  TAIGA_POSTGRESQL_PASSWORD=$(openssl rand 16 -hex)
  TAIGA_RABBIT_USER=taiga
  TAIGA_RABBIT_PASSWORD=$(openssl rand 16 -hex)
  echo "TAIGA_SECRET=$TAIGA_SECRET" >> $TAIGA_SECRETS
  echo "TAIGA_POSTGRESQL_USER=$TAIGA_POSTGRESQL_USER" >> $TAIGA_SECRETS
  echo "TAIGA_POSTGRESQL_PASSWORD=$TAIGA_POSTGRESQL_PASSWORD" >> $TAIGA_SECRETS
  echo "TAIGA_RABBIT_USER=$TAIGA_RABBIT_USER" >> $TAIGA_SECRETS
  echo "TAIGA_RABBIT_PASSWORD=$TAIGA_RABBIT_PASSWORD" >> $TAIGA_SECRETS
fi

source $TAIGA_SECRETS

PROJECT_ENV=$PROJECT_SRC/.env
cp $PROJECT_SRC/env.tmpl $PROJECT_ENV

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_BACK_MEDIA$|'"$TAIGA_BACK_MEDIA"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_BACK_CONF$|'"$TAIGA_BACK_CONF"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_FRONT_CONF$|'"$TAIGA_FRONT_CONF"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_POSTGRESQL_DATA$|'"$TAIGA_POSTGRESQL_DATA"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_PROXY_CONF$|'"$TAIGA_PROXY_CONF"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_SECRET$|'"$TAIGA_SECRET"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_POSTGRESQL_USER$|'"$TAIGA_POSTGRESQL_USER"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_POSTGRESQL_PASSWORD$|'"$TAIGA_POSTGRESQL_PASSWORD"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_RABBIT_USER$|'"$TAIGA_RABBIT_USER"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_RABBIT_PASSWORD$|'"$TAIGA_RABBIT_PASSWORD"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_POSTGRESQL_PORT$|'"$TAIGA_POSTGRESQL_PORT"'|g' $PROJECT_ENV
sed -i 's|@TAIGA_PROXY_PORT$|'"$TAIGA_PROXY_PORT"'|g' $PROJECT_ENV

echo "Created '.env' file at '$TAIGA_ROOT'."
echo

echo "Taiga volume mounts:"
echo "TAIGA_DATA: $TAIGA_DATA"
echo "TAIGA_BACK_CONF: $TAIGA_BACK_CONF"
echo "TAIGA_BACK_MEDIA $TAIGA_BACK_MEDIA"
echo "TAIGA_FRONT_CONF: $TAIGA_FRONT_CONF"
echo "TAIGA_POSTGRESQL_DATA: $TAIGA_POSTGRESQL_DATA"
echo "TAIGA_PROXY_CONF: $TAIGA_PROXY_CONF"
echo
echo "Taiga ports"
echo "TAIGA_POSTGRESQL_PORT: $TAIGA_POSTGRESQL_PORT"
echo "TAIGA_PROXY_PORT: $TAIGA_PROXY_PORT"
echo
echo "Taiga secrets:"
echo "Taiga adimistartor user: admin/123123"
echo "TAIGA_SECRET: $TAIGA_SECRET"
echo "TAIGA_POSTGRESQL_USER: $TAIGA_POSTGRESQL_USER"
echo "TAIGA_POSTGRESQL_PASSWORD: $TAIGA_POSTGRESQL_PASSWORD"
echo "TAIGA_RABBIT_USER: $TAIGA_RABBIT_USER"
echo "TAIGA_RABBIT_PASSWORD: $TAIGA_RABBIT_PASSWORD"
echo

echo "Completed Taiga setup."
echo