#!/bin/bash
pwd=abc123
tm=$(echo $pwd | sudo -S -k cat /sys/class/rtc/rtc0/wakealarm)
if [ ! -z $tm ]; then
echo 'clear wakealarm'
echo -$tm | sudo tee /sys/class/rtc/rtc0/wakealarm
fi
minutes=$1
new_tm=$((minutes * 60))
echo $pwd | echo +$new_tm | sudo tee /sys/class/rtc/rtc0/wakealarm
echo $pwd | sudo halt

