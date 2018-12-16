#!/bin/bash
set -e

# The import throws an error about var being non-empty when mounting...
# Really I just want a sanity check here to make sure a zfs filesystem is found before trying to kexec
# TODO: come up with something better here
#zpool import -o altroot=/sysroot pool -f
#zpool export pool

dracut -fv --kver `uname -r`

kexec -l /boot/vmlinuz-4.19.8-300.fc29.x86_64 --append "root=ZFS=pool/root LANG=en_US.UTF-8" --initrd=/boot/initramfs-4.19.8-300.fc29.x86_64.img

kexec -e
