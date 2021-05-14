#!/bin/bash
set -eux

HTTP_SERVER=112.124.9.243

# hack for me
PCNAME=`hostname`
if [ x"${PCNAME}" = x"tzs-i7pc" ]; then
       HTTP_SERVER=192.168.1.9
fi

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/android-nougat-images.tgz
tar xzf android-nougat-images.tgz
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

sudo ./mk-sd-image.sh android7
sudo ./mk-emmc-image.sh android7
