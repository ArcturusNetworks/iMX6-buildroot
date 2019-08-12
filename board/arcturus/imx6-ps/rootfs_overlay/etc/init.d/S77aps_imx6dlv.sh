#!/bin/bash
#
# Arcturus Networks iMX6 Programming Station script
#
# Copyright (c) 2019, Arcturus Networks Inc.
#		by Oleksandr G Zhadan
#

show_header()
{ 
	printf "\nArcturus Networks iMX6 Programming Station\n"
	printf "*********************************************\n"
	printf "  HW_ID=${HW_ID}\n"
	printf "  eMMC: dev=${img_dev} size=${emmc_size}GB\n"
	printf "  mode=${aps_mode} step=${aps_step} "
	
	if [ -f "${DATA_DIR}/${HW_ID}.partitioned" ]; then
		printf "P"
	fi
	if [ -f "${DATA_DIR}/${HW_ID}.formatted" ]; then
		printf "F"
	fi
	if [ -f "${DATA_DIR}/${HW_ID}.programmed" ]; then
		printf "X"
	fi
	printf "\n"
}

show_menu()
{
	cd ${IMG_DIR}
	printf "*********************************************\n"
	printf "\n Operations\n";
	printf "   1) Partitioning\n"
	printf "   2) Format\n"
	printf "   3) Program Images\n"
	printf "   4) Program u-boot\n"
	printf "   5) Auto\n"
	printf "\n Settings\n";
	printf "   6) eMMC size\n"
	printf "   7) Print OTP keys\n"
	printf "   8) Set OTP keys from u-boot ENV\n"
	printf "\n"
	printf "   Q) Quit\n"
	printf "   R) Reboot\n"
	printf "*********************************************\n"
	printf "\n"
	printf "Please enter a menu option and enter  "

	if [ ${aps_mode} = m ]; then
		read opt
	else
		printf "5"
		sleep 3
		f_auto
	fi
}

do_mount()
{
	##### Create mountpoints
	mkdir -p ${MNT_BASE}
	mkdir -p ${MNT_BASE}/p1
	mkdir -p ${MNT_BASE}/p2
	mkdir -p ${MNT_BASE}/p3
	mkdir -p ${MNT_BASE}/p4
	mkdir -p ${MNT_BASE}/p5
	mkdir -p ${MNT_BASE}/p6
	mkdir -p ${MNT_BASE}/p7
	mkdir -p ${MNT_BASE}/p8
	mkdir -p ${MNT_BASE}/p9
	mkdir -p ${MNT_BASE}/p10
	sync

	##### Mount partitions
	mount -t ext4 ${IMG_DEV}p1 ${MNT_BASE}/p1
	mount -t ext4 ${IMG_DEV}p2 ${MNT_BASE}/p2
	mount -t ext4 ${IMG_DEV}p3 ${MNT_BASE}/p3
	mount -t ext4 ${IMG_DEV}p5 ${MNT_BASE}/p5
	mount -t ext4 ${IMG_DEV}p6 ${MNT_BASE}/p6
	mount -t ext4 ${IMG_DEV}p7 ${MNT_BASE}/p7
	mount -t ext4 ${IMG_DEV}p8 ${MNT_BASE}/p8
	mount -t ext4 ${IMG_DEV}p9 ${MNT_BASE}/p9
	mount -t ext4 ${IMG_DEV}p10 ${MNT_BASE}/p10
	sync

	##### Create /encrypted mountpoints
	mkdir -p ${MNT_BASE}/p3/encrypted
	mkdir -p ${MNT_BASE}/p5/encrypted
	mkdir -p ${MNT_BASE}/p6/encrypted
	mkdir -p ${MNT_BASE}/p7/encrypted
	mkdir -p ${MNT_BASE}/p8/encrypted
	mkdir -p ${MNT_BASE}/p9/encrypted
	mkdir -p ${MNT_BASE}/p10/encrypted
	sync
}

do_umount()
{
	##### uMount partitions
	umount ${MNT_BASE}/p1
	umount ${MNT_BASE}/p1
	umount ${MNT_BASE}/p2
	umount ${MNT_BASE}/p2
	umount ${MNT_BASE}/p3
	umount ${MNT_BASE}/p3
	umount ${MNT_BASE}/p4
	umount ${MNT_BASE}/p4
	umount ${MNT_BASE}/p5
	umount ${MNT_BASE}/p5
	umount ${MNT_BASE}/p6
	umount ${MNT_BASE}/p6
	umount ${MNT_BASE}/p7
	umount ${MNT_BASE}/p7
	umount ${MNT_BASE}/p8
	umount ${MNT_BASE}/p8
	umount ${MNT_BASE}/p9
	umount ${MNT_BASE}/p9
	umount ${MNT_BASE}/p10
	umount ${MNT_BASE}/p10
	sync
}

get_keys()
{
	read o0 < /sys/fsl_otp/HW_OCOTP_SRK0
	read o1 < /sys/fsl_otp/HW_OCOTP_SRK1
	read o2 < /sys/fsl_otp/HW_OCOTP_SRK2
	read o3 < /sys/fsl_otp/HW_OCOTP_SRK3
	read o4 < /sys/fsl_otp/HW_OCOTP_SRK4
	read o5 < /sys/fsl_otp/HW_OCOTP_SRK5
	read o6 < /sys/fsl_otp/HW_OCOTP_SRK6
	read o7 < /sys/fsl_otp/HW_OCOTP_SRK7
	s="0x"${o1}${o2}${o3}${o4}
}

set_policy()
{
	if [ ! -f "/sbin/e4crypt" ]; then
		printf "ERROR: No e4crypt found\n"
	else
		p=${HW_ID}

		k3=`/sbin/e4crypt add_key -S $s -P $p -s p3`
		/sbin/e4crypt set_policy ${k3} ${MNT_BASE}/p3/encrypted

		k5=`/sbin/e4crypt add_key -S $s -P $p -s p5`
		/sbin/e4crypt set_policy ${k5} ${MNT_BASE}/p5/encrypted

		k6=`/sbin/e4crypt add_key -S $s -P $p -s p6`
		/sbin/e4crypt set_policy ${k6} ${MNT_BASE}/p6/encrypted

		k7=`/sbin/e4crypt add_key -S $s -P $p -s p7`
		/sbin/e4crypt set_policy ${k7} ${MNT_BASE}/p7/encrypted

		k8=`/sbin/e4crypt add_key -S $s -P $p -s p8`
		/sbin/e4crypt set_policy ${k8} ${MNT_BASE}/p8/encrypted

		k9=`/sbin/e4crypt add_key -S $s -P $p -s p9`
		/sbin/e4crypt set_policy ${k9} ${MNT_BASE}/p9/encrypted

		k10=`/sbin/e4crypt add_key -S $s -P $p -s p10`
		/sbin/e4crypt set_policy ${k10} ${MNT_BASE}/p10/encrypted

		sync
		echo 1 > /proc/sys/vm/drop_caches > /dev/null
		echo 2 > /proc/sys/vm/drop_caches > /dev/null
		echo 3 > /proc/sys/vm/drop_caches > /dev/null
		sync
	fi
}

do_extract()
{
	echo "part0-00000t.bin into <${img_dev}/p1>"
	cd ${MNT_BASE}/p1
	tar -xmf ${IMG_DIR}/part0-00000t.bin
	sync

	echo "partS-00000t.bin into <${img_dev}/p2>"
	cd ${MNT_BASE}/p2
	tar -xmf ${IMG_DIR}/partS-00000t.bin
	sync

	echo "part1-00000t.bin into <${img_dev}/p6>"
	cd ${MNT_BASE}/p6/encrypted
	tar -xmf ${IMG_DIR}/part1-00000t.bin
	sync

	echo "part2-00000t.bin into <${img_dev}/p5>"
	cd ${MNT_BASE}/p5/encrypted
	tar -xmf ${IMG_DIR}/part2-00000t.bin
	sync

	echo "partV-00000t.bin into <${img_dev}/p7>"
	cd ${MNT_BASE}/p7/encrypted
	tar -xmf ${IMG_DIR}/partV-00000t.bin
	sync
}

do_program()
{
	do_mount
	get_keys
	set_policy
	do_extract
	touch ${DATA_DIR}/${HW_ID}.programmed
	sync
	do_umount
}

set_otp_keys()
{
	if [ ! -f "/usr/sbin/fw_printenv" ]; then
		printf "ERROR: No fw_printenv found\n"
	else
		printf "WARNING: This is One Time Programmable operation !\n"
		printf "WARNING: Are you sure ? (Y/N)\n"
		read otp_step

		if [ 0$otp_step = 0 ]; then
			otp_step=n
		fi

		if [ ${otp_step} = Y ]; then
			a0=`fw_printenv -n SRK0`
			a1=`fw_printenv -n SRK1`
			a2=`fw_printenv -n SRK2`
			a3=`fw_printenv -n SRK3`
			a4=`fw_printenv -n SRK4`
			a5=`fw_printenv -n SRK5`
			a6=`fw_printenv -n SRK6`
			a7=`fw_printenv -n SRK7`
			echo -n ${a0} > /sys/fsl_otp/HW_OCOTP_SRK0
			echo -n ${a1} > /sys/fsl_otp/HW_OCOTP_SRK1
			echo -n ${a2} > /sys/fsl_otp/HW_OCOTP_SRK2
			echo -n ${a3} > /sys/fsl_otp/HW_OCOTP_SRK3
			echo -n ${a4} > /sys/fsl_otp/HW_OCOTP_SRK4
			echo -n ${a5} > /sys/fsl_otp/HW_OCOTP_SRK5
			echo -n ${a6} > /sys/fsl_otp/HW_OCOTP_SRK6
			echo -n ${a7} > /sys/fsl_otp/HW_OCOTP_SRK7
		fi
	fi
}

print_otp_keys()
{
		printf "\nKeys from u-boot ENV:\n"
		fw_printenv SRK0
		fw_printenv SRK1
		fw_printenv SRK2
		fw_printenv SRK3
		fw_printenv SRK4
		fw_printenv SRK5
		fw_printenv SRK6
		fw_printenv SRK7
		printf "\nKeys from /sys/fsl_otp:\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK0; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK1; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK2; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK3; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK4; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK5; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK6; printf "\n"
		printf "0x"; cat /sys/fsl_otp/HW_OCOTP_SRK7; printf "\n"
}

do_format()
{
	if [ ! -f "/sbin/mkfs.ext4" ]; then
		printf "ERROR: No mkfs.ext4 found\n"
	else
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L OS ${IMG_DEV}p1
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L ROOTFS_BASE ${IMG_DEV}p2
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L OPT ${IMG_DEV}p3
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L WEB ${IMG_DEV}p5
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L ROOTFS ${IMG_DEV}p6
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L USER1 ${IMG_DEV}p7
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L USER2 ${IMG_DEV}p8
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L USER3 ${IMG_DEV}p9
		mkfs.ext4 -O encrypt -t ext4 -b 4096 -F -L USER4 ${IMG_DEV}p10
		touch ${DATA_DIR}/${HW_ID}.formatted
		sync
	fi
}

do_part()
{
	if [ ! -f "/sbin/sfdisk" ]; then
		printf "ERROR: No sfdisk found\n"
	else
		/sbin/sfdisk ${img_dev} < ${APS_DIR}/${disk_layout}
		touch ${DATA_DIR}/${HW_ID}.partitioned
		sync
	fi
}

f_auto()
{
	if [ ${aps_step} = 1 ]; then
		aps_step=2
		echo ${aps_step} > ${IMG_DIR}/.aps_step
		do_part
		printf "\nWait for reboot.\n"
		sleep 3
		/sbin/reboot -f
		sleep 10
	fi
	if [ ${aps_step} = 2 ]; then
		do_format
		do_program
	fi

	dd if=${IMG_DIR}/u-boot.img of=${IMG_DEV} bs=512 seek=2
	sync

	aps_step=0
	echo ${aps_step} > ${IMG_DIR}/.aps_step
	aps_mode=m
	echo ${aps_mode} > ${IMG_DIR}/.aps_mode
	sync
}

f_size()
{
	printf "eMMC size...... ${emmc_size} GB\n";
        printf "Enter new size. "

	read emmc_size

	if [ 0$emmc_size = 0 ]; then
		emmc_size=4
	fi

	if [ $emmc_size = 8 ]; then
		disk_layout=`echo disk_8GB.layout`
	else
		emmc_size=4
		disk_layout=`echo disk_4GB.layout`
	fi

	if [ ! -f ${APS_DIR}/"${disk_layout}" ]; then
		printf "ERROR: No ${APS_DIR}/${disk_layout} found"
	else
		echo ${emmc_size} > ${IMG_DIR}/.emmc_size
	fi
}


f_part()
{
	aps_mode=m
	echo ${aps_mode} > ${IMG_DIR}/.aps_mode
	do_part
	sync
	printf "\nBoard has to be reset for next operations !!!\n"
}

f_format()
{
	aps_mode=m
	echo ${aps_mode} > ${IMG_DIR}/.aps_mode
	do_format
	sync
}

f_program()
{
	aps_mode=m
	echo ${aps_mode} > ${IMG_DIR}/.aps_mode
	do_program
	sync
}

f_program_uboot()
{
	aps_mode=m
	echo ${aps_mode} > ${IMG_DIR}/.aps_mode
	echo "Program Bootloader"
	dd if=${IMG_DIR}/u-boot.img of=${IMG_DEV} bs=512 seek=2
	sync
}

manage_cmd()
{
	if [ $opt = '' ]; then
		exit;
	else
		case $opt in

		1) f_part;
		;;

		2) f_format;
        	;;

		3) f_program;
		;;

		4) f_program_uboot;
		;;

		5) 
		   aps_mode=a
		   echo ${aps_mode} > ${IMG_DIR}/.aps_mode
		   aps_step=1
		   echo ${aps_step} > ${IMG_DIR}/.aps_step
		   sync
		   f_auto;
		;;

		6) f_size
		;;

		7) print_otp_keys
		;;

		8) set_otp_keys
		;;

		q) exit;
		;;

		Q) exit;
		;;

		r) /sbin/reboot -f
		   sleep 10
		;;

		R) /sbin/reboot -f
		   sleep 10
		;;

		*) clear;
		   show_header;
		;;

		esac
	fi
}

aps_init()
{
	if [ -f "${IMG_DIR}/.aps_mode" ]; then
		read aps_mode < ${IMG_DIR}/.aps_mode
	else
		aps_mode=${APS_MODE}
		echo ${aps_mode} > ${IMG_DIR}/.aps_mode
	fi

	if [ -f "${IMG_DIR}/.img_dev" ]; then
		read img_dev < ${IMG_DIR}/.img_dev
	else
		img_dev=${IMG_DEV}
		echo ${img_dev} > ${IMG_DIR}/.img_dev
	fi

	if [ -f "${IMG_DIR}/.emmc_size" ]; then
		read emmc_size < ${IMG_DIR}/.emmc_size
	else
		emmc_size=${EMMC_SIZE};
		echo ${emmc_size} > ${IMG_DIR}/.emmc_size
	fi

	if [ ${emmc_size} = 8 ]; then
		disk_layout=`echo disk_8GB.layout`
	else
		disk_layout=`echo disk_4GB.layout`
	fi

	if [ ! -f "${APS_DIR}/${disk_layout}" ]; then
		printf "ERROR: No ${APS_DIR}${disk_layout} found"
	fi

	if [ -f "${IMG_DIR}/.aps_step" ]; then
		read aps_step < ${IMG_DIR}/.aps_step
	else
		aps_step=0;
		echo ${aps_step} > ${IMG_DIR}/.aps_step
	fi
	
	mkdir -p ${DATA_DIR}

}

###### Init & deafaults

CDIR=`pwd`
#IMG_DIR=${CDIR}
IMG_DIR=/Images
IMG_DEV=/dev/mmcblk2
EMMC_SIZE=4

APS_DIR=/APS
APS_MODE=m

DATA_DIR=${IMG_DIR}/database
MNT_BASE=${APS_DIR}/parts

IMG_PART=`echo disk_4GB.layout`
read o9 < /sys/fsl_otp/HW_OCOTP_CFG0
read oA < /sys/fsl_otp/HW_OCOTP_MAC0
HW_ID=${o9}${oA}

mkdir -p /Images
/bin/umount /Images > /dev/null
/bin/umount /Images > /dev/null
/bin/mount -t ext4 /dev/mmcblk0p3 /Images

clear
aps_init
show_header

###### Main loop
while true
do
	show_menu
	manage_cmd
done

exit 0
