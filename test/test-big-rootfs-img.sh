#!/bin/bash
set -eux

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/s5p6818/images
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/s5p6818/images
fi
# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget ${CDN_URL}/friendlycore-images-arm64.tgz
tar xzf friendlycore-images-arm64.tgz
wget ${CDN_URL}/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

# make big file
fallocate -l 6G friendlycore-arm64/rootfs.img

# calc image size
IMG_SIZE=`du -s -B 1 friendlycore-arm64/rootfs.img | cut -f1`

# re-gen partmap.txt
./tools/generate-partmap-txt.sh ${IMG_SIZE} friendlycore-arm64

sudo ./mk-sd-image.sh friendlycore-arm64
sudo ./mk-emmc-image.sh friendlycore-arm64
