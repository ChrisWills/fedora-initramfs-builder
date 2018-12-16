#!/bin/bash

zpool create pool -m none -o ashift=12 /dev/vda

zfs create pool/root
zfs create pool/root/var
zfs create pool/root/home

zfs set compression=on pool
zfs set atime=off pool

zpool export pool
zpool import -o altroot=/sysroot pool

zfs set mountpoint=/ pool/root

echo "pool/root / zfs defaults 0 0" > /sysroot/etc/fstab
