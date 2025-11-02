#!/bin/bash

cur_dir=$(pwd)

cd ./server

#======== Install dependencies ======== 

sudo npm install
wait

#======== Update firewall rules =======
sudo ufw allow 3000
sudo ufw allow 3443
sudo ufw allow 9999
sudo ufw reload

#======== Create launch server startup ========

if [ ! -d ~/.config/autostart ]; then 
sudo mkdir ~/.config/autostart
fi

sudo touch ~/.config/autostart/lauch_housekeeper_bee_finder.desktop

echo "[Desktop Entry]
Type=Application
Exec=gnome-terminal -- bash -c \"${cur_dir}/run_server.sh; exec bash\"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[C]=housekeeper bee finder server
Name=housekeeper bee finder
Comment[C]=
Comment=
" | sudo tee -a ~/.config/autostart/lauch_housekeeper_bee_finder.desktop >> /dev/null


#======== Create start server shell script ========

cd ${cur_dir}

sudo touch run_server.sh

echo "#!/bin/bash
clear
cd ${cur_dir}/server
npm start
" | sudo tee -a ${cur_dir}/run_server.sh  >> /dev/null

sudo chmod +x run_server.sh


