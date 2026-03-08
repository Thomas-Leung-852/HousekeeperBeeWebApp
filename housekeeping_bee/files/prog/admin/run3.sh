#!/bin/bash

if [ -z "$HOUSEKEEPER_BEE_HOME" ]; then
   HOUSEKEEPER_BEE_HOME=$(dirname "$HOUSEKEEPER_BEE_SETUP_PATH")
fi

export scheduler_path=$HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/prog/admin/scheduler/
java -jar $HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/prog/admin/housekeeper-core-0.0.1-SNAPSHOT.jar
