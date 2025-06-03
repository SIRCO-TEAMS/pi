# PiSpot Wi-Fi Hotspot Troubleshooting & Setup Guide

## Troubleshooting: If You Can't Connect to the Hotspot

### 1. Check if HostAPD is Running
```bash
sudo systemctl status hostapd
sudo systemctl restart hostapd
```

### 2. Verify Wi-Fi Interface
```bash
iwconfig wlan0
sudo ip link set wlan0 up
```

### 3. Confirm SSID is Set Correctly
```bash
sudo nano /etc/hostapd/hostapd.conf
```
Ensure it contains:
```
interface=wlan0
ssid=<your-ssid>
hw_mode=g
channel=7
wpa=2
wpa_passphrase=<your-password>
ignore_broadcast_ssid=<0-or-1>
```
Replace `<your-ssid>`, `<your-password>`, and `<0-or-1>` with the values you set during setup.

### 4. Restart Services
```bash
sudo systemctl restart hostapd
dnsmasq
networking
```

### 5. Scan for Wi-Fi Networks
```bash
sudo iwlist wlan0 scan | grep SSID
```

### 6. Check for Conflicting Services
```bash
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
```

### 7. Reboot
```bash
sudo reboot
```

---

# Complete Raspberry Pi Setup Guide

## Part 1: Setting Up a Wi-Fi Hotspot

1. Download Raspberry Pi OS Lite and flash it to your SD card.
2. Update and install required packages:
   ```bash
   sudo apt update
   sudo apt upgrade
   sudo apt install hostapd dnsmasq iptables iw
   ```
3. Configure `/etc/dnsmasq.conf`:
   ```
   interface=wlan0
   dhcp-range=192.168.4.10,192.168.4.100,255.255.255.0,24h
   ```
4. Configure `/etc/hostapd/hostapd.conf`:
   ```
   interface=wlan0
   ssid=LS7
   hw_mode=g
   channel=7
   wpa=2
   wpa_passphrase=Therizzler2025
   ignore_broadcast_ssid=1
   ```
5. Enable and start services:
   ```bash
   sudo systemctl unmask hostapd
   sudo systemctl enable hostapd
   sudo systemctl start hostapd
   sudo systemctl enable dnsmasq
   sudo systemctl start dnsmasq
   ```

## Part 2: Automatic Shutdown at 6:00 PM

1. Create `/home/timour/shutdown_at_6pm.sh`:
   ```bash
   #!/bin/bash
   if [ -f /home/timour/stop_shutdown ]; then
       echo "Shutdown aborted because the override file exists."
       exit 0
   fi
   sudo shutdown -h now
   ```
2. Make it executable and add to crontab:
   ```bash
   chmod +x /home/timour/shutdown_at_6pm.sh
   crontab -e
   # Add:
   0 18 * * * /home/timour/shutdown_at_6pm.sh
   ```

## Part 3: Nginx Setup

1. Install and configure Nginx:
   ```bash
   sudo apt install nginx
   sudo nano /etc/nginx/sites-available/default
   # Change port to 8080
   sudo systemctl restart nginx
   ```

## Part 4: Cockpit Web Console

1. Install Cockpit:
   ```bash
   sudo apt install cockpit
   sudo nano /etc/cockpit/cockpit.conf
   # Add:
   [WebService]
   Port = 9090
   sudo systemctl enable cockpit.socket
   sudo systemctl start cockpit.socket
   ```

## Part 5: Mesh Networking (batman-adv)

1. Install and configure batman-adv:
   ```bash
   sudo apt install batctl
   sudo nano /etc/network/interfaces.d/wlan0
   # Add mesh config as needed
   ```

## Part 6: Restrict Internet Access

1. Set up iptables rules and ensure they restore on boot.

---

**After setup, reboot and verify each service.**
