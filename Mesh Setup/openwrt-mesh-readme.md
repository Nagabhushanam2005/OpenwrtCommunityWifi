# OpenWrt IEEE 802.11s Wireless Mesh Network Setup Guide

## Overview

This guide provides instructions for setting up an IEEE 802.11s wireless mesh network using OpenWrt access point.

## Prerequisites

- OpenWrt version 19.07 or later
- Wireless drivers with 802.11s mesh point support
- Mesh-capable wpad package

## Preliminary Compatibility Check

Before proceeding, verify your wireless driver's mesh networking capabilities:

```bash
iw list | grep "Supported interface modes" -A 9
```

### Mesh Point Support Detection

1. If "mesh point" is present in the output:
   - Proceed with IEEE 802.11s Mesh Point configuration
   
2. If "mesh point" is NOT present:
   - Use the Ad-Hoc Mode configuration section

## Installation Steps

1. Update OpenWrt packages:
   ```
   opkg update
   ```

2. Install mesh-capable wpad:
   ```
   opkg install wpad-mesh-mbedtls
   ```

3. Remove basic wpad package:
   ```
   opkg remove wpad-basic-mbedtls
   ```

## Configuration

### Using LuCI Web Interface

1. Navigate to Network → Wireless
2. Add new wireless interface
3. Set Mode to '802.11s'
4. Choose a shared Mesh ID
5. Select LAN network
6. Configure wireless security (recommended: WPA3-SAE)

### Manually Editing `/etc/config/wireless`

Example configuration:
```
config wifi-iface 'mesh'
    option device 'radio0'
    option disabled '0'
    option mode 'mesh'
    option ifname 'mesh0'
    option network 'lan'
    option mesh_id 'my-mesh-id'
    option encryption 'sae'
    option key 'your-secret-password'
    option mesh_hwmp_rootmode '3'
    option mesh_gate_announcements '1'
```

## Key Configuration Options

- `mesh_id`: Unique identifier for your mesh network (must be same on all nodes)
- `mesh_hwmp_rootmode`: Routing mode (recommended: 3 or 4)
  - `0`: Default, no root-specific activities
  - `3`: Periodic PREQ messages, responds to other stations
  - `4`: Proactive RANN announcements
- `mesh_gate_announcements`: Enable gateway announcements (1 for mesh portals)

## Verification

Verify mesh network status:
```
wifi
iw dev mesh0 info
iw dev mesh0 station dump
iw dev mesh0 mpath dump
```

## Troubleshooting

- Ensure all nodes have:
  - Same mesh_id
  - Same channel
  - Same encryption key
- Check wireless driver compatibility
- Verify wpad package supports mesh encryption




