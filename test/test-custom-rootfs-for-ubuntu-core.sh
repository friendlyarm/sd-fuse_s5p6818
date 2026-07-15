#!/bin/bash
set -eux

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/s5p6818/images
    ROOTFS_URL=http://cdn.local/friendlyelec-cdn/rootfs/s5p6818
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/s5p6818/images
    ROOTFS_URL=https://downloads.friendlyelec.com/rootfs/s5p6818
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
wget ${CDN_URL}/ubuntu-noble-core-arm64-images.tgz
tar xzf ubuntu-noble-core-arm64-images.tgz
wget ${CDN_URL}/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget ${ROOTFS_URL}/rootfs-ubuntu-noble-core-arm64.tgz
wget ${ROOTFS_URL}/rootfs-ubuntu-noble-core-arm64.tgz.sha256
sha256sum -c rootfs-ubuntu-noble-core-arm64.tgz.sha256
tar xzf rootfs-ubuntu-noble-core-arm64.tgz
echo hello > ubuntu-noble-core-arm64/rootfs/root/welcome.txt
(cd ubuntu-noble-core-arm64/rootfs/root/ && {
	wget ${CDN_URL}/ubuntu-noble-core-arm64-images.tgz -O deleteme.tgz
});
./build-rootfs-img.sh ubuntu-noble-core-arm64/rootfs ubuntu-noble-core-arm64

# build kernel
git clone ${KERNEL_URL} --depth 1 -b ${KERNEL_BRANCH} kernel-s5p6818
KERNEL_SRC=$PWD/kernel-s5p6818 ./build-kernel.sh ubuntu-noble-core-arm64

# build uboot
git clone https://github.com/friendlyarm/u-boot --depth 1 -b nanopi2-v2016.01 uboot-s5p6818
UBOOT_SRC=$PWD/uboot-s5p6818 ./build-uboot.sh ubuntu-noble-core-arm64

sudo ./mk-sd-image.sh ubuntu-noble-core-arm64
sudo ./mk-emmc-image.sh ubuntu-noble-core-arm64
