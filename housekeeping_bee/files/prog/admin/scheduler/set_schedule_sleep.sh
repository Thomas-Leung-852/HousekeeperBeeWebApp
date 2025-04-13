#!/bin/bash
crontab -l | grep -v 'prog/admin/scheduler/sleep.sh'  | crontab -
(crontab -l ; echo "$2 $1 * * * /bin/echo $HOUSEKEEPER_BEE_PWD_SUDO | /bin/sudo -S -k ~/Desktop/housekeeping_bee/files/prog/admin/scheduler/sleep.sh $3") | crontab -
