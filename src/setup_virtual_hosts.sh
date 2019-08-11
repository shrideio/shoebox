#!/bin/bash
set -euo pipefail

# Replace with the actual domain name
YOUR_DOMAIN=yourdomain.com

HTTPD_CONFD=/etc/httpd/conf.d
SRC_ROOT=/tmp/shoebox/src
HTTPD_SRC=$SRC_ROOT/httpd
HTTPD_SRC_CONFD=$HTTPD_SRC/confg.d
VHOST_CONF_TMPL=$HTTPD_SRC/ssl.conf.tmpl

echo
echo "Started virtual hosts setup."
echo

mkdir -p $HTTPD_SRC_CONFD

declare -A SERVICES=(
  [git]=10080
  [registry]=10180
  [vault]=10280
  [ci]=10380
  [project]=10480
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