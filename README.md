# PlayStation 5 with piSCSI OTG

I’m a moderate player on PlayStation 5. I love to play with my wife together some games if the game allows.

Some time ago we run out of internal disk space. An option would have been to add M2 storage or an external USB drive. But this is too risky, because of bitrot issues and so forth. In the cellar is a big Synology server with RAID6 activated and plenty of storage.

Wouldn’t it be possible to use that storage for PlayStations external storage? I had a look on remote USB (but Synology doesn’t support it, other brands does), some network dongles or homemade Pi devices.

I found the following blog: https://matt.olan.me/post/making-a-piscsi-usb-drive-part-2/

This would be the perfect solution. I ordered a Rock Pi 4c+ which was available in my country. But whatever OS I tried, something was always missing:
- Armbian is the most active OS. But there is an issue with UDC not showing up. Somewhen in the past it worked, but then a bug got introduced and it is still there.
- DietOS: Somehow it works with Armbian and in the Forum is a lot of noise because of the broken pieces
- Debian CLI/Desktop: No g_mass_storage
- OpenWRT: I forgot what didn’t work

A half year later I wanted to try it again and ordered the Rock Pi 4b, like the one mentioned in the Blog.

I experienced the same result. I thought maybe the manual trigger to set the Device to OTG would be of help.

After researching a lot of things the final suggestion was to create my own kernel. Something I haven’t done yet. I have a lot of experiences with VMs, LXCs and Dockers. But not with building my own kernel.

So here is the step-by-step instructions how to get it running:

## Install OS 

https://radxa.com/products/rock4/4bp#downloads. This forwards to https://github.com/radxa-build/rock-pi-4b-plus/releases 

The releases are quite old. But don’t worry. Just download it, install it on a SD with etcher and update it through apt update/upgrade.

## Compile Kernel
(I’m not quite sure, if I still need it, as I don’t rely anymore on g_mass_storage) 

https://radxa-repo.github.io/bsp/getting_started.html 

I created a new VM with a plain Debian and installed the prerequisite as described in the webpage. In linux/rockchip/kconfig.conf I added CONFIG_USB_MASS_STORAGE=y

Then I created a new kernel with `./bsp rock-pi-4b-plus`.

After the kernel compilation I got a lot of deb packages.

## Replace Kernel

Out of these packages I needed only 2:
- linux-headers-5.10.110-1…
- linux-image-5.10.110-1…

I copied them over the Rock Pi with `scp` and installed them with `dpkg -i {package}`.

Through installation I got a version 8 and through the apt update a version 39 of the kernel. But bsp generated a version 1. It won’t be used. And I don’t have the deep knowledge about defining my new kernel as the one to use.

Therefore, I removed every other kernel currently installed:
- `apt list --installed | grep linux`
- `apt purge {not wished headers and image}`

After a reboot everything was running smoothly and I could use g_mass_storage.

## piSCSI Setup

Through my testing I figured out that my PS5 wants to have 2 devices:
- 1 for storage of games
- 1 as backup location

How to accomplish that with my Rock Pi 5? I followed the wonderful guide of https://github.com/thagrol/Guides/ mass-storage-gadget.pdf.

On my Synology I created 2 LUNs. One for storage and one for backup.

On the RockPi I installed the following package:
```
apt update
apt install open-iscsi
```

I created the following script `piscsi.sh` and 2 selector scripts to switch between storage and backup. Both are not possible to be used at the same time. There is another script I found https://gist.github.com/eballetbo/e55ac48a620476a3ec1f860947194c55 but this doesn't work, as it doesn't publish as an USB storage.

In crontab -e I added the following command `@reboot bash -x /root/piscsi.sh >> /root/piscsi.log 2>&1`.
