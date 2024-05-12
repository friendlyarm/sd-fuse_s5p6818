#!/bin/bash
set -eux

HTTP_SERVER=112.124.9.243

# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/lubuntu-desktop-images.tgz
tar xzf lubuntu-desktop-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/rootfs/rootfs-lubuntu.tgz
tar xzf rootfs-lubuntu.tgz
echo hello > lubuntu/rootfs/root/welcome.txt
(cd lubuntu/rootfs/root/ && {
	wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/lubuntu-desktop-images.tgz -O deleteme.tgz
});
./build-rootfs-img.sh lubuntu/rootfs lubuntu
sudo ./mk-sd-image.sh lubuntu
sudo ./mk-emmc-image.sh lubuntu
