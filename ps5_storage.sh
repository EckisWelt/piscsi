#!/bin/bash -ex
echo "" > /sys/kernel/config/usb_gadget/piscsi-backup/UDC
ls /sys/class/udc > /sys/kernel/config/usb_gadget/piscsi-storage/UDC
