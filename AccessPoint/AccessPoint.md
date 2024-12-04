## Access Point Setup with BATMAN-ADV
## Introduction
This guide provides a step-by-step process for setting up a BATMAN-ADV network using OpenWRT, where one Raspberry Pi is configured as an Access Point (AP) and the other as a client.

## Prerequisites
Hardware: Two Raspberry Pi 4b units.
Software: OpenWRT(21.02) installed on both Raspberry Pis.

## Configuration for AP (Raspberry Pi)
### Wireless Setup
1. Edit the wireless configuration file:
 ```bash
    vi /etc/config/wireless
  ```
2. Add the following to configure the AP mode:
 ```bash
    config wifi-device 'radio0'
        option type 'mac80211'
        option channel '6'
        option hwmode '11g'
        option path 'platform/soc/fe300000.mmcnr/mmc_host/mmc1/mmc1:0001/mmc1:0001:1'
        option htmode 'HT20'
        option disabled '0'

    config wifi-iface 'default_radio0'
        option device 'radio0'
        option mode 'ap'
        option ssid 'AP'
        option encryption 'none'
        option network 'lan'
  ```
3. Apply changes:
    ```bash
    wifi
    ```


Or to configure the Ad-Hoc network using the LuCI web interface:

1. Open the LuCI web interface in a web browser.
2. Navigate to Network > Wireless.
3. Click on the Edit button next to the wireless network.
4. Change the mode to AccessPoint.
5. Set the SSID to `AP`.
6. Set the encryption to None.
7. (Optional) Set the channel and other settings as required.
8. Click on Save & Apply.

## Setting up BATMAN-ADV

Batman-adv is a mesh protocol for a Layer 2 networking (like Ethernet frames) running in the kernel.
To setup BATMAN-ADV, SSH into the Raspberry Pi and run the following commands:

```bash
opkg update
opkg install batctl-full
```

Make sure your raspberry pi has internet access to install the package. This can be done by setting up the Raspberry Pi as a WiFi client (Station) or by connecting it to the internet using an Ethernet cable with DNS.

To check if the BATMAN-ADV module is loaded, run the following command:

```bash
batctl -v
```

If the command returns the version of batctl, then the module is loaded.

## Testing of a sample batman-adv network

To check how the batman-adv routing protocol works, we can create a simple network with [namespaces](/AdHoc/namespaces.md).

## Setting a Raspberry Pi with BATMAN-ADV as a Server(Gateway)

This part will set up the Raspberry Pi as a server in the BATMAN-ADV network. The server acts as a gateway to the internet via the Ethernet interface.

1. Set up a batman interface on the Raspberry Pi. Here `phy0-ap0` is the name of the wireless interface. It could be different on other Raspberry Pis.

```bash
ifconfig phy0-ap0 down
batctl if add phy0-ap0
ifconfig phy0-ap0 up
ifconfig bat0 mtu 1468
batctl gw_mode server
```

2. Allow ip forwarding on the Raspberry Pi.

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```
or

```bash
sysctl -w net.ipv4.ip_forward=1
```

3. Connecting the batman-adv network to the internet via the Ethernet interface `eth0`.

```bash
nft add table ip nat
nft add chain ip nat POSTROUTING { type nat hook postrouting priority 100 \; }
nft add rule ip nat POSTROUTING oifname "eth0" masquerade

nft add table ip filter
nft add chain ip filter forward { type filter hook forward priority 0 \; }
nft add rule ip filter forward iifname "eth0" oifname "bat0" ct state related,established accept
nft add rule ip filter forward iifname "bat0" oifname "eth0" accept
```

if iptables is installed, the following commands can be used:

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i bat0 -o eth0 -j ACCEPT
```


4. Set up the IP address of the batman-adv interface.

```bash
ifconfig wlan0 up
ifconfig bat0 up
ifconfig bat0 192.168.1.1/24
``` 

5. Set up the DHCP server on the Raspberry Pi to assign IP addresses to the clients.

Install the `dnsmasq` package on the Raspberry Pi.
```bash
opkg update
opkg install dnsmasq
```

Start the `dnsmasq` server with the following command:
```bash
dnsmasq --no-daemon --interface=bat0 --dhcp-range=192.168.1.2,192.168.1.100,12h &
```
The above command will start the `dnsmasq` server in the background and assign IP addresses in the range `192.168.1.2` to `192.168.1.100`.

## Script to automate the setup

To automate the setup, create a script with the following content:

```bash
ifconfig phy0-ap0 down
batctl if add phy0-ap0
ifconfig phy0-ap0 up
ifconfig bat0 mtu 1468
sudo batctl gw_mode server
echo 1 > /proc/sys/net/ipv4/ip_forward
nft add table ip nat
nft add chain ip nat POSTROUTING { type nat hook postrouting priority 100 \; }
nft add rule ip nat POSTROUTING oifname "eth0" masquerade

nft add table ip filter
nft add chain ip filter forward { type filter hook forward priority 0 \; }
nft add rule ip filter forward iifname "eth0" oifname "bat0" ct state related,established accept
nft add rule ip filter forward iifname "bat0" oifname "eth0" accept
ifconfig wlan0 up
ifconfig bat0 up
ifconfig bat0 192.168.1.1/24
dnsmasq --no-daemon --interface=bat0 --dhcp-range=192.168.1.2,192.168.1.100,12h &
```

Save the script as `batman-adv-server.sh` and make it executable by running the following command:

```bash
chmod +x batman-adv-server.sh
```

Run the script to set up the Raspberry Pi as a server in the BATMAN-ADV network.

```bash
./batman-adv-server.sh
```

To make the script run on boot, add the following line to the `/etc/rc.local` file:

```bash
batman-adv-server.sh
```

## Setting up the other Raspberry Pi as a Client

This part will set up the Raspberry Pi as a client in the BATMAN-ADV network. The client connects to the server via the wireless interface same as the server.

1. Set up a batman interface on the Raspberry Pi. Here `phy0-ap0` is the name of the wireless interface. It could be different on other Raspberry Pis as mentioned above.

```bash
ifconfig phy0-ap0 down
batctl if add phy0-ap0
ifconfig phy0-ap0 up
ifconfig bat0 mtu 1468
batctl gw_mode client
ifconfig wlan0 up
ifconfig bat0 up
```

2. Save the script as `batman-adv-client.sh` and make it executable by running the following command:

```bash
chmod +x batman-adv-client.sh
```

3. Run the script to set up the Raspberry Pi as a client in the BATMAN-ADV network.

```bash
./batman-adv-client.sh
```

To make the script run on boot, add the following line to the `/etc/rc.local` file:

```bash
batman-adv-client.sh
```

## Output

Reboot both Raspberry Pis and check the connectivity between the two Raspberry Pis. The client Raspberry Pi should be able to ping the server Raspberry Pi.


