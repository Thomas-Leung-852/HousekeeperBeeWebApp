#!/bin/bash

#====== Install node js ==============

# sudo apt-get purge nodejs -y
# sudo apt-get autoremove

# Check if npm is installed
isMissing="true"

if command -v npm &> /dev/null; then
    # npm is installed, check its version
    NPM_VERSION=$(node -v | cut -d'.' -f1)
    if [ "$NPM_VERSION" == "v24" ]; then
        echo "npm version 24 is already installed."
        isMissing="false"
    else
        echo "npm is installed, but it's not version 24 (current version: $NPM_VERSION). Installing Node.js 24 and npm."
    fi
else
    echo "npm is not found."
fi

if [ "$isMissing" == "true" ]; then
   echo "Installing Node.js 24 and npm."

   # Install Node.js 24 and npm if not already installed or not version 24
   echo "Adding Node.js 24 repository and installing..."
   curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
   sudo apt install nodejs

   echo "Verifying npm installation..."
   if command -v npm &> /dev/null; then
       NPM_VERSION=$(node -v | cut -d'.' -f1)
       if [ "$NPM_VERSION" == "v24" ]; then
           echo "npm version 24 successfully installed."
       else
           echo "npm installed, but version check failed after installation. Current version: $NPM_VERSION."
           exit 1
       fi
   else
       echo "npm command not found after installation attempt. Please investigate."
       exit 1
   fi
else
   echo "Node.js 24 already installed"
fi

#======= Start Setup finder ===========

echo "Setup finder server and auto start..."

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


echo "=========================================================="
echo " Completed!                                               "
echo " Reboot the device to start the Housekeeper Bee finder.   "
echo "=========================================================="
echo                                                         # Add a newline after keypress



