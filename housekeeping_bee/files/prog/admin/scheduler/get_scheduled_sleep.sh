#!/bin/bash
hr=$(crontab -l | grep housekeeping_bee/files/prog/admin/scheduler/sleep.sh | cut -d' ' -f 2)
mm=$(crontab -l | grep housekeeping_bee/files/prog/admin/scheduler/sleep.sh | cut -d' ' -f 1)
duration=$(crontab -l | grep housekeeping_bee/files/prog/admin/scheduler/sleep.sh | cut -d' ' -f 13)
if [ ! -z $duration ]; then
   wakeup=$(date -d "$hr:$mm $duration minutes" +'%H:%M')
   echo "Scheduled sleep at $hr:$mm and wakeup at $wakeup"
else
   echo "No Scheduled sleep"
fi
