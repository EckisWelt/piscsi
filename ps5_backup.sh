#!/bin/bash
echo "" > /sys/kernel/config/usb_gadget/piscsi-storage/UDC
ls /sys/class/udc > /sys/kernel/config/usb_gadget/piscsi-backup/UDC
