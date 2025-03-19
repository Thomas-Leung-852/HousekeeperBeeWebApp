#! /usr/bin/bash
cd ~/Desktop/HousekeeperBackup_initial_db
docker_id=$(docker container ls)
export CONTAINER_ID=${docker_id}
export DB_NAME=housekeeper2024v1
export DB_PWD=abcd2468
export SRC_FOLDER=~/Desktop/HousekeeperBackup_initial_db
docker exec -e PGPASSWORD=$DB_PWD -i db-postgres_container-1 psql -U postgres -d $DB_NAME < $SRC_FOLDER/postgres-backup.sql

