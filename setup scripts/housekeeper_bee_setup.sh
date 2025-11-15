#!/bin/bash

#Functions
function show_msg()
{
	echo 
	echo "================================================================="
	echo $1
	echo "================================================================="
}

#Main
sleep 1
autostart_fn=housekeeper_bee_setup_part2.desktop

if [ -z "$1"  ]; then

	# set env variables
	su_pwd=""
	db_pwd=""

	while [ -z "$su_pwd" ] || [ -z "$db_pwd" ]
	do
		echo -n "Input sudo password:" 
		read -s su_pwd
		echo
		echo -n "Setup housekeeper bee database password:"
		read -s db_pwd
		echo

		if [ -z "$su_pwd" ] || [ -z "$db_pwd" ]; then
			echo "******************************"
			echo "err: Not allow empty password!"
		 	echo "******************************"
		fi
	done

	#setup_path=$(pwd | awk '{gsub(/ /,"\\ ");print}') #/
	setup_path=$(pwd) #/
	path2=$(pwd | awk '{gsub(/ /,"\\\\ ");print}')
	fn=~/.profile
	sed -i '/housekeeper_bee/Id' $fn
	# echo '' >> $fn
	echo '# housekeeper_bee - environment variables::begin' >> $fn
	echo 'export HOUSEKEEPER_BEE_PWD_SUDO='$su_pwd >> $fn
	echo 'export HOUSEKEEPER_BEE_PWD_DB='$db_pwd >> $fn
	echo 'export HOUSEKEEPER_BEE_SETUP_PATH="'$setup_path'"' >> $fn
	echo '# housekeeper_bee - environment variables::end' >> $fn
	# echo '' >> $fn
	echo 'file:' $fn ' updated.'


	# prepare continues setup after rebooting

	if [ ! -d ~/.config/autostart ]; then 
		sudo mkdir ~/.config/autostart
	fi

	sudo rm -f ~/.config/autostart/$autostart_fn
	sudo touch ~/.config/autostart/$autostart_fn

	echo "[Desktop Entry]
	Type=Application
	Exec=gnome-terminal -- bash -c \"$path2/housekeeper_bee_setup.sh part2; exec bash\"
	Hidden=false
	NoDisplay=false
	X-GNOME-Autostart-enabled=true
	Name[C]=housekeeper bee setup part 2
	Name=housekeeper bee setup part 2
	Comment[C]=
	Comment=
	" | sudo tee -a  ~/.config/autostart/$autostart_fn >> /dev/null

	#run part A scripts
	show_msg "Initial ...."
	./00_init.sh "$su_pwd" 
	wait
	show_msg "Install SSH package."
	./01_setup_ssh.sh 
	wait
	show_msg "Install docker package."
	./05_install_docker.sh  
	wait
	show_msg "Setup rootless docker."
	./10_rootless_docker.sh 
	wait

elif [ $1 == "part2" ]; then
	su_pwd=$HOUSEKEEPER_BEE_PWD_SUDO
	db_pwd=$HOUSEKEEPER_BEE_PWD_DB
	setup_path=$HOUSEKEEPER_BEE_SETUP_PATH
	# cd ~/.config/autostart
	echo "Continuse Setup ......"
	sudo rm -f ~/.config/autostart/$autostart_fn
	cd "$setup_path"

	show_msg "Install PostgerSQL database."
	./15_setup_db.sh 
	wait
	show_msg "Initial Housekeeper Bee database."
	./20_restore_db.sh 
	wait
	show_msg "Install Java runtime and JDK."
	./25_install_java.sh  
	wait
	show_msg "Change files mode."
	./30_chmod_script_files.sh 
	wait 
	show_msg "Update firewall setting."
	./35_update_firewall.sh 
	wait
	show_msg "Add autostart."
 	./40_create_autorun_files.sh 
	wait
	show_msg "Setup RTC."
 	./45_setup_rtc.sh 
	wait 
	show_msg "Install sensors."
	./50_install_sensor.sh 
	wait
	show_msg "Setup finder server."
        ./55_setup_finder.sh
        wait 

	show_msg "Completed!"

        read -n 1 -s -r -p "Press any key to reboot..."              # Wait
        echo                                                         # Add a newline after keypress
        sudo reboot                                                 # reboot to apply the changes

else
	echo "error" 
	show_msg "Oop! Something wrong!"
fi





