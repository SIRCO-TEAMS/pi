#!/bin/bash
./update.sh -y

sudo rm update.sh && sudo rm pi.sh && sudo rm start.sh && sudo rm troubleshoot_pispot.sh && sudo rm nginx.sh && sudo rm node_pispot.sh && sudo rm reconf.sh

echo "****************************************************************************************************************************"
echo "* Pistop setup complete THANK YOU!!! You can run ./reconf.sh to look at the settings you have used and logs of the setup.  *"
echo "****************************************************************************************************************************"
echo "==== FINAL STEP ===="
echo "Unplug the ethernet cable from your Pi now."
read -p "Press ENTER to reboot and finish setup..." _
sleep 1