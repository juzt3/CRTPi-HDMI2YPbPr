#!/bin/sh
cd $HOME
sudo apt-get update -y && sudo apt-get install git dialog -y
git clone https://github.com/juzt3/es-theme-raspixel-320-240-mod
sudo mv ./es-theme-raspixel-320-240-mod /etc/emulationstation/themes/es-theme-raspixel-320-240-mod
cd /
sudo wget https://github.com/crtpi/CRTPi-RGB/raw/master/CRTPi-HDMI2YPbPr.zip
sudo unzip -o -q CRTPi-HDMI2YPbPr.zip
sudo rm CRTPi-RGB.zip
sudo chmod a+rw -R /opt/retropie/configs/
sudo chmod a+x -R /opt/retropie/configs/all/*.sh
sudo reboot