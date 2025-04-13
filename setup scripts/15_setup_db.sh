#! /usr/bin/bash

docker pull bitnami/postgresql:16.4.0-debian-12-r12
cd ~/Desktop/housekeeping_bee/db
export PG_HOUSEKEEPER_PWD="$HOUSEKEEPER_BEE_PWD_DB"
echo "docker compose..."
docker compose -f housekeeper.yaml up -d
sleep 5
echo "start docker container..."
docker start db-postgres_container-1
sleep 5
echo "docker run create database schema and user role..."
docker exec -u 0 -it db-postgres_container-1 psql postgres postgres \
-c '\connect housekeeper2024v1;' \
-c 'CREATE SCHEMA housekeeper_app;' \
-c 'SET search_path TO housekeeper_app;' \
-c 'SELECT * FROM pg_tables;' \
-c '\dt;' \
-c 'ALTER USER postgres SET search_path TO ''housekeeper_app'';'
sleep 5
echo "restart docker container..."
docker container restart db-postgres_container-1
sleep 5




