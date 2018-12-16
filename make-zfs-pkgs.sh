#!/bin/bash

cd spl
sh autogen.sh
./configure
make -s -j$(nproc)
make -j1 pkg-utils pkg-kmod
sudo yum -y localinstall *.$(uname -p).rpm
cd ../zfs
sh autogen.sh
./configure 
make -s -j$(nproc)
make -j1 pkg-utils pkg-kmod
sudo yum -y localinstall *.$(uname -p).rpm
