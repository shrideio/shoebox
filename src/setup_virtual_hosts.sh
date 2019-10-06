#!/bin/bash
set -euo pipefail

YOUR_DOMAIN=$1
REPO_ROOT=$(pwd)

HTTPD_CONFD=/etc/httpd/conf.d
HTTPD_SRC=$REPO_ROOT/src/httpd
HTTPD_SRC_CONFD=$HTTPD_SRC/confg.d
VHOST_CONF_TMPL=$HTTPD_SRC/ssl.conf.tmpl

echo
echo "Started virtual hosts setup."
echo

mkdir -p $HTTPD_SRC_CONFD

source ports_prefix.ini

declare -A SERVICES=(
  [git]=${GIT_PORTS_PREFIX}80
  [packages]=${PACKAGES_PORTS_PREFIX}80
  [registryui]=${REGISTRY_PORTS_PREFIX}80
  [registry]=${REGISTRY_PORTS_PREFIX}50
  [vault]=${VAULT_PORTS_PREFIX}80
  [ci]=${CI_PORTS_PREFIX}80
  [project]=${PROJETC_PORTS_PREFIX}80
)

for SRV in "${!SERVICES[@]}"
do
  CONF_FILE=$HTTPD_SRC_CONFD/$SRV.ssl.conf
  SVC_PORT=${SERVICES[$SRV]}

  cp $VHOST_CONF_TMPL $CONF_FILE
 
  sed -i -e 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' $CONF_FILE
  sed -i -e 's|@SUBDOMAIN|'"$SRV"'|g' $CONF_FILE
  sed -i -e 's|@SVC_PORT|'"$SVC_PORT"'|g' $CONF_FILE
  
  echo "Created a virtual host configuration file for '$SRV.$YOUR_DOMAIN' with a revers proxy at 'http://localhost:$SVC_PORT'."
done;

echo
echo "Created virtual host configuration '.conf' files at '$HTTPD_SRC_CONFD'."
ls $HTTPD_SRC_CONFD -I "*.conf" -l
echo

cp  $HTTPD_SRC_CONFD/*.conf $HTTPD_CONFD

echo "Copied virtual host configuration '.conf' files  to '$HTTPD_CONFD'."
ls $HTTPD_CONFD

echo "Completed virtual hosts setup."
echo