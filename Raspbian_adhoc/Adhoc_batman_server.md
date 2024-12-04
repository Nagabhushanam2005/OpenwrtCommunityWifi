# Ad-Hoc Network Server Configuration Guide

## Understanding Ad-Hoc Networking

An ad-hoc network represents a flexible, dynamically created network configuration that allows devices to communicate directly without relying on a predetermined infrastructure. Unlike traditional network setups, ad-hoc networks can be quickly established, making them ideal for scenarios requiring rapid, decentralized communication.

## Network Configuration Strategy

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

#### Installation Significance
- Deploys the `dnsmasq` network configuration service
- Prepares automated IP address assignment mechanisms
- Establishes foundation for dynamic network management

### 2. DHCP Server Configuration

Configure the network's DHCP settings to define how devices will receive network information:

```bash
sudo nano /etc/dnsmasq.conf
```

Add these critical configuration lines:

```
interface=bat0
dhcp-range=192.168.199.2,192.168.199.99,255.255.255.0,12h
```

#### Configuration Breakdown
- `interface=bat0`: Specifies the primary network interface
- `dhcp-range` parameters:
  - Allocate IP addresses from 192.168.199.2 to 192.168.199.99
  - Apply standard 255.255.255.0 subnet mask
  - Issue 12-hour IP address leases

### 3. Advanced Routing Configuration

Modify the routing script `~/batman.sh` to the following:

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

#### Routing Logic Explained
- `batctl if add wlan0`: Integrates wireless interface into routing
- `batctl gw_mode server`: Establishes advanced gateway functionality
- `net.ipv4.ip_forward=1`: Enables bidirectional network routing
- `iptables` rules:
  - Implement Network Address Translation
  - Track and permit established connections
  - Enable controlled inter-network communication

### 4. Final Configuration Step


```bash
dnsmasq --no-daemon --interface=bat0 --dhcp-range=192.168.199.2,192.168.199.100,12h &
reboot
```
This will start the dnsmasq server in the background and assign IP addresses in the range 192.168.1.2 to 192.168.1.100.
## Diagnostic and Troubleshooting Techniques

- Examine DHCP service logs: `sudo journalctl -u dnsmasq`
- Verify network interface status: `batctl if`
- Review network routing rules: `sudo iptables -L -n -v`


