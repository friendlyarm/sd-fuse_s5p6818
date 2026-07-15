#!/bin/bash
set -eux

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/s5p6818/images
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/s5p6818/images
fi
KERNEL_URL=https://github.com/friendlyarm/linux
KERNEL_BRANCH=nanopi2-v4.4.y

# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget ${CDN_URL}/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz

git clone ${KERNEL_URL} --depth 1 -b ${KERNEL_BRANCH} kernel-s5p6818
KERNEL_SRC=$PWD/kernel-s5p6818 ./build-kernel.sh friendlycore-arm64

sudo ./mk-sd-image.sh friendlycore-arm64
