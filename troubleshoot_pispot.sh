#!/bin/bash
# PiSpot Wi-Fi Hotspot Troubleshooting Script
# This script helps diagnose common hotspot issues on your Raspberry Pi

set -e

# 1. Check if HostAPD is Running

echo "\n[1/7] Checking hostapd status..."
status_output=$(sudo systemctl is-active hostapd 2>&1)
if [ "$status_output" = "active" ]; then
    echo "hostapd is running."
else
    echo "hostapd is NOT running (status: $status_output)."
    echo "Attempting to restart hostapd..."
    sudo systemctl restart hostapd
    sleep 2
    status_output2=$(sudo systemctl is-active hostapd 2>&1)
    if [ "$status_output2" = "active" ]; then
        echo "hostapd started successfully after restart."
    else
        echo "hostapd still not running (status: $status_output2)."
        echo "There may be a configuration or installation issue."
        echo "Try reinstalling hostapd or ask an AI assistant for help with the error above."
    fi
fi

# 2. Verify Wi-Fi Interface

echo "\n[2/7] Checking wlan0 interface..."
if ! iwconfig wlan0 2>&1 | grep -q 'no wireless extensions.'; then
    iwconfig wlan0
else
    echo "wlan0 not up. Trying to bring it up..."
    sudo ip link set wlan0 up
    iwconfig wlan0
fi

# 3. Confirm SSID is Set Correctly

echo "\n[3/7] Showing /etc/hostapd/hostapd.conf (please verify SSID, password, and visibility):"
echo "--- /etc/hostapd/hostapd.conf ---"
sudo cat /etc/hostapd/hostapd.conf
cat <<EOM

Ensure it contains:
interface=wlan0
ssid=<your-ssid>
hw_mode=g
channel=7
wpa=2
wpa_passphrase=<your-password>
ignore_broadcast_ssid=<0-or-1>
Replace <your-ssid>, <your-password>, and <0-or-1> with your actual values.
EOM

# 4. Restart Services

echo "\n[4/7] Restarting services..."
sudo systemctl restart hostapd
echo "Restarting dnsmasq..."
sudo systemctl restart dnsmasq
echo "Restarting networking..."
sudo systemctl restart networking || echo "[INFO] 'networking' service may not exist on all systems."

# 5. Scan for Wi-Fi Networks

echo "\n[5/7] Scanning for Wi-Fi networks (look for your SSID):"
sudo iwlist wlan0 scan | grep SSID || echo "No SSIDs found."

# 6. Check for Conflicting Services

echo "\n[6/7] Checking for NetworkManager..."
if systemctl is-active --quiet NetworkManager; then
    echo "NetworkManager is running. Stopping and disabling it to avoid conflicts."
    sudo systemctl stop NetworkManager
    sudo systemctl disable NetworkManager
else
    echo "NetworkManager is not running."
fi

# 7. Suggest Reboot

echo "\n[7/7] Troubleshooting steps complete. It is recommended to reboot your Pi."
echo "Run: sudo reboot"
