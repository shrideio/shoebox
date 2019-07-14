#!/bin/bash

# STORAGE
export GOGS_ROOT=/var/gogs

# NETWORK
export GOGS_HTTP_PORT=10080
export GOGS_SSH_PORT=10022

# DB-MYSQL
# export GOGS_MYSQL_PORT=10306
# export GOGS_MYSQL_DATABASE=gogs
# export GOGS_MYSQL_PASSWORD=r00t

docker-compose up -d -f packages_docker_compose.yml