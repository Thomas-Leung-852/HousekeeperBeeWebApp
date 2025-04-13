#! /usr/bin/bash

#################################################################################
# setup rootless docker
#################################################################################

id -u
whoami
grep ^$(whoami): /etc/subuid
sudo apt-get install -y dbus-user-session
sudo apt-get install -y uidmap
sudo apt-get install -y systemd-container
filename=$(echo $HOME/bin/rootlesskit | sed -e s@^/@@ -e s@/@.@g)

# input the following code block to terminal:
cat <<EOF > ~/${filename}
abi <abi/4.0>,
include <tunables/global>

"$HOME/bin/rootlesskit" flags=(unconfined) {
  userns,

  include if exists <local/${filename}>
}
EOF

sudo mv ~/${filename} /etc/apparmor.d/${filename}
systemctl restart apparmor.service
sudo usermod -a -G docker $USER
sudo reboot
