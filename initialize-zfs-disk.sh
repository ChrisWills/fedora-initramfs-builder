#!/bin/bash

set -e

dnf -y install rsync

zpool create pool -m none -o ashift=12 /dev/vda

zfs create pool/root
zfs create pool/root/var
zfs create pool/root/home

zfs set compression=on pool
zfs set atime=off pool

zpool export pool
zpool import -o altroot=/sysroot pool

zfs set mountpoint=/ pool/root

dracut -fv --kver `uname -r`

rsync -axvHASX / /sysroot/

echo "pool/root / zfs defaults 0 0" > /sysroot/etc/fstab

kexec -l /boot/vmlinuz-4.19.8-300.fc29.x86_64 --append "root=ZFS=pool/root LANG=en_US.UTF-8" --initrd=/boot/initramfs-4.19.8-300.fc29.x86_64.img

#kexec -e
