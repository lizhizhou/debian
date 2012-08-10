TARGET_DIR=../obj/wheezy
HOSTNAME=lophilo
DEFAULT_SERIAL_CONSOLE=ttyS0 # as per tabbyrev2
DEFAULT_SERIAL_CONSOLE_MAJOR=4
DEFAULT_SERIAL_CONSOLE_MINOR=64
DEFAULT_SERIAL_CONSOLE_TARGET:=${TARGET_DIR}/dev/${DEFAULT_SERIAL_CONSOLE}
STAGE1_INDICATOR:=${TARGET_DIR}/debootstrap/debootstrap
APT_SOURCE:=ftp://ftp.cn.debian.org/debian

.PHONY: setup

all: setup
	echo "debootstrap to ${TARGET_DIR}"

#
# initial image creation from the host system
#

${TARGET_DIR}:
	mkdir -p ${TARGET_DIR}

/usr/bin/debootstrap:
	sudo apt-get install debootstrap

${TARGET_DIR}/debootstrap/debootstrap: ${TARGET_DIR} /usr/bin/debootstrap
	sudo debootstrap --arch=armel --foreign wheezy ${TARGET_DIR} ${APT_SOURCE}
	@echo "Modify /etc/exports to export ${TARGET_DIR} if you want to use NFSROOT"

#
# setup tasks
#

${TARGET_DIR}/firstboot.sh: firstboot.sh
	sudo cp firstboot.sh $@
	sudo chmod a+rx $@

${TARGET_DIR}/dpkg-get-selections: dpkg-get-selections
	sudo cp dpkg-get-selections $@

setup: ${TARGET_DIR}/etc/fstab ${TARGET_DIR}/etc/hostname ${TARGET_DIR}/etc/securetty ${TARGET_DIR}/etc/inittab ${TARGET_DIR}/firstboot.sh ${TARGET_DIR}/dpkg-get-selections
	@echo "Boot to init=/bin/sh using the real device"
	@echo "run /debootstrap/debootstrap --second-stage"
	@echo "Please set root password on target system"

${TARGET_DIR}/etc/fstab: ${STAGE1_INDICATOR}
	@echo "Setting up /proc for $@"
	sudo sh -c "echo 'proc /proc proc none 0 0' >> $@"

${TARGET_DIR}/etc/hostname: ${TARGET_DIR}/bin/hostname ${STAGE1_INDICATOR}
	sudo sh -c "echo ${HOSTNAME} > $@"
	sudo mkdir -p ${TARGET_DIR}/usr/share/man/man1/

${TARGET_DIR}/dev/console: ${STAGE1_INDICATOR}
	sudo mknod $@ c 5 1

${TARGET_DIR}/etc/securetty: ${DEFAULT_SERIAL_CONSOLE_TARGET} ${STAGE1_INDICATOR}
	sudo sh -c "echo ${DEFAULT_SERIAL_CONSOLE} >> ${TARGET_DIR}/etc/securetty"

${TARGET_DIR}/etc/inittab: ${DEFAULT_SERIAL_CONSOLE_TARGET} ${STAGE1_INDICATOR}
	sudo sh -c "echo 'T0:2345:respawn:/sbin/getty -L -a root ${DEFAULT_SERIAL_CONSOLE} 115200 linux' >> $@"

${TARGET_DIR}/etc/apt/sources.list: ${STAGE1_INDICATOR}
	sudo cp sources.list ${TARGET_DIR}/etc/apt

${TARGET_DIR}/etc/rc.local: ${STAGE1_INDICATOR}
	sudo sh -c "echo ntpdate 2.asia.pool.ntp.org >> $@"

#
# sub-targets
#
${DEFAULT_SERIAL_CONSOLE_TARGET}: 
	sudo mknod ${TARGET_DIR}/dev/${DEFAULT_SERIAL_CONSOLE} c ${DEFAULT_SERIAL_CONSOLE_MAJOR} ${DEFAULT_SERIAL_CONSOLE_MINOR}
