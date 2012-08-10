#!/bin/sh
#
# Author: Ricky Ng-Adam <rngadam@lophilo.com>
# Lophilo Copyright 2012
#
# From a host system, create SD card from scratch
#
# We clone the FAT32 partition #1 because mkdosfs results in
# an unbootable filesystem
#
# Assumptions:
# - Executed on Ubuntu 12.04 LTS
# - checked out Lophilo/debian.git -> ~/lophilo/debian
# - checked out Lophilo/mkcard.git -> ~/lophilo/mkcard
# - make as been run and ~/lophilo/obj/wheezy generated
# - target MicroSD inserted as /dev/sdb
# - copy of a valid MicroSD card partition #1 in ~/lophilo/mkcard
#
sudo ~/lophilo/mkcard/mkcard.py \
	--dev /dev/sdb \
	--os ~/lophilo/obj/wheezy/ \
	--clone_boot_source ~/lophilo/mkcard/sdb1.img \
	--force_partition \
	--mount \
	--create_partition \
	--clone_boot \
	--format_os \
	--format_swap \
	--sync_os \
	--sync_firmware
