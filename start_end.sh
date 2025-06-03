#!/bin/bash
./update.sh -y

sudo rm update.sh && sudo rm pi.sh && sudo rm start.sh

echo "****************************************************************************************************************************"
echo "* Pistop setup complete THANK YOU!!! You can run ./reconf.sh to look at the settings you have used and logs of the setup.  *"
echo "****************************************************************************************************************************"
read -p "Press Enter to reboot."
sudo reboot now