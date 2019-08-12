Arcturus iMX6 Programming Station
=================================

This tutorial describes how to use the predefined Buildroot
configuration for the Arcturus iMX6 Programming Station(iMX6-PS).

Building
--------

NOTE:
First you have to obtain Arcturus-imx6ps.patch, disk_sd.layout and srk.keys
files from Arcturus Networks Inc.

Return to the top directory <buildrootdir> and execute the following commands.

  patch -p1 < <patch_location>/Arcturus-imx6ps.patch
  make arcturus_imx6ps_defconfig
  make

Create a bootable SD card
=========================

To determine the device associated to the SD card have a look in the
/proc/partitions file:

  cat /proc/partitions

Buildroot prepares a bootable "sdcard.img" image in the output/images/
directory, ready to be dumped on a SD card. Launch the following
command as root:

As an example: MMC/SD card device is "/dev/sde" and mount point is "/mnt".

  sync
  dd if=output/images/sdcard.img of=/dev/sde
  sync
  sfdisk -f /dev/sde < disk_sd.layout
  sync
  mkfs.ext4 -t ext4 -L Images /dev/sde3
  sync
  mount -t ext4 /dev/sde3 /mnt
  
Now  copy images into /mnt.

  cp part0-00000t.bin /mnt/
  cp part1-00000t.bin /mnt/
  cp part2-00000t.bin /mnt/
  cp partS-00000t.bin /mnt/
  cp partV-00000t.bin /mnt/
  cp build/PART0/u-boot.img /mnt/

  sync

  umount /mnt
  umount /mnt


*** WARNING! This will destroy all the card content. Use with care! ***


Boot the i.MX8MM EVK board
==========================

To boot your newly created system.
- insert the SD card in the SD slot of the board;
- Configure the switches to boot from SD Card
- put a micro USB cable into the Debug USB Port and connect using a terminal
  emulator at 115200 bps, 8n1;
- power on the board.
- follow menu to programm your eMMC.

ONLY AT FIRST TIME RUN:

 Press ECS when u-boot runs and set SRK0, SRK1, SRK2, SRK3, SRK4, SRK5,
SRK6 and SRK7 environment variables from srk.keys file.
Run `saveenv` and reset.


Good Luck !

