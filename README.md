# PlayStation 5 with piSCSI and USB3 OTG

I’m a moderate player on PlayStation 5. I love to play with my wife together some games if the game allows.

Some time ago we run out of internal disk space. An option would have been to add M2 storage or an external USB drive. But this is too risky, because of bitrot issues and so forth. In the cellar is a big Synology server with RAID6 activated and plenty of storage.

Wouldn’t it be possible to use that storage for PlayStations external storage? I had a look on remote USB (but Synology doesn’t support it, other brands do), some network dongles or homemade Pi devices.

I found the following blog: https://matt.olan.me/post/making-a-piscsi-usb-drive-part-2/

This would be the perfect solution. I ordered a Rock Pi 4c+ which was available in my country. But whatever OS I tried, something was always missing. The solution described relys on g_mass_storage.
- Armbian is the most active OS. But there is an issue with UDC not showing up. Somewhen in the past it worked, but then a bug got introduced and it is still there.
- DietOS: Somehow it works with Armbian and in the forum is a lot of noise because of the broken pieces
- Debian CLI/Desktop: No g_mass_storage
- OpenWRT: I forgot what didn’t work

A half year later I wanted to try it again and ordered the Rock Pi 4b, like the one mentioned in the Blog.

I experienced the same result. I thought maybe the manual trigger to set the Device to OTG would be of help.

After researching a lot of things the final suggestion was to create my own kernel to have the USB gadget g_mass_storage available. Something I haven’t done yet. I have a lot of experiences with VMs, LXCs and Dockers. But not with building my own kernel. So I went this path and worked well. But I found another issue. Through my testing I figured out that my PS5 wants to have 2 devices:
- 1 for storage of games
- 1 as backup location

How to accomplish that with my Rock Pi and g_mass_storage? I found and followed the wonderful guide of https://github.com/thagrol/Guides/ mass-storage-gadget.pdf.

So in the end the solution is very easy. No need to patch kernels.

## Install OS 

https://radxa.com/products/rock4/4bp#downloads. This forwards to https://github.com/radxa-build/rock-pi-4b-plus/releases

The releases are quite old. But don’t worry. Just download it, install it on a SD with etcher and update it through apt update/upgrade.

## Synology LUN

On my Synology I created 2 LUNs. One for storage and one for backup.

## piSCSI Setup

On the RockPi I installed the following packages:
```
apt install open-iscsi
apt install cron
```

I created the following script `piscsi.sh` and 2 selector scripts to switch between storage and backup. Both are not possible to be used at the same time. There is a script I found https://gist.github.com/eballetbo/e55ac48a620476a3ec1f860947194c55. But this doesn't work, as it doesn't publish as an USB storage.

In crontab -e I added the following command `@reboot bash -x /root/piscsi.sh >> /root/piscsi.log 2>&1`.

Maybe you might need to set in `rsetup` the OTG mode to 'Peripheral'. In the end when I recreated everything from scratch it wasn't needed.

Happy using!
