#!/bin/bash
crontab -l | grep -v 'prog/admin/scheduler/sleep.sh'  | crontab -
(crontab -l ; echo "$2 $1 * * * /bin/echo abc123 | /bin/sudo -S -k ~/Desktop/housekeeping_bee/files/prog/admin/scheduler/sleep.sh $3") | crontab -
