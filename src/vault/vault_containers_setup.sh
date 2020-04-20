#!/bin/bash
set -euo pipefail

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
PORTS_PREFIX=$3

# VAULT

VAULT_SRC=$(dirname "$0")

echo "Setting up Vault..."
echo "https://www.vaultproject.io/"
echo

VAULT_ROOT=$SHOEBOX_ROOT/vault-hashicorp
VAULT_CONFIG=$VAULT_ROOT/config
VAULT_LOGS=$VAULT_ROOT/logs
VAULT_CONSUL_CONFIG=$VAULT_ROOT/consul/config
VAULT_CONSUL_DATA=$VAULT_ROOT/consul/data
VAULT_PORT=${PORTS_PREFIX}80
CONSUL_PORT=${PORTS_PREFIX}85

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
sed -i 's|@VAULT_PORT$|'"$VAULT_PORT"'|g' $VAULT_ENV
sed -i 's|@CONSUL_PORT$|'"$CONSUL_PORT"'|g' $VAULT_ENV

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
echo "CONSUL_PORT: $CONSUL_PORT"
echo
echo "Configuration files:"
echo "Vault: '$VAULT_CONFIG/config.hcl'."
echo "Consul: '$VAULT_CONSUL_CONFIG/config.json'."
echo

echo "Completed Vault setup."
echo
