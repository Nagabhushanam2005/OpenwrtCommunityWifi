# Batman-ADV Client Configuration Guide

## Overview
This guide focuses on configuring a Batman-ADV network node as a client, detailing the specific modifications required for client-side setup.

## Client Configuration Script
1. create a `batman-adv-client.sh` file and add the following lines 


```bash
#!/bin/bash

sudo ifconfig wlo1 down
sudo iwconfig wlo1 mode ad-hoc
sudo iwconfig wlo1 channel 1
sudo iwconfig wlo1 essid fusenet

sudo ifconfig wlo1 up
sudo batctl if add wlo1
sudo ifconfig bat0 mtu 1468

sudo batctl gw_mode client

sudo ifconfig bat0 up


```

2. Apply execution permissions to the script:

```bash
chmod +x ~/batman-adv-client.sh
```

3. To make the script run on boot, add the following line to the /etc/rc.local file:

```bash
batman-adv-client.sh
```

4. reboot the system
```bash
reboot
```