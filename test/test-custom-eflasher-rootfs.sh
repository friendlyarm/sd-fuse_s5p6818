#!/bin/bash
set -eux

# HTTP_SERVER=112.124.9.243
HTTP_SERVER=192.168.1.9

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

wget http://${HTTP_SERVER}/dvdfiles/S5P6818/rootfs/rootfs-eflasher.tgz
tar xzf rootfs-eflasher.tgz

echo hello > eflasher/rootfs/root/welcome.txt
(cd eflasher/rootfs/root/ && {
    wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz -O deleteme.tgz
});

./build-rootfs-img.sh eflasher/rootfs eflasher
sudo ./mk-emmc-image.sh friendlycore-arm64
