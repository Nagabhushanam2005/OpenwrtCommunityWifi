# Firmware and flashing into Raspberry Pi 4b

## Building the firmware

The Firmware Selector can be found here:
https://firmware-selector.openwrt.org/

- Open the link in your browser
- Select the model
- Select the version of OpenWrt
Click on “Customize installed packages and/or first boot script”

In the upper text box, labelled “Installed Packages”, you will see a list of packages.

Add the following text, the upper text box will now look like this:
```
base-files bcm27xx-gpu-fw busybox ca-bundle dnsmasq dropbear e2fsprogs firewall4 fstools kmod-fs-vfat kmod-nft-offload kmod-nls-cp437 kmod-nls-iso8859-1 kmod-sound-arm-bcm2835 kmod-sound-core kmod-usb-hid libc libgcc libustream-mbedtls logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg partx-utils ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uci uclient-fetch urandom-seed cypress-firmware-43455-sdio brcmfmac-nvram-43455-sdio kmod-brcmfmac wpad-basic-mbedtls kmod-usb-net-lan78xx kmod-r8169 iwinfo luci
nano ip-full veth 
```
Now, in the lower text box, add the following:

```
rootpassword="myrootpassword"
/bin/passwd root << EOF
$rootpassword
$rootpassword
EOF
```
- Replace myrootpassword with a secret root password of your choice.


Finally, click “REQUEST BUILD” to build your customised firmware. 

Once the firmware build has completed, download it.


## Flashing the firmware into Raspberry Pi 4b

- Download the firmware image from the link provided after the build is complete.
- Extract the firmware image file from the downloaded archive.
- Insert the microSD card into your computer.
- Check for the device name of the microSD card by running the following command:
    ```bash
    lsblk
    ```
  The device name will be something like `/dev/sda` or `/dev/mmcblk0`. The output will look something like this:
    ```
    NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    loop0         7:0    0     4K  1 loop /snap/bare/5
    loop1         7:1    0 313.1M  1 loop /snap/code/171
    loop2         7:2    0 313.1M  1 loop /snap/code/172
    loop3         7:3    0  55.7M  1 loop /snap/core18/2829
    loop4         7:4    0  55.4M  1 loop /snap/core18/2846
    loop5         7:5    0  63.9M  1 loop /snap/core20/2318
    sda           8:0    1    29G  0 disk 
    └─sda1        8:1    1    29G  0 part 
    nvme0n1     259:0    0 465.8G  0 disk 
    ├─nvme0n1p1 259:1    0   100M  0 part /boot/efi
    ├─nvme0n1p2 259:2    0    16M  0 part 
    ├─nvme0n1p3 259:3    0 116.4G  0 part 
    ├─nvme0n1p4 259:4    0   707M  0 part 
    ├─nvme0n1p5 259:5    0 120.1G  0 part /var/snap/firefox/common/host-hunspell
    │                                     /
    └─nvme0n1p6 259:6    0 228.5G  0 part 
    ```
- Unmount the microSD card by running the following command:
  ```bash
    sudo umount /dev/sdX
  ```
    Replace `sdX` with the device name of the microSD card.
- Use the `dd` command to write the firmware image to the microSD card. 
  ```bash
    sudo dd if=firmware.img of=/dev/sdX bs=2M status=progress conv=fsync
  ```

  Replace `firmware.img` with the path to the firmware image file and `sdX` with the device name of the microSD card.