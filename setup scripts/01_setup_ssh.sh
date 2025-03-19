#! /usr/bin/bash
sudo apt update
sudo apt install openssh-client openssh-server -y
sudo systemctl start ssh
sudo systemctl enable ssh
#sudo nano /etc/ssh/sshd_config
sudo sed -i "s/#Port 22/Port 22/g" /etc/ssh/sshd_config
sudo ufw enable
sudo ufw allow 22
sudo ufw reload
sudo systemctl status ssh

