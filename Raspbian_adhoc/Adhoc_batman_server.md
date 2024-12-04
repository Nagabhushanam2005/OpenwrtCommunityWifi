# Ad-Hoc Network Server Configuration Guide

## Overview
This guide focuses on configuring a Batman-ADV network node as a server, detailing the specific modifications required for server-side setup.

## Network Configuration

### Network Topology
- **Ad-Hoc Network Address Range**: 192.168.199.x
- **Netmask**: 255.255.255.0
- **Server Address**: 192.168.199.1


## Detailed Server Configuration Process

### 1. DHCP Service Installation

The Dynamic Host Configuration Protocol (DHCP) server automates network configuration, dynamically assigning IP addresses and essential network parameters to connecting devices.

```bash
sudo apt-get install -y dnsmasq
```

### 2. DHCP Server Configuration

Configure the network's DHCP settings to define how devices will receive network information:

```bash
sudo nano /etc/dnsmasq.conf
```

Add these lines:

```
interface=bat0
dhcp-range=192.168.199.2,192.168.199.99,255.255.255.0,12h
```

### 3. Server configuration script

1. create a file `~/batman-adv-server.sh` and add the following lines:

```bash
#!/bin/bash
# Network Interface Initialization
sudo batctl if add wlan0
sudo ifconfig bat0 mtu 1468
sudo ifconfig wlo1 down
sudo iwconfig wlo1 mode ad-hoc
sudo iwconfig wlo1 channel 1
sudo iwconfig wlo1 essid fusenet
# Gateway Server Configuration
sudo batctl gw_mode server

# Port Forwarding Activation
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT

# Interface Activation Sequence
sudo ifconfig wlan0 up
sudo ifconfig bat0 up
sudo ifconfig bat0 192.168.199.1/24

```

- `iptables` rules:
  - Implement Network Address Translation
  - Track and permit established connections
  - Enable controlled inter-network communication

2. Apply execution permissions to the script:

```bash
chmod +x ~/batman-adv-server.sh
```

3. To make the script run on boot, add the following line to the /etc/rc.local file:

```bash
batman-adv-server.sh
```

4. Run this command to start the dnsmasq server in the background and assign IP addresses in the range 192.168.1.2 to 192.168.1.100.

```bash
dnsmasq --no-daemon --interface=bat0 --dhcp-range=192.168.199.2,192.168.199.100,12h &
```

5. reboot the system
```bash
reboot
```


