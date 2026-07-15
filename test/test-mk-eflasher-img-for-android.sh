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
wget ${CDN_URL}/android-nougat-images.tgz
tar xzf android-nougat-images.tgz
wget ${CDN_URL}/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

sudo ./mk-sd-image.sh android7
sudo ./mk-emmc-image.sh android7
