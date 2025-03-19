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
fdest=/home/thomas/Desktop/housekeeping_bee/files/prog
fname=$(lsblk | grep -i "sda1" | awk '{print $7}')

if found $fname/update_housekeeper_bee.txt; then
echo 'Update server begin!'
echo $pwd | sudo -S -k kill -9 $(ps aux | grep -i '[h]ousekeeper-' | awk '{print $2}')
mv $fdest/housekeeper-0.0.1-SNAPSHOT.jar $fdest/housekeeper-0.0.1-SNAPSHOT.jar.bak
cp $fname/housekeeper-0.0.1-SNAPSHOT.jar $fdest/housekeeper-0.0.1-SNAPSHOT.jar
cp $fname/housekeeper-core-0.0.1-SNAPSHOT.jar $fdest/admin/housekeeper-core-0.0.1-SNAPSHOT.jar
rm $fname/update_housekeeper_bee.txt;
echo $pwd | sudo -S -k eject -F /dev/sda1
sleep 3
reboot
else
	echo "No need up server!"
fi

