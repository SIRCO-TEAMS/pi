sudo apt-get update
sudo apt-get install -y rfkill

wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/update.sh
wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/pi.sh
wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/reconf.sh
wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/start_end.sh
wget https://raw.githubusercontent.com/SIRCO-TEAMS/pi/refs/heads/main/troubleshoot_pispot.sh
sudo chmod +x update.sh
sudo chmod +x pi.sh 
sudo chmod +x reconf.sh
sudo chmod +x start_end.sh
sudo chmod +x troubleshoot_pispot.sh

echo "\n*** Now starting PiSpot Automated Setup. ***\n"