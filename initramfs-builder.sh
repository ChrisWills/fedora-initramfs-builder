#!/bin/bash

source private.sh

SYSROOT="${HOME}/sysroot-tmp"

echo "==> Initializing root filesystem"

sudo mkdir ${SYSROOT} 

for dir in dev etc home mnt proc root sys tmp ; do 
	sudo mkdir -p ${SYSROOT}/${dir}
done

echo "==> Creating character devices"

sudo mknod ${SYSROOT}/dev/console c 5 1
sudo mknod ${SYSROOT}/dev/kmsg c 1 11
sudo mknod ${SYSROOT}/dev/null c 1 3
sudo mknod ${SYSROOT}/dev/random c 1 8
sudo mknod ${SYSROOT}/dev/urandom c 1 9

echo "==> Installing pacakges"

sudo rpmdb --initdb --root ${SYSROOT}

sudo yum -y --installroot=${SYSROOT} --releasever=29 install fedora-release systemd bash binutils kernel dnf iproute NetworkManager iputils openssh-server kexec-tools

sudo yum -y --installroot=${SYSROOT} --releasever=29 localinstall spl/kmod-spl-4.19.8-300.fc29.x86_64-0.7.12-1.fc29.x86_64.rpm spl/spl-0.7.12-1.fc29.x86_64.rpm

sudo yum -y --installroot=${SYSROOT} --releasever=29 localinstall zfs/kmod-zfs-4.19.8-300.fc29.x86_64-0.7.12-1.fc29.x86_64.rpm zfs/libnvpair1-0.7.12-1.fc29.x86_64.rpm zfs/libuutil1-0.7.12-1.fc29.x86_64.rpm zfs/libzfs2-0.7.12-1.fc29.x86_64.rpm zfs/libzpool2-0.7.12-1.fc29.x86_64.rpm zfs/zfs-0.7.12-1.fc29.x86_64.rpm zfs/zfs-dracut-0.7.12-1.fc29.x86_64.rpm

#zfs/zfs-test-0.7.12-1.fc29.x86_64.rpm
#rsync 

# TODO: setup authorized keys for root

sudo ln -s /usr/lib/systemd/systemd ${SYSROOT}/init

sudo cp kexec-to-zfs.sh ${SYSROOT}/root/ 
sudo chmod +x ${SYSROOT}/root/kexec-to-zfs.sh

sudo cp initialize-zfs-disk.sh ${SYSROOT}/root/ 
sudo chmod +x ${SYSROOT}/root/initialize-zfs-disk.sh

echo "==> Setting root password"
set_root_pass ${SYSROOT}/etc/shadow

echo "==> Cleaning image"
sudo rm -rf ${SYSROOT}/var/cache/dnf/*

echo "==> Creating archive"
cd ${SYSROOT}
sudo find . | sudo cpio -ov --format=newc | sudo gzip -9 > ../initramfs.img

echo "==> Cleaning up"
cd
#rm -rf ${SYSROOT}
