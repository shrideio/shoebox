#!/bin/bash
set -euo pipefail

echo "Setting up Traefik..."
echo "https://containo.us/traefik/"
echo

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
CLOUDFLARE_API_INI=$3

PROXY_SRC=$(dirname $(realpath $0))

TRAEFIK_ROOT=$SHOEBOX_ROOT/proxy-traefik
TRAEFIK_CONFIG=$TRAEFIK_ROOT/config
TRAEFIK_SECRETS=$TRAEFIK_ROOT/secrets.ini
TRAEFIK_LETSENCRYPT=$TRAEFIK_ROOT/letsencrypt

mkdir -p $TRAEFIK_CONFIG
mkdir -p $TRAEFIK_LETSENCRYPT

if test ! -f "$TRAEFIK_SECRETS"; then
  mkdir -p $TRAEFIK_ROOT
  TRAEFIK_DASHBOARD_USERNAME=proxyadmin
  TRAEFIK_DASHBOARD_PASSWORD=$(openssl rand 16 -hex)
  echo "TRAEFIK_DASHBOARD_USERNAME=$TRAEFIK_DASHBOARD_USERNAME" >> $TRAEFIK_SECRETS
  echo "TRAEFIK_DASHBOARD_PASSWORD=$TRAEFIK_DASHBOARD_PASSWORD" >> $TRAEFIK_SECRETS
fi

PROXY_ENV=$PROXY_SRC/.env
cp $PROXY_SRC/env.tmpl $PROXY_ENV

source $TRAEFIK_SECRETS
source $CLOUDFLARE_API_INI

htpasswd -bBc -C 10 $PROXY_SRC/htpasswd $TRAEFIK_DASHBOARD_USERNAME $TRAEFIK_DASHBOARD_PASSWORD
cp $PROXY_SRC/htpasswd $TRAEFIK_CONFIG/htpasswd

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $PROXY_ENV
sed -i 's|@CLOUDFLARE_EMAIL$|'"$CLOUDFLARE_EMAIL"'|g' $PROXY_ENV
sed -i 's|@CLOUDFLARE_API_KEY$|'"$CLOUDFLARE_API_KEY"'|g' $PROXY_ENV
sed -i 's|@TRAEFIK_LETSENCRYPT$|'"$TRAEFIK_LETSENCRYPT"'|g' $PROXY_ENV
sed -i 's|@LETSENCRYPT_EMAIL$|'"$LETSENCRYPT_EMAIL"'|g' $PROXY_ENV
sed -i 's|@TRAEFIK_CONFIG$|'"$TRAEFIK_CONFIG"'|g' $PROXY_ENV

echo "Created .env file at '$PROXY_SRC'."
echo

echo "Traefic volume mounts:"
echo "TRAEFIK_LETSENCRYPT: $TRAEFIK_LETSENCRYPT"
echo "TRAEFIK_CONFIG: $TRAEFIK_CONFIG"
echo
echo "Traefic secrets:"
echo "TRAEFIK_DASHBOARD_USERNAME: $TRAEFIK_DASHBOARD_USERNAME"
echo "TRAEFIK_DASHBOARD_PASSWORD: $TRAEFIK_DASHBOARD_PASSWORD"
echo

echo "Completed Traefik setup."
echo
