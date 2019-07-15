#!/bin/bash

# STORAGE
export PROGET_ROOT=/var/dev/proget
export PROGET_PACKAGES=$PROGET_ROOT/packages
export PROGET_POSTGRES_DATA=$PROGET_ROOT/postgresql/data

mkdir -p $PROGET_PACKAGES
mkdir -p $PROGET_POSTGRES_DATA

# NETWORK
export PROGET_HTTP_PORT=10180
export PROGET_POSTGRES_PORT=10132

# DB-POSTGRES
export PROGET_POSTGRES_DATABASE=proget
export PROGET_POSTGRES_USER=proget
export PROGET_POSTGRES_PASSWORD=r00t

docker-compose -f packages_docker_compose.yml up -d