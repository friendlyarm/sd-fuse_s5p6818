#!/bin/bash
set -eux

if [ -f "$(dirname "$(readlink -f "$0")")/../.use-local-r2" ]; then
    CDN_URL=http://cdn.local/friendlyelec-cdn/os-images/s5p6818/images
    ROOTFS_URL=http://cdn.local/friendlyelec-cdn/rootfs/s5p6818
else
    CDN_URL=https://downloads.friendlyelec.com/os-images/s5p6818/images
    ROOTFS_URL=https://downloads.friendlyelec.com/rootfs/s5p6818
fi
# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget ${CDN_URL}/lubuntu-desktop-images.tgz
tar xzf lubuntu-desktop-images.tgz
wget ${CDN_URL}/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget ${ROOTFS_URL}/rootfs-lubuntu.tgz
wget ${ROOTFS_URL}/rootfs-lubuntu.tgz.sha256
sha256sum -c rootfs-lubuntu.tgz.sha256
tar xzf rootfs-lubuntu.tgz
echo hello > lubuntu/rootfs/root/welcome.txt
(cd lubuntu/rootfs/root/ && {
	wget ${CDN_URL}/lubuntu-desktop-images.tgz -O deleteme.tgz
});
./build-rootfs-img.sh lubuntu/rootfs lubuntu
sudo ./mk-sd-image.sh lubuntu
sudo ./mk-emmc-image.sh lubuntu
