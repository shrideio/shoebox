#!/bin/bash
set -euo pipefail


SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
CLOUDFLARE_EMAIL=$3
CLOUDFLARE_API_KEY$4
LETS_ENCRYPT_EMAIL=$5

# PROXY-TRAEFIK

PROXY_SRC=$(dirname "$0")

echo "Setting up Traefik..."
echo "https://containo.us/traefik/"
echo

PROXY_ROOT=$SHOEBOX_ROOT/proxy-traefik
PROXY_LETSENCRYPT_DIR=$PROGET_ROOT/letsencrypt


mkdir -p $PROXY_ROOT
mkdir -p $PROXY_LETSENCRYPT_DIR

source $PROGET_SECRETS

PROXY_ENV=$PROXY_SRC/.env
cp $PROXY_SRC/env.tmpl $PROXY_ENV

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $PROXY_ENV
sed -i 's|@CLOUDFLARE_EMAIL$|'"$CLOUDFLARE_EMAIL"'|g' $PROXY_ENV
sed -i 's|@CLOUDFLARE_API_KEY$|'"$CLOUDFLARE_API_KEY"'|g' $PROXY_ENV
sed -i 's|@PROXY_LETSENCRYPT_DIR$|'"$PROXY_LETSENCRYPT_DIR"'|g' $PROXY_ENV
sed -i 's|@LETS_ENCRYPT_EMAIL$|'"$LETS_ENCRYPT_EMAIL"'|g' $PROXY_ENV



echo "Created .env file at '$PROXY_SRC'."
echo

echo "Proxy volume mounts:"
echo "PROXY_LETSENCRYPT: $PROGET_PACKAGES"
echo "PROXY_DOCKER_SOCK_ACCESS: /var/run/docker.sock"
echo


echo "Completed ProGet setup."
echo