# CRTPi-HDMI2YPbPr

 ## CRTPi-Project HDMI to YPbPr Fork

 ### Introduction
 I've updated the CRTPi instalation to be compatible with the last Retropie version to date. Aditionally this fork has been made to use a generic HDMI 2 YPbPr o Component so we, people from North and South America, can play in full RGB with our SCART-less TVs.

 I took inspiration from the work of [@cjuniorfox](https://github.com/cjuniorfox) who made a script with the same porpuse before.

### Instructions

* Install Retropie 4.8.
* Connect to WiFi or Ethernet with internet access.
* Enable the SSH at raspi-config as [described here](https://retropie.org.uk/docs/SSH/).
* From the same network and any command-line tool like Terminal or CMD, copy and paste the commands below.
> ssh pi@retropie 'bash <(curl -s https://raw.githubusercontent.com/juzt3/CRTPi-HDMI2YPbPr/main/setup.sh)'
* Type the Raspberry's password if asked. The default password generally it's 'raspberry'.
* The automated tool will install all the files needed and finally it will reboot the device.