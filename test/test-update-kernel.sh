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
wget http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz

# git clone https://github.com/friendlyarm/linux -b nanopi2-v4.4.y --depth 1 kernel-s5p6818
git clone git@192.168.1.5:/devel/kernel/linux.git --depth 1 -b nanopi2-v4.4.y kernel-s5p6818

KERNEL_SRC=$PWD/kernel-s5p6818 ./build-kernel.sh friendlycore-arm64
sudo ./mk-sd-image.sh friendlycore-arm64
