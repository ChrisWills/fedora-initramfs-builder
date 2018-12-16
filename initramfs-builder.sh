#!/bin/bash

source private.sh

SYSROOT="/root/sysroot-tmp"

echo "==> Initializing root filesystem"

mkdir ${SYSROOT} 

for dir in dev etc home mnt proc root sys tmp ; do 
	mkdir -p ${SYSROOT}/${dir}
done

echo "==> Creating character devices"

mknod ${SYSROOT}/dev/console c 5 1
mknod ${SYSROOT}/dev/kmsg c 1 11
mknod ${SYSROOT}/dev/null c 1 3
mknod ${SYSROOT}/dev/random c 1 8
mknod ${SYSROOT}/dev/urandom c 1 9

echo "==> Installing pacakges"

rpmdb --initdb --root ${SYSROOT}

yum -y --installroot=${SYSROOT} --releasever=29 install fedora-release-29-6 systemd bash binutils kernel-4.19.8-300.fc29 dnf iproute NetworkManager iputils kernel-devel http://download.zfsonlinux.org/fedora/zfs-release.fc29.noarch.rpm openssh-server

# TODO: setup authorized keys for root

# TODO: copy over zfs stuff as binaries so we don't waste time and space compiling during boot
yum -y --installroot=${SYSROOT} --releasever=29 install zfs

ln -s /usr/lib/systemd/systemd ${SYSROOT}/init

echo "==> Setting root password"
set_root_pass ${SYSROOT}/etc/shadow

echo "==> Cleaning image"
rm -rf  var/cache/dnf/*

echo "==> Creating archive"
cd ${SYSROOT}
find . | cpio -ov --format=newc | gzip -9 > ../initramfs.img

echo "==> Cleaning up"
cd
#rm -rf ${SYSROOT}
