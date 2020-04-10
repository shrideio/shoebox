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

bash $SRC_ROOT/proxy/proxy_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "mich4xD@gmail.com" "mich4xD@gmail.com"
bash $SRC_ROOT/git/git_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$GIT_PORTS_PREFIX"
bash $SRC_ROOT/vault/vault_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$VAULT_PORTS_PREFIX"
bash $SRC_ROOT/packages/packages_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$PACKAGES_PORTS_PREFIX"
bash $SRC_ROOT/registry/registry_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$REGISTRY_PORTS_PREFIX"
bash $SRC_ROOT/ci/ci_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$CI_PORTS_PREFIX"
bash $SRC_ROOT/project/project_containers_setup.sh "$SHOEBOX_ROOT" "$YOUR_DOMAIN" "$PROJECT_PORTS_PREFIX"


echo "Completed containers setup."
echo
