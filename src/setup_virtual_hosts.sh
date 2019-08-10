#!/bin/bash
set -euo pipefail

# Replace with the actual domain name
export YOUR_DOMAIN = yourdomain.com

export HTTPD_CONFD = /etc/httpd/conf.d
export SRC_ROOT=/tmp/shoebox/src
export HTTPD_CONFD_SRC = $SRC_ROOT/httpd/conf.d

echo
echo "Started virtual hosts setup."
echo

for f in $HTTPD_CONFD_SRC/*.tmpl; 
  do cp "$f" "${f%.tmpl}";
done

find $HTTPD_CONFD_SRC -type f -name '*.conf' -exec sed -i -e 's|@YOUR_DOMAIN|'"$YOUR_DOMAIN"'|g' {} \;

echo "Created virtual host configuration '.conf' files ."
ls $HTTPD_CONFD_SRC -I "*.tmpl" -l
echo

cp  $HTTPD_CONFD_SRC/*.conf $HTTPD_CONFD

echo "Copied virtual host configuration '.conf' files  to '$HTTPD_CONFD'."
ls $HTTPD_CONFD

echo "Completed virtual hosts setup."
echo