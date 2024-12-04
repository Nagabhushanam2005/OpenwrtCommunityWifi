# OpenwrtCommunityWifi

## Description

This project is a simple OpenWRT configuration to create a community wifi network. The idea is to have a mesh network of Raspberry Pi 4b devices that can be used to provide internet access to a community. The IEEE802.11s mesh networking protocol with BATMAN routing protocol is used to create the mesh network. The Raspberry Pi 4b devices are configured as mesh gates (access points) that provide internet access to user devices.

## Features

- IEEE802.11s mesh networking protocol
- BATMAN routing protocol

## Firmware Configuration

<!-- firmware.md -->

To build the firmware, follow the documentation in the [Firmware and flashing into Raspberry Pi 4b](firmware/firmware.md) section.

## Network Configuration using OpenWrt with BATMAN-ADV

OpenWrt is a Linux distribution for embedded devices. It is used to create a ad-hoc network with the BATMAN-ADV routing protocol. The Raspberry Pi 4b devices are configured as server and client. Follow the documentation in the [Ad-Hoc Network Configuration using OpenWrt with BATMAN-ADV](AdHoc/OpenWRT.md) section.

## Network Configuration using raspbian with BATMAN-ADV (optional)
To create a ad-hoc network with raspbian os and BATMAN-ADV routing protocol follow the documentation in the [Ad-Hoc Network Configuration using raspbian with BATMAN-ADV](Raspbian_adhoc\Adhoc_batman_raspbian.md) section.

## Access Point Configuration with BATMAN-ADV

Raspberry Pi 4b is configured as an Access Point (AP) to provide wireless connectivity, and BATMAN-ADV is enabled to support mesh networking capabilities. For detailed steps including setting up the AP and enabling BATMAN-ADV on the device follow the documentation in the [Access Point Setup with BATMAN-ADV](AccessPoint/AccessPoint.md) section.

