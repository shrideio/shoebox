#!/bin/bash

export DEV_ROOT=/var/dev

# GOGS
export GOGS_ROOT=$DEV_ROOT/gogs
export GOGS_DATA=$GOGS_ROOT/data
export GOGS_MYSQL_DATA=$GOGS_ROOT/mysql/data

mkdir -p $GOGS_DATA
mkdir -p $GOGS_MYSQL_DATA

find /tmp/shoebox/src/git -type f -name '*.env' -exec sed -i -e 's|@GOGS_DATA|'"$GOGS_DATA"'|g' {} \;
find /tmp/shoebox/src/git -type f -name '*.env' -exec sed -i -e 's|@GOGS_MYSQL_DATA|'"$GOGS_MYSQL_DATA"'|g' {} \;

# PROGET
export PROGET_ROOT=$DEV_ROOT/proget
export PROGET_PACKAGES=$PROGET_ROOT/packages
export PROGET_EXTENSIONS=$PROGET_ROOT/extensions
export PROGET_POSTGRESQL_DATA=$PROGET_ROOT/postgresql/data

mkdir -p $PROGET_PACKAGES
mkdir -p $PROGET_EXTENSIONS
mkdir -p $PROGET_POSTGRESQL_DATA

find /tmp/shoebox/src/packages -type f -name '*.env' -exec sed -i -e 's|@PROGET_PACKAGES|'"$PROGET_PACKAGES"'|g' {} \;
find /tmp/shoebox/src/packages -type f -name '*.env' -exec sed -i -e 's|@PROGET_EXTENSIONS|'"$PROGET_EXTENSIONS"'|g' {} \;
find /tmp/shoebox/src/packages -type f -name '*.env' -exec sed -i -e 's|@PROGET_POSTGRESQL_DATA|'"$PROGET_POSTGRESQL_DATA"'|g' {} \;