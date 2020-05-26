#!/bin/bash
set -euo pipefail

echo "Setting up Vault..."
echo "https://www.vaultproject.io/"
echo

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2

VAULT_SRC=$(dirname $(realpath $0))
SRC_ROOT=$(dirname "$VAULT_SRC")

source $SRC_ROOT/ports_prefix.ini
REGISTRY_PORTS_PREFIX=${3:-$REGISTRY_PORTS_PREFIX}

VAULT_ROOT=$SHOEBOX_ROOT/vault-hashicorp
VAULT_CONFIG=$VAULT_ROOT/config
VAULT_LOGS=$VAULT_ROOT/logs
VAULT_CONSUL_CONFIG=$VAULT_ROOT/consul/config
VAULT_CONSUL_DATA=$VAULT_ROOT/consul/data

VAULT_PORT=${REGISTRY_PORTS_PREFIX}80
VAULT_CONSUL_PORT=${REGISTRY_PORTS_PREFIX}85

LOCALHOST="127.0.0.1"
VAULT_PORT_BINDING="$LOCALHOST:$VAULT_PORT"
VAULT_CONSUL_PORT_BINDING="$LOCALHOST:$VAULT_CONSUL_PORT"

mkdir -p $VAULT_CONFIG
mkdir -p $VAULT_LOGS
mkdir -p $VAULT_CONSUL_CONFIG
mkdir -p $VAULT_CONSUL_DATA

cp $VAULT_SRC/config/vault/config.hcl $VAULT_CONFIG/config.hcl
cp $VAULT_SRC/config/consul/config.json $VAULT_CONSUL_CONFIG/config.json

VAULT_ENV=$VAULT_SRC/.env
cp $VAULT_SRC/env.tmpl $VAULT_ENV

sed -i 's|@YOUR_DOMAIN$|'"$YOUR_DOMAIN"'|g' $VAULT_ENV
sed -i 's|@VAULT_CONFIG$|'"$VAULT_CONFIG"'|g' $VAULT_ENV
sed -i 's|@VAULT_LOGS$|'"$VAULT_LOGS"'|g' $VAULT_ENV
sed -i 's|@VAULT_CONSUL_CONFIG$|'"$VAULT_CONSUL_CONFIG"'|g' $VAULT_ENV
sed -i 's|@VAULT_CONSUL_DATA$|'"$VAULT_CONSUL_DATA"'|g' $VAULT_ENV
sed -i 's|@VAULT_PORT_BINDING$|'"$VAULT_PORT_BINDING"'|g' $VAULT_ENV
sed -i 's|@VAULT_CONSUL_PORT_BINDING$|'"$VAULT_CONSUL_PORT_BINDING"'|g' $VAULT_ENV

echo "Created '.env' file at '$VAULT_SRC'."
echo

echo "Vault volume mounts:"
echo "VAULT_CONFIG: $VAULT_CONFIG"
echo "VAULT_LOGS: $VAULT_LOGS"
echo "VAULT_CONSUL_CONFIG: $VAULT_CONSUL_CONFIG"
echo "VAULT_CONSUL_DATA: $VAULT_CONSUL_DATA"
echo
echo "Vault ports:"
echo "VAULT_PORT: $VAULT_PORT"
echo "VAULT_CONSUL_PORT: $VAULT_CONSUL_PORT"
echo
echo "Configuration files:"
echo "Vault: '$VAULT_CONFIG/config.hcl'."
echo "Consul: '$VAULT_CONSUL_CONFIG/config.json'."
echo

echo "Completed Vault setup."
echo