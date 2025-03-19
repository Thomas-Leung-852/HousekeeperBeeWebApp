#! /usr/bin/bash

docker pull bitnami/postgresql:16.4.0-debian-12-r12
cd ~/Desktop/housekeeping_bee/db
export PG_HOUSEKEEPER_PWD="abcd2468"
docker compose -f housekeeper.yaml up -d
docker start db-postgres_container-1
docker exec -u 0 -it db-postgres_container-1 psql postgres postgres \
-c '\connect housekeeper2024v1;' \
-c 'CREATE SCHEMA housekeeper_app;' \
-c 'SET search_path TO housekeeper_app;' \
-c 'SELECT * FROM pg_tables;' \
-c '\dt;' \
-c 'ALTER USER postgres SET search_path TO ''housekeeper_app'';'




