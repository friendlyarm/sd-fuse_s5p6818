#!/bin/bash
set -eux

HTTP_SERVER=112.124.9.243

# hack for me
PCNAME=`hostname`
if [ x"${PCNAME}" = x"tzs-i7pc" ]; then
       HTTP_SERVER=127.0.0.1
fi

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/rootfs/rootfs-eflasher.tgz
tar xzf rootfs-eflasher.tgz

echo hello > eflasher/rootfs/root/welcome.txt
(cd eflasher/rootfs/root/ && {
    wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz -O deleteme.tgz
});

./build-rootfs-img.sh eflasher/rootfs eflasher
sudo ./mk-emmc-image.sh friendlycore-arm64
