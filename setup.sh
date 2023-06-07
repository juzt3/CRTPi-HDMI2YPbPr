#!/bin/sh
cd $HOME
sudo apt-get update -y && sudo apt-get install git dialog -y
git clone https://github.com/juzt3/es-theme-raspixel-320-240-mod
sudo mv ./es-theme-raspixel-320-240-mod /etc/emulationstation/themes/es-theme-raspixel-320-240-mod
cd /
sudo wget https://github.com/juzt3/CRTPi-HDMI2YPbPr/raw/main/CRTPi-HDMI2YPbPr.zip
sudo unzip -o -q CRTPi-HDMI2YPbPr.zip
sudo rm CRTPi-HDMI2YPbPr.zip
sudo chmod a+rw -R /opt/retropie/configs/
sudo chmod 775 -R /opt/retropie/configs/all/*.sh
sudo chmod 775 /usr/bin/chvideo.py && sudo a+x /usr/bin/consoledisp.py
sudo reboot