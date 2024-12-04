
# Ad-hoc Architecture Implementation Guide

## Using Batman-adv Protocol on Raspberry Pi Systems with raspbian os

### Introduction

This document outlines the implementation process for creating a robust, ad-hoc network infrastructure using the Batman-adv protocol on Raspberry Pi devices using raspbian os. This solution enables peer-to-peer connectivity without relying on centralized access points, making it suitable for scenarios where traditional network infrastructure is unavailable or impractical.


### Batman-adv Implementation
Make sure rpi has network connectivity to install packages.

#### Installation

Install the Batman-adv control utility using the following command:

```bash
sudo apt-get install -y batctl
```


#### Network Interface creation

1. Create a file named `wlan0` within the network interface configuration directory (`/etc/network/interfaces.d/wlan0`) with the following content:

```
auto wlan0
iface wlan0 inet manual
    wireless-channel 3
    wireless-essid <your_network_name>
    wireless-mode ad-hoc
```

**Note:** Replace `<your_network_name>` with a unique identifier for your ad-hoc network.


1. Enable the `batman-adv` by appending it to the `/etc/modules` file:

```bash
echo 'batman-adv' | sudo tee --append /etc/modules
```

2. Reboot the system with `reboot`.
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

After completing the batman installtion and setup the rpi needs to be configured either as a
* a Ad-hoc Server that acts a dhcp server and assign ip addresses to all other ad-hoc devices [ad-hoc server](Adhoc_batman_server.md)
* a Ad-hoc Client [ad-hoc_client](Adhoc_batman_client.md)