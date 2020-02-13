#!/bin/bash
set -euo pipefail

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
PORTS_PREFIX=$3

# DOCKER REGISTRY

REGISTRY_SRC=$(dirname "$0")

echo "Setting up Docker registry..."
echo "https://hub.docker.com/_/registry"
echo "https://joxit.dev/docker-registry-ui"
echo

REGISTRY_ROOT=$SHOEBOX_ROOT/registry
REGISTRY_SECRETS=$REGISTRY_ROOT/secrets.ini
REGISTRY_DATA=$REGISTRY_ROOT/data
REGISTRY_CONFIG=$REGISTRY_ROOT/config
REGISTRY_PORT=${PORTS_PREFIX}50
REGISTRY_UI_PORT=${PORTS_PREFIX}80

mkdir -p $REGISTRY_DATA
mkdir -p $REGISTRY_CONFIG

if test ! -f "$REGISTRY_SECRETS"; then
  REGISTRY_USERNAME=registry
  REGISTRY_PASSWORD=$(openssl rand 16 -hex)
  echo "REGISTRY_USERNAME=$REGISTRY_USERNAME" >> $REGISTRY_SECRETS
  echo "REGISTRY_PASSWORD=$REGISTRY_PASSWORD" >> $REGISTRY_SECRETS
fi

source $REGISTRY_SECRETS

htpasswd -bBc -C 10 $REGISTRY_SRC/htpasswd $REGISTRY_USERNAME $REGISTRY_PASSWORD
cp $REGISTRY_SRC/config.tmpl $REGISTRY_SRC/config.yml
sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $REGISTRY_SRC/config.yml

cp $REGISTRY_SRC/config.yml $REGISTRY_CONFIG/config.yml
cp $REGISTRY_SRC/htpasswd $REGISTRY_CONFIG/htpasswd

REGISTRY_ENV=$REGISTRY_SRC/.env
cp $REGISTRY_SRC/env.tmpl $REGISTRY_ENV

sed -i 's|@REGISTRY_DATA$|'"$REGISTRY_DATA"'|g' $REGISTRY_ENV
sed -i 's|@REGISTRY_CONFIG$|'"$REGISTRY_CONFIG"'|g' $REGISTRY_ENV
sed -i 's|@REGISTRY_PORT$|'"$REGISTRY_PORT"'|g' $REGISTRY_ENV
sed -i 's|@REGISTRY_UI_PORT$|'"$REGISTRY_UI_PORT"'|g' $REGISTRY_ENV
sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $REGISTRY_ENV

echo "Created '.env' file at '$REGISTRY_SRC'."
echo

echo "Docker registry mounts:"
echo "REGISTRY_DATA: $REGISTRY_DATA"
echo "REGISTRY_DATA: $REGISTRY_CONFIG"
echo
echo "Docker registry ports:"
echo "REGISTRY_PORT: $REGISTRY_PORT"
echo "REGISTRY_UI_PORT: $REGISTRY_UI_PORT"
echo
echo "Docker registry secrets:"
echo "REGISTRY_USERNAME: $REGISTRY_USERNAME"
echo "REGISTRY_PASSWORD: $REGISTRY_PASSWORD"
echo

echo "Completed Docker registry setup."
echo