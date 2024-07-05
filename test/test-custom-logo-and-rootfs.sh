#!/bin/bash
set -eu

HTTP_SERVER=112.124.9.243
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
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/rootfs/rootfs-friendlycore-arm64.tgz
tar xzf rootfs-friendlycore-arm64.tgz

# custome rootfs: re-gen rootfs.img
echo hello > friendlycore-arm64/rootfs/root/welcome.txt
(cd friendlycore-arm64/rootfs/root/ && {
	wget --no-proxy http://${HTTP_SERVER}/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz -O deleteme.tgz
});
./build-rootfs-img.sh friendlycore-arm64/rootfs friendlycore-arm64

# custome logo: re-gen boot.img
wget https://upload.wikimedia.org/wikipedia/commons/8/8d/Linux_Logo.jpg
convert Linux_Logo.jpg -type truecolor friendlycore-arm64/boot/logo.bmp
./build-boot-img.sh friendlycore-arm64/boot friendlycore-arm64/boot.img

# custome kernel
git clone ${KERNEL_URL} --depth 1 -b ${KERNEL_BRANCH} kernel-s5p6818
(cd kernel-s5p6818 && {
	# disabling "Framebuffer Console support" allows Logo to stay long enough until user-app starts.
	sed -i 's/^CONFIG_FRAMEBUFFER_CONSOLE=.*/# CONFIG_FRAMEBUFFER_CONSOLE is not set/' arch/arm64/configs/nanopi3_linux_defconfig
})
KERNEL_SRC=$PWD/kernel-s5p6818 ./build-kernel.sh friendlycore-arm64

sudo ./mk-sd-image.sh friendlycore-arm64
sudo ./mk-emmc-image.sh friendlycore-arm64
