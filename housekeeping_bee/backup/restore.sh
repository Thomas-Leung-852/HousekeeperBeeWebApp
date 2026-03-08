#!/bin/bash

if [ -z "$HOUSEKEEPER_BEE_HOME" ]; then
   HOUSEKEEPER_BEE_HOME=$(dirname "$HOUSEKEEPER_BEE_SETUP_PATH")
fi

CONTAINER_NAME=db-postgres_container-1
DB_NAME=housekeeper2024v1
DB_PWD=$HOUSEKEEPER_BEE_PWD_DB
FAMILY_ID=$1
FOLDER_NAME=$2
SRC_FOLDER=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/backup/$FAMILY_ID/$FOLDER_NAME
IMG_FOLDER=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/uploads
PWD=$HOUSEKEEPER_BEE_PWD_SUDO

docker exec -e PGPASSWORD=$DB_PWD -i $CONTAINER_NAME psql -U postgres -d $DB_NAME < $SRC_FOLDER/postgres-backup.sql
tar -xvf $SRC_FOLDER/images.tar -C $IMG_FOLDER/$1

