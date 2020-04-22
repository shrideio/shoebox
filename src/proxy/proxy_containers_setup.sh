#!/bin/bash
set -euo pipefail

echo "Setting up Traefik..."
echo "https://containo.us/traefik/"
echo

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2

PROXY_SRC=$(pwd "$0")

LETSENCRYPT_ROOT=/etc/letsencrypt
LETSENCRYPT_INI=$LETSENCRYPT_ROOT/letsencrypt.ini

TRAEFIK_ROOT=$SHOEBOX_ROOT/proxy-traefik
TRAEFIK_CONFIG=$TRAEFIK_ROOT/config
TRAEFIK_SECRETS=$TRAEFIK_ROOT/secrets.ini

mkdir -p $TRAEFIK_CONFIG

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
source $LETSENCRYPT_INI

htpasswd -bBc -C 10 $PROXY_SRC/htpasswd $TRAEFIK_DASHBOARD_USERNAME $TRAEFIK_DASHBOARD_PASSWORD
cp $PROXY_SRC/htpasswd $TRAEFIK_CONFIG/htpasswd

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $PROXY_ENV
sed -i 's|@DNS_CLOUDFLARE_EMAIL$|'"$DNS_CLOUDFLARE_EMAIL"'|g' $PROXY_ENV
sed -i 's|@DNS_CLOUDFLARE_API_KEY$|'"$DNS_CLOUDFLARE_API_KEY"'|g' $PROXY_ENV
sed -i 's|@LETSENCRYPT_ROOT$|'"$LETSENCRYPT_ROOT"'|g' $PROXY_ENV
sed -i 's|@LETSENCRYPT_EMAIL$|'"$LETSENCRYPT_EMAIL"'|g' $PROXY_ENV
sed -i 's|@TRAEFIK_CONFIG$|'"$TRAEFIK_CONFIG"'|g' $PROXY_ENV

echo "Created .env file at '$PROXY_SRC'."
echo

echo "Proxy volume mounts:"
echo "PROXY_LETSENCRYPT: $LETSENCRYPT_ROOT"
echo "PROXY_DOCKER_SOCK_ACCESS: /var/run/docker.sock"
echo


echo "Completed Traefik setup."
echo
