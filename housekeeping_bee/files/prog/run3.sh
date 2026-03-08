#!/bin/bash

if [ -z "$HOUSEKEEPER_BEE_HOME" ]; then
   export HOUSEKEEPER_BEE_HOME=$(dirname "$HOUSEKEEPER_BEE_SETUP_PATH")
fi

export housekeeper_bee_sys_img=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/sys/images/
export housekeeper_bee_upload_path=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/uploads/
export housekeeper_bee_backup_restore=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/backup/
export db_pwd=$HOUSEKEEPER_BEE_PWD_DB
export deploy_env=dev
export domain_name=192.168.50.187:8080
export email_user_id_dev=id
export email_api_key_dev=key
export email_api_key_prod=xxx
export sender_email_address=support@a.com
export server_location=onsite
export license_key=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/prog/license.yaml
export keystore_pwd=abc123
export service_print_server_secret=adaNfriends
cd $HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/prog
java -jar housekeeper-0.0.1-SNAPSHOT.jar --spring.config.location=application.properties
