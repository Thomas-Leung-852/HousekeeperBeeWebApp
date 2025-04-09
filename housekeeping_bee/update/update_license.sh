#!/bin/sh

# 0 = true, 1 = false
found(){
   if test -f $1; then
       return 0
   else
       return 1
   fi
}

#Do update
sleep 1
pwd="abc123"
fdest=~/Desktop/housekeeping_bee/files/prog
fname=$(lsblk | grep -i "sda1" | awk '{print $7}')

#Update License Key
if found $fname/update_housekeeper_bee_license.txt; then
echo 'Update License Key begin!'
mv $fdest/license.yaml $fdest/license.yaml.bak
cp $fname/license.yaml $fdest/license.yaml
rm $fname/update_housekeeper_bee_license.txt;
echo $pwd | sudo -S -k eject -F /dev/sda1
sleep 3
reboot
else
        echo "No need update License Key!"
fi


