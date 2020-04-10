!/bin/bash
set -euo pipefail

# PROXY-TRAEFIK

YOUR_DOMAIN=$1

LETSENCRYPT_ROOT=/etc/letsencrypt
LETSENCRYPT_CONFIG=$LETSENCRYPT_ROOT/letsencrypt.ini

PROXY_SRC=$(dirname "$0")

echo "Setting up Traefik..."
echo "https://containo.us/traefik/"
echo

PROXY_ENV=$PROXY_SRC/.env
cp $PROXY_SRC/env.tmpl $PROXY_ENV

source $LETSENCRYPT_CONFIG

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $PROXY_ENV
sed -i 's|@DNS_CLOUDFLARE_EMAIL$|'"$DNS_CLOUDFLARE_EMAIL"'|g' $PROXY_ENV
sed -i 's|@DNS_CLOUDFLARE_API_KEY$|'"$DNS_CLOUDFLARE_API_KEY"'|g' $PROXY_ENV
sed -i 's|@LETSENCRYPT_ROOT$|'"$LETSENCRYPT_ROOT"'|g' $PROXY_ENV
sed -i 's|@LETSENCRYPT_EMAIL$|'"$LETSENCRYPT_EMAIL"'|g' $PROXY_ENV



echo "Created .env file at '$PROXY_SRC'."
echo

echo "Proxy volume mounts:"
echo "PROXY_LETSENCRYPT: $LETSENCRYPT_ROOT"
echo "PROXY_DOCKER_SOCK_ACCESS: /var/run/docker.sock"
echo


echo "Completed Traefik setup."
echo
