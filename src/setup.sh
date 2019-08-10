#!/bin/bash

export DEV_ROOT = /var/dev
export SRC_ROOT = /tmp/shoebox/src

echo "Started setup."
echo "DEV_ROOT: $DEV_ROOT"
echo "SRC_ROOT: $SRC_ROOT"
echo


# GOGS

echo "Setting up Gogs..."
echo "https://gogs.io/"
echo

export GOGS_ROOT = $DEV_ROOT/gogs
export GOGS_DATA = $GOGS_ROOT/data
export GOGS_MYSQL_DATA = $GOGS_ROOT/mysql/data

mkdir -p $GOGS_DATA
mkdir -p $GOGS_MYSQL_DATA

echo "Created volume mounts for Gogs."
echo "GOGS_DATA: $GOGS_DATA"
echo "GOGS_MYSQL_DATA: $GOGS_MYSQL_DATA"
echo

export GIT_SRC = $SRC_ROOT/git
mv $GIT_SRC/env.tmpl GIT_SRC/.env
find $GIT_SRC -type f -name '*.env' -exec sed -i -e 's|@GOGS_DATA|'"$GOGS_DATA"'|g' {} \;
find $GIT_SRC -type f -name '*.env' -exec sed -i -e 's|@GOGS_MYSQL_DATA|'"$GOGS_MYSQL_DATA"'|g' {} \;

echo "Created .env file at '$GIT_SRC'."
echo

echo "Completed Gogs setup."
echo


# PROGET

echo "Setting up ProGet..."
echo "https://inedo.com/proget"
echo

export PROGET_ROOT = $DEV_ROOT/proget
export PROGET_PACKAGES = $PROGET_ROOT/packages
export PROGET_EXTENSIONS = $PROGET_ROOT/extensions
export PROGET_POSTGRESQL_DATA = $PROGET_ROOT/postgresql/data

mkdir -p $PROGET_PACKAGES
mkdir -p $PROGET_EXTENSIONS
mkdir -p $PROGET_POSTGRESQL_DATA

echo "Created volume mounts for ProGet."
echo "PROGET_PACKAGES: $PROGET_PACKAGES"
echo "PROGET_EXTENSIONS: $PROGET_EXTENSIONS"
echo "PROGET_POSTGRESQL_DATA: $PROGET_POSTGRESQL_DATA"
echo

export PACKAGES_SRC=$SRC_ROOT/packages
mv $PACKAGES_SRC/env.tmpl $PACKAGES_SRC/.env
find $PACKAGES_SRC -type f -name '*.env' -exec sed -i -e 's|@PROGET_PACKAGES|'"$PROGET_PACKAGES"'|g' {} \;
find $PACKAGES_SRC -type f -name '*.env' -exec sed -i -e 's|@PROGET_EXTENSIONS|'"$PROGET_EXTENSIONS"'|g' {} \;
find $PACKAGES_SRC -type f -name '*.env' -exec sed -i -e 's|@PROGET_POSTGRESQL_DATA|'"$PROGET_POSTGRESQL_DATA"'|g' {} \;

echo "Created .env file at '$PACKAGES_SRC'."
echo

echo "Completed ProGet setup."
echo


# VAULT

echo "Setting up Vault..."
echo "https://www.vaultproject.io/"
echo

export VAULT_ROOT=$DEV_ROOT/vault
export VAULT_CONFIG = $VAULT_ROOT/config
export VAULT_LOGS = $VAULT_ROOT/logs
export VAULT_CONSUL_CONFIG = $VAULT_ROOT/consul/config
export VAULT_CONSUL_DATA = $VAULT_ROOT/consul/data

mkdir -p $VAULT_CONFIG
mkdir -p $VAULT_LOGS
mkdir -p $VAULT_CONSUL_CONFIG
mkdir -p $VAULT_CONSUL_DATA

echo "Created volume mounts for Vault."
echo "VAULT_CONFIG: $VAULT_CONFIG"
echo "VAULT_LOGS: $VAULT_LOGS"
echo "VAULT_CONSUL_CONFIG: $VAULT_CONSUL_CONFIG"
echo "VAULT_CONSUL_DATA: $VAULT_CONSUL_DATA"
echo

export VAULT_SRC=$SRC_ROOT/vault
mv $VAULT_SRC/env.tmpl $VAULT_SRC/.env
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_CONFIG|'"$VAULT_CONFIG"'|g' {} \;
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_LOGS|'"$VAULT_LOGS"'|g' {} \;
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_CONSUL_CONFIG|'"$VAULT_CONSUL_CONFIG"'|g' {} \;
find $VAULT_SRC -type f -name '*.env' -exec sed -i -e 's|@VAULT_CONSUL_DATA|'"$VAULT_CONSUL_DATA"'|g' {} \;

echo "Created .env file at '$VAULT_SRC'."
echo

echo "Completed Vault setup."
echo