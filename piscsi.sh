#!/bin/bash
# Setup iSCSI devices
iscsiadm -m discovery -t st -p {IP}
iscsiadm -m node --targetname "{LUN storage}" --portal "{IP/Port}" --login
iscsiadm -m node --targetname "{LUN backup}" --portal "{IP/Port}" --login

sleep 2

modprobe libcomposite

sleep 2

# Setup piSCSI Storage
mkdir -p /sys/kernel/config/usb_gadget/piscsi-storage
cd /sys/kernel/config/usb_gadget/piscsi-storage

echo 0x1d6b > idVendor
echo 0x0104 > idProduct
echo 0x0100 > bcdDevice
echo 0x0200 > bcdUSB

mkdir -p strings/0x409
echo "1234567890"     > strings/0x409/serialnumber
echo "Synology"       > strings/0x409/manufacturer
echo "piSCSI-Storage" > strings/0x409/product

mkdir -p configs/c.1/strings/0x409
echo "Config 1: Mass Storage" > configs/c.1/strings/0x409/configuration
echo 250                      > configs/c.1/MaxPower

mkdir -p functions/mass_storage.usb0
echo 0        > functions/mass_storage.usb0/lun.0/cdrom
echo 0        > functions/mass_storage.usb0/lun.0/ro
# Lookup device with lsblk
echo /dev/sda > functions/mass_storage.usb0/lun.0/file

ln -s functions/mass_storage.usb0 configs/c.1/
# This is the trigger to activate it. But only one can run at a time.
#ls /sys/class/udc > UDC

# Setup piSCSI Backup
mkdir -p /sys/kernel/config/usb_gadget/piscsi-backup
cd /sys/kernel/config/usb_gadget/piscsi-backup

echo 0x1d6b > idVendor
echo 0x0104 > idProduct
echo 0x0100 > bcdDevice
echo 0x0200 > bcdUSB

mkdir -p strings/0x409
echo "ABCDEFGHIJK"   > strings/0x409/serialnumber
echo "Synology"      > strings/0x409/manufacturer
echo "piSCSI-Backup" > strings/0x409/product

mkdir -p configs/c.1/strings/0x409
echo "Config 1: Mass Storage" > configs/c.1/strings/0x409/configuration
echo 250                      > configs/c.1/MaxPower

mkdir -p functions/mass_storage.usb0
echo 0        > functions/mass_storage.usb0/lun.0/cdrom
echo 0        > functions/mass_storage.usb0/lun.0/ro
# Lookup device with lsblk
echo /dev/sdb > functions/mass_storage.usb0/lun.0/file

ln -s functions/mass_storage.usb0 configs/c.1/
# This is the trigger to activate it. But only one can run at a time.
ls /sys/class/udc > UDC
