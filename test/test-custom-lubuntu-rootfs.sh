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
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/lubuntu-desktop-images.tgz
tar xzf lubuntu-desktop-images.tgz
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/rootfs/rootfs-lubuntu.tgz
tar xzf rootfs-lubuntu.tgz
echo hello > lubuntu/rootfs/root/welcome.txt
(cd lubuntu/rootfs/root/ && {
	wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/lubuntu-desktop-images.tgz -O deleteme.tgz
});
./build-rootfs-img.sh lubuntu/rootfs lubuntu
sudo ./mk-sd-image.sh lubuntu
sudo ./mk-emmc-image.sh lubuntu
