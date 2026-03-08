#!/bin/bash

if [ -z "$HOUSEKEEPER_BEE_HOME" ]; then
   HOUSEKEEPER_BEE_HOME=$(dirname "$HOUSEKEEPER_BEE_SETUP_PATH")
fi

CONTAINER_NAME=db-postgres_container-1
DB_NAME=housekeeper2024v1
DB_PWD=$HOUSEKEEPER_BEE_PWD_DB
FAMILY_ID=$1
FOLDER_NAME='HousekeeperBackup'_$(date '+%Y%m%d%H%M%S')
DEST_FOLDER=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/backup
IMG_FOLDER=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/uploads
PWD=$HOUSEKEEPER_BEE_PWD_SUDO

if [ ! -d "$FAMILY_ID" ]; then
  mkdir $DEST_FOLDER/$FAMILY_ID
fi

mkdir $DEST_FOLDER/$FAMILY_ID/$FOLDER_NAME
docker exec -i -e PGPASSWORD=$DB_PWD $CONTAINER_NAME pg_dump --clean -U postgres $DB_NAME  > $DEST_FOLDER/$FAMILY_ID/$FOLDER_NAME/postgres-backup.sql
tar -cvz -f $DEST_FOLDER/$1/$FOLDER_NAME/images.tar -C $IMG_FOLDER/$FAMILY_ID .



