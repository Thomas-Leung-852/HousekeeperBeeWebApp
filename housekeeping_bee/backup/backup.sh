  GNU nano 8.1                                                                                   backup.sh                                                                                            #/bin/bash!

CONTAINER_ID=683f980ca753
DB_NAME=housekeeper2024v1
DB_PWD=abcd2468
FAMILY_ID=$1
FOLDER_NAME='HousekeeperBackup'_$(date '+%Y%m%d%H%M%S')
DEST_FOLDER=/home/thomas/Desktop/housekeeping_bee/backup
IMG_FOLDER=/home/thomas/Desktop/housekeeping_bee/files/uploads
PWD=abc123

if [ ! -d "$FAMILY_ID" ]; then
  mkdir $DEST_FOLDER/$FAMILY_ID
fi

mkdir $DEST_FOLDER/$FAMILY_ID/$FOLDER_NAME
docker exec -i -e PGPASSWORD=$DB_PWD $CONTAINER_ID pg_dump --clean -U postgres $DB_NAME  > $DEST_FOLDER/$FAMILY_ID/$FOLDER_NAME/postgres-backup.sql
tar -cvz -f $DEST_FOLDER/$1/$FOLDER_NAME/images.tar -C $IMG_FOLDER/$FAMILY_ID .



