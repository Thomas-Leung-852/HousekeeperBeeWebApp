#!/bin/bash
crontab -l | grep -v 'prog/admin/scheduler/sleep.sh'  | crontab -
pwd=abc123
tm=$(echo $pwd | sudo -S -k cat /sys/class/rtc/rtc0/wakealarm)
if [ ! -z $tm ]; then
echo 'clear wakealarm'
echo -$tm | sudo tee /sys/class/rtc/rtc0/wakealarm
fi

