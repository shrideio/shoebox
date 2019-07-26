#!/bin/bash

# STORAGE
export GOGS_ROOT=/var/dev/gogs
export GOGS_DATA=$GOGS_ROOT/data
export GOGS_MYSQL_DATA=$GOGS_ROOT/mysql/data

mkdir -p $GOGS_DATA
mkdir -p $GOGS_MYSQL_DATA

# NETWORK
export GOGS_HTTP_PORT=10080
export GOGS_SSH_PORT=10022

# DB-MYSQL
export GOGS_MYSQL_PORT=10306
export GOGS_MYSQL_DATABASE=gogs
export GOGS_MYSQL_USER=gogs
export GOGS_MYSQL_USER_PASSWORD=g09z
export GOGS_MYSQL_ROOT_PASSWORD=r00t

docker-compose -f git_docker_compose.yml up -d
