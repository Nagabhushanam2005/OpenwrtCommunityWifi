
# Ad-hoc Architecture Implementation Guide

## Using Batman-adv Protocol on Raspberry Pi Systems with raspbian os

### Introduction

This document outlines the implementation process for creating a robust, ad-hoc network infrastructure using the Batman-adv protocol on Raspberry Pi devices using raspbian os. This solution enables peer-to-peer connectivity without relying on centralized access points, making it suitable for scenarios where traditional network infrastructure is unavailable or impractical.



### System Preparation

#### Base System Configuration

1. Download and flash Raspbian Lite onto an SD card.
2. Enable SSH access by creating an empty file named `ssh` in the boot partition of the SD card using the appropriate command
```bash
Linux : touch ssh

MacOS : touch ssh

Windows command prompt : type NUL >> ssh

Windows PowerShell : echo $null >> ssh
```

3. Power on the Raspberry Pi and establish an SSH connection if it is headless-setup.

#### System Optimization

1. Access the system configuration utility using the following command:

```bash
sudo raspi-config
```

2. Configure the following essential parameters:
    * Security credentials (username and password)
    * System localization (language, timezone)
    * Network settings (static or DHCP)
    * Interface settings (enable SSH)

3. Save configuration changes and reboot the system.

4. Execute a full system update:

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo reboot
```

### Batman-adv Implementation
Make sure rpi has network connectivity to install packages.
* Network connectivity for initial setup (optional) Refer this [rpi_connection_to_home_network](/OpenwrtCommunityWifi/rpi_to_home_network.md)
#### Installation

Install the Batman-adv control utility using the following command:

```bash
sudo apt-get install -y batctl
```

#### Protocol Configuration Script

1. Create a script named `batman.sh` in your home directory (`~/batman.sh`) with the following content:

```bash
#!/bin/bash

# Interface Configuration
sudo batctl if add wlan0
sudo ifconfig bat0 mtu 1468


# Interface Activation
sudo ifconfig wlan0 up
sudo ifconfig bat0 up
```

2. Apply execution permissions to the script:

```bash
chmod +x ~/batman.sh
```

#### Network Interface Definition

1. Create a file named `wlan0` within the network interface configuration directory (`/etc/network/interfaces.d/wlan0`) with the following content:

```
auto wlan0
iface wlan0 inet manual
    wireless-channel 3
    wireless-essid <your_network_name>
    wireless-mode ad-hoc
```

**Note:** Replace `<your_network_name>` with a unique identifier for your ad-hoc network.

### System Integration


1. Enable the `batman-adv` by appending it to the `/etc/modules` file:

```bash
echo 'batman-adv' | sudo tee --append /etc/modules
```

2. Reboot the system to load the module.

#### Network Management

1. Configure DHCP behavior to prevent automatic IP assignment on the wireless interface:

```bash
echo 'denyinterfaces wlan0' | sudo tee --append /etc/dhcpcd.conf
```

#### Automation Setup

1. Modify the `/etc/rc.local` file to automatically execute the `batman.sh` script during system startup:

```bash
sudo sed -i '/^exit 0/i /home/pi/batman.sh &' /etc/rc.local
```



### Troubleshooting 

* **Protocol Status:**

```bash
batctl n
```

* **Interface Status:**

```bash
ip link show
```

* **System Logs:**

```bash
journalctl -u batman-adv
```
After completing the batman installtion and setup the rpi needs to be configured either as a
* a Ad-hoc Server that acts a dhcp server and assign ip addresses to all other ad-hoc devices [ad-hoc server](Adhoc_batman_server.md)
* a Ad-hoc Client [ad-hoc_client](Adhoc_batman_client.md)