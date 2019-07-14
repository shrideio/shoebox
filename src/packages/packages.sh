#!/bin/bash

# STORAGE
export PROGET_ROOT=/var/dev/proget

# NETWORK
export PROGET_HTTP_PORT=10180
export PROGET_POSTGRES_PORT=1015432

# DB-POSTGRES
export PROGET_POSTGRES_DATABASE=proget
export PROGET_POSTGRES_USER=proget
export PROGET_POSTGRES_PASSWORD=r00t

docker-compose up -d -f packages_docker_compose.yml