wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/update.sh
wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/pi.sh
wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/reconf.sh
sudo chmod +x update.sh
sudo chmod +x pi.sh 
sudo chmod +x reconf.sh
./update.sh -y
./pi.sh
./update.sh -y

echo "****************************************************************************************************************************"
echo "* Pistop setup complete THANK YOU!!! You can run ./reconf.sh to look at the settings you have used and logs of the setup.  *"
echo "****************************************************************************************************************************"
read -p "Press Enter to reboot."
sudo reboot now
