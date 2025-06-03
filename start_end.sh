#!/bin/bash
./update.sh -y

sudo rm update.sh && sudo rm pi.sh && sudo rm start.sh

echo "****************************************************************************************************************************"
echo "* Pistop setup complete THANK YOU!!! You can run ./reconf.sh to look at the settings you have used and logs of the setup.  *"
echo "****************************************************************************************************************************"
echo "==== FINAL STEP ===="
echo "Unplug the ethernet cable from your Pi now."
read -p "Press ENTER to reboot and finish setup..." _
sudo reboot