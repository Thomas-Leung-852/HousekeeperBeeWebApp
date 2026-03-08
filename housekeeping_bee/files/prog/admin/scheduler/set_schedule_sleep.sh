#!/bin/bash

if [ -z "$HOUSEKEEPER_BEE_HOME" ]; then
   HOUSEKEEPER_BEE_HOME=$(dirname "$HOUSEKEEPER_BEE_SETUP_PATH")
fi

crontab -l | grep -v 'prog/admin/scheduler/sleep.sh'  | crontab -
(crontab -l ; echo "$2 $1 * * * /bin/echo $HOUSEKEEPER_BEE_PWD_SUDO | /bin/sudo -S -k $HOUSEKEEPER_BEE_HOME/housekeeping_bee/files/prog/admin/scheduler/sleep.sh $3") | crontab -
