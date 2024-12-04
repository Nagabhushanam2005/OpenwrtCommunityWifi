# Batman-ADV Client Configuration Guide

## Overview
This guide focuses on configuring a Batman-ADV network node as a client, detailing the specific modifications required for client-side setup.

## Client Configuration Script
change the `batman.sh` contents to the following for client-side setup

### Updated Script Content
```bash
#!/bin/bash

# Batman-ADV Client Configuration Script

# Disable wireless interface
sudo ifconfig wlo1 down

# Set wireless interface to ad-hoc mode
sudo iwconfig wlo1 mode ad-hoc

# Configure wireless channel
sudo iwconfig wlo1 channel 1

# Set network name (ESSID)
sudo iwconfig wlo1 essid fusenet

# Activate wireless interface
sudo ifconfig wlo1 up

# Add interface to Batman-ADV
sudo batctl if add wlo1

# Set MTU for Batman interface
sudo ifconfig bat0 mtu 1468

# Set gateway mode to CLIENT
sudo batctl gw_mode client

# Ensure interfaces are activated
sudo ifconfig wlo1 up
sudo ifconfig bat0 up
```

