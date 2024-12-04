# Connecting Raspberry Pi to Home/Office Network

## Overview
Setting up network connectivity on a Raspberry Pi is a crucial first step for most projects. This guide covers multiple methods to connect your Raspberry Pi to WiFi, verify network connectivity, discover your device on the network, and enable remote access via SSH.

## WiFi Configuration Methods

### Method 1: Using raspi-config
The `raspi-config` utility provides a user-friendly interface for configuring your Raspberry Pi, including WiFi settings.

```bash
sudo raspi-config
# Navigate to: System Options > Wireless LAN
# Enter SSID and Password
```

### Method 2: Manually Editing Network Configuration
For more advanced users or specific network setups, manually editing the `wpa_supplicant.conf` file offers greater flexibility.

```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

# Add network configuration
network={
    ssid="YourNetworkName"
    psk="YourNetworkPassword"
    key_mgmt=WPA-PSK
}

# Save and exit
sudo reboot
```

## Verifying Network Connection

### Network Interface Information
Use the following commands to check your WiFi connection status and IP address:

```bash
# Check WiFi IP address
ip addr show wlan0

# Test internet connectivity
ping 8.8.8.8
```

## Discovering Raspberry Pi on Network

### Network Scanning Methods
Multiple techniques can help you locate your Raspberry Pi's IP address on the network:

```bash
# Network scanning methods
hostname -I
nmap -sn 192.168.1.0/24

# Alternative network discovery
arp -a
```

## SSH Access and Remote Connection

### Enabling SSH
Remote access is disabled by default. Enable it through `raspi-config`:

```bash
# Enable SSH if disabled
sudo raspi-config
# Interfacing Options > SSH > Enable
```

### Connecting via SSH
Once SSH is enabled, connect remotely:

```bash
# Connect to Raspberry Pi
ssh pi@<raspberry_pi_ip_address>
```

## Troubleshooting Common Issues
- Incorrect WiFi password
- Out-of-range WiFi signal
- Incompatible WiFi adapter
- Network configuration errors
