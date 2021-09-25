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
wget http://${HTTP_SERVER}/dvdfiles/s5p6818/images-for-eflasher/friendlycore-images-arm64.tgz
tar xzf friendlycore-images-arm64.tgz
wget http://${HTTP_SERVER}/dvdfiles/s5p6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

# make big file
fallocate -l 6G friendlycore-arm64/rootfs.img

# calc image size
IMG_SIZE=`du -s -B 1 friendlycore-arm64/rootfs.img | cut -f1`

# re-gen partmap.txt
./tools/generate-partmap-txt.sh ${IMG_SIZE} friendlycore-arm64

sudo ./mk-sd-image.sh friendlycore-arm64
sudo ./mk-emmc-image.sh friendlycore-arm64
