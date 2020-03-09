#!/bin/bash
set -euo pipefail

SHOEBOX_ROOT=$1
YOUR_DOMAIN=$2
SRC_ROOT=$(dirname "$0")

echo
echo "SHOEBOX_ROOT: $SHOEBOX_ROOT"
echo "YOUR_DOMAIN: $YOUR_DOMAIN"
echo

echo
echo "Started containers setup."
echo

source $SRC_ROOT/ports_prefix.ini

bash $SRC_ROOT/git/git_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$GIT_PORTS_PREFIX"
bash $SRC_ROOT/vault/vault_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$VAULT_PORTS_PREFIX"
bash $SRC_ROOT/packages/packages_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$PACKAGES_PORTS_PREFIX"
bash $SRC_ROOT/registry/registry_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$REGISTRY_PORTS_PREFIX"
bash $SRC_ROOT/ci/ci_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$CI_PORTS_PREFIX"
bash $SRC_ROOT/project/project_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$PROJECT_PORTS_PREFIX"


# TAIGA

echo "Setting up Taiga..."
echo "https://taiga.io/"
echo

TAIGA_ROOT=$SHOEBOX_ROOT/taiga
TAIGA_SECRETS=$TAIGA_ROOT/secrets.ini
TAIGA_DATA=$TAIGA_ROOT/data

STORAGE_TAIGA_BACK=$TAIGA_DATA/back
STORAGE_TAIGA_BACK_MEDIA=$TAIGA_DATA/back_media
STORAGE_TAIGA_FRONT=$TAIGA_DATA/front
STORAGE_TAIGA_DB=$TAIGA_DATA/db
STORAGE_TAIGA_PROXY=$TAIGA_DATA/proxy

mkdir -p $TAIGA_DATA
mkdir -p $STORAGE_TAIGA_BACK
mkdir -p $STORAGE_TAIGA_BACK_MEDIA
mkdir -p $STORAGE_TAIGA_FRONT
mkdir -p $STORAGE_TAIGA_DB
mkdir -p $STORAGE_TAIGA_PROXY

echo "Created volume mounts for Taiga."
echo "TAIGA_DATA: $TAIGA_DATA"
echo "STORAGE_TAIGA_BACK: $STORAGE_TAIGA_BACK"
echo "STORAGE_TAIGA_BACK_MEDIA: $STORAGE_TAIGA_BACK_MEDIA"
echo "STORAGE_TAIGA_FRONT: $STORAGE_TAIGA_FRONT"
echo "STORAGE_TAIGA_DB: $STORAGE_TAIGA_DB"
echo "STORAGE_TAIGA_PROXY: $STORAGE_TAIGA_PROXY"

if test ! -f "$TAIGA_SECRETS"; then
  TAIGA_SECRET=$(openssl rand 16 -hex)
  TAIGA_POSTGRESQL_USER=taiga_t0iG022
  TAIGA_POSTGRESQL_PASSWORD=$(openssl rand 16 -hex)
  TAIGA_RABBIT_USER=taiga_r2bB2t
  TAIGA_RABBIT_PASSWORD=$(openssl rand 16 -hex)
  echo "TAIGA_SECRET=$TAIGA_SECRET" >> $TAIGA_SECRETS
  echo "TAIGA_POSTGRESQL_USER=$TAIGA_POSTGRESQL_USER" >> $TAIGA_SECRETS
  echo "TAIGA_POSTGRESQL_PASSWORD=$TAIGA_POSTGRESQL_PASSWORD" >> $TAIGA_SECRETS
  echo "TAIGA_RABBIT_USER=$TAIGA_RABBIT_USER" >> $TAIGA_SECRETS
  echo "TAIGA_RABBIT_PASSWORD=$TAIGA_RABBIT_PASSWORD" >> $TAIGA_SECRETS
fi

source $TAIGA_SECRETS

echo "Generated secrets for Taiga."
echo "Taiga adimistartor user: admin/123123"
echo "Check '$TAIGA_SECRETS' for more information."
echo

TAIGA_SRC=$SRC_ROOT/project
cp $TAIGA_SRC/env.tmpl $TAIGA_SRC/.env

find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@TAIGA_HOST|'"project.$YOUR_DOMAIN"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@STORAGE_TAIGA_BACK|'"$STORAGE_TAIGA_BACK"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@STORAGE_TAIGA_BACK_MEDIA|'"$STORAGE_TAIGA_BACK_MEDIA"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@STORAGE_TAIGA_FRONT|'"$STORAGE_TAIGA_FRONT"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@STORAGE_TAIGA_DB|'"$STORAGE_TAIGA_DB"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@STORAGE_TAIGA_PROXY|'"$STORAGE_TAIGA_PROXY"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@TAIGA_SECRET|'"$-helk"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@TAIGA_POSTGRESQL_USER|'"$TAIGA_POSTGRESQL_USER"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@TAIGA_POSTGRESQL_PASSWORD|'"$TAIGA_POSTGRESQL_PASSWORD"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@TAIGA_RABBIT_USER|'"$TAIGA_RABBIT_USER"'|g' {} \;
find $TAIGA_SRC -type f -name '*.env' -exec sed -i -e 's|@TAIGA_RABBIT_PASSWORD|'"$TAIGA_RABBIT_PASSWORD"'|g' {} \;

echo "Created '.env' file at '$TAIGA_ROOT'."
echo

echo "Completed Taiga CI setup."
echo


echo "Completed containers setup."
echo