#/bin/bash!

CONTAINER_NAME=db-postgres_container-1
DB_NAME=housekeeper2024v1
DB_PWD=abcd2468
FAMILY_ID=$1
FOLDER_NAME=$2
SRC_FOLDER=~/Desktop/housekeeping_bee/backup/$FAMILY_ID/$FOLDER_NAME
IMG_FOLDER=~/Desktop/housekeeping_bee/files/uploads
PWD=abc123

docker exec -e PGPASSWORD=$DB_PWD -i $CONTAINER_NAME psql -U postgres -d $DB_NAME < $SRC_FOLDER/postgres-backup.sql
tar -xvf $SRC_FOLDER/images.tar -C $IMG_FOLDER/$1

