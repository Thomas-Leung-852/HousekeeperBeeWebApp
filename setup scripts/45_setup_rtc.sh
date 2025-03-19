#!/usr/bin/bash
sudo apt install i2c-tools -y
sudo apt install raspi-config -y
sudo raspi-config
#Go to Interface Option >> select I2C >> enable I2C
cat /boot/firmware/config.txt | grep -v dtparam=rtc_bbat_vchg | sudo tee "/boot/firmware/config.txt" > /dev/null
echo 'dtparam=rtc_bbat_vchg=3000000' | sudo tee -a "/boot/firmware/config.txt"
sudo -E rpi-eeprom-config --edit
#Adding the following two lines.
# POWER_OFF_ON_HALT=1
# WAKE_ON_GPIO=0
