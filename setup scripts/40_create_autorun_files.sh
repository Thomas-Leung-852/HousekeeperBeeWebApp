#!/bin/bash

if [ ! -d "~/.config/autostart" ]; then 
sudo mkdir ~/.config/autostart
fi

sudo touch ~/.config/autostart/lauch_java_prog_1.desktop
sudo touch ~/.config/autostart/lauch_java_prog_2.desktop

echo "[Desktop Entry]
Type=Application
Exec=gnome-terminal -- bash -c \"/home/thomas/Desktop/housekeeping_bee/files/prog/admin/run3.sh; exec bash\"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[C]=housekeeper bee admin server
Name=housekeeper bee admin server
Comment[C]=
Comment=
" | sudo tee -a  ~/.config/autostart/lauch_java_prog_1.desktop >> /dev/null

echo "[Desktop Entry]
Type=Application
Exec=gnome-terminal -- bash -c \"/home/thomas/Desktop/housekeeping_bee/files/prog/run3.sh; exec bash\"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[C]=housekeeper bee backend server
Name=housekeeper bee backend server
Comment[C]=
Comment=
" | sudo tee -a ~/.config/autostart/lauch_java_prog_2.desktop >> /dev/null
