# sd-fuse_s5p6818
Create bootable SD card for NanoPi Fire3/NanoPC T3/NanoPC T3 Plus/NanoPi M3/Smart6818

## How to find the /dev name of my SD Card
Unplug all usb devices:
```
ls -1 /dev > ~/before.txt
```
plug it in, then
```
ls -1 /dev > ~/after.txt
diff ~/before.txt ~/after.txt
```

## Build friendlycore bootable SD card
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818.git
cd sd-fuse_s5p6818
sudo ./fusing.sh /dev/sdX friendlycore
```
You can build the following OS: friendlycore, friendlycore-arm64, lubuntu, eflasher, android.  

Notes:  
fusing.sh will check the local directory for a directory with the same name as OS, if it does not exist fusing.sh will go to download it from network.  
So you can download from the netdisk in advance, on netdisk, the images files are stored in a directory called images-for-eflasher, for example:
```
cd sd-fuse_s5p6818
tar xvzf ../images-for-eflasher/friendlycore-images.tgz
sudo ./fusing.sh /dev/sdX friendlycore
```

## Build an sd card image
First, download and unpack:
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818.git
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xvzf friendlycore-arm64-images.tgz
```
Now,  Change something under the friendlycore-arm64 directory, 
for example, replace the file you compiled, then build friendlycore-arm64 bootable SD card: 
```
sudo ./fusing.sh /dev/sdX friendlycore-arm64
```
or build an sd card image:
```
sudo ./mkimage.sh friendlycore-arm64
```
The following file will be generated:  
```
s5p6818-friendly-core-xenial-4.4-arm64-$(date +%Y%m%d).img
```
You can use dd to burn this file into an sd card:
```
dd if=s5p6818-friendly-core-xenial-4.4-arm64-$(date +%Y%m%d).img of=/dev/sdX bs=1M
```
## Build a package similar to s5p6818-eflasher-friendlycore-xenial-4.4-arm64-YYYYMMDD.img
Enable exFAT file system support on Ubuntu:
```
sudo apt-get install exfat-fuse exfat-utils
```
Generate the eflasher raw image, and put friendlycore image files into eflasher:
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818.git
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
sudo ./mkimage.sh eflasher
DEV=`losetup -f`
losetup ${DEV} s5p6818-eflasher-$(date +%Y%m%d).img
partprobe ${DEV}
sudo mkfs.exfat ${DEV}p1 -n FriendlyARM
mkdir -p /mnt/exfat
mount -t exfat ${DEV}p1 /mnt/exfat
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz -C /mnt/exfat
umount /mnt/exfat
losetup -d ${DEV}
```

## Replace the file you compiled

### Install cross compiler and tools

Install the package:
```
apt install liblz4-tool android-tools-fsutils
```
Install Cross Compiler:
```
git clone https://github.com/friendlyarm/prebuilts.git
sudo mkdir -p /opt/FriendlyARM/toolchain
sudo tar xf prebuilts/gcc-x64/aarch64-cortexa53-linux-gnu-6.4.tar.xz -C /opt/FriendlyARM/toolchain/
```

### Build U-boot and Kernel for Lubuntu, FriendlyCore
Download image files:
```
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/lubuntu-desktop-images.tgz
tar xzf lubuntu-desktop-images.tgz
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz
```
Build kernel:
```
cd sd-fuse_s5p6818
git clone https://github.com/friendlyarm/linux.git -b nanopi2-v4.4.y --depth 1
cd linux
touch .scmversion
export PATH=/opt/FriendlyARM/toolchain/6.4-aarch64/bin:$PATH
make ARCH=arm64 nanopi3_linux_defconfig
make ARCH=arm64

# lubuntu
simg2img ../lubuntu/boot.img ../lubuntu/r.img
mkdir -p /mnt/lubuntu-boot
mount -t ext4 -o loop ../lubuntu/r.img /mnt/lubuntu-boot
cp arch/arm64/boot/Image /mnt/lubuntu-boot
cp arch/arm64/boot/dts/nexell/s5p6818-nanopi3-rev*.dtb /mnt/lubuntu-boot
umount /mnt/lubuntu-boot
rm ../lubuntu/r.img

# friendlycore-arm64
simg2img ../friendlycore-arm64/boot.img ../friendlycore-arm64/r.img
mkdir -p /mnt/friendlycore-arm64-boot
mount -t ext4 -o loop ../friendlycore-arm64/r.img /mnt/friendlycore-arm64-boot
cp arch/arm64/boot/Image /mnt/friendlycore-arm64-boot
cp arch/arm64/boot/dts/nexell/s5p6818-nanopi3-rev*.dtb /mnt/friendlycore-arm64-boot
umount /mnt/friendlycore-arm64-boot
rm ../friendlycore-arm64/r.img
```
Build uboot:
```
cd sd-fuse_s5p6818
git clone https://github.com/friendlyarm/u-boot.git 
cd u-boot
git checkout nanopi2-v2016.01
make s5p6818_nanopi3_defconfig
export PATH=/opt/FriendlyARM/toolchain/6.4-aarch64/bin:$PATH
make CROSS_COMPILE=aarch64-linux-
cp fip-nonsecure.img ../lubuntu/
cp fip-nonsecure.img ../friendlycore-arm64/
```

### Custom rootfs for Lubuntu, FriendlyCore
#### Custom rootfs in the bootable SD card
Use FriendlyCore as an example:
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818.git
cd sd-fuse_s5p6818
sudo ./mkimage.sh friendlycore-arm64
DEV=`losetup -f`
losetup ${DEV} s5p6818-friendly-core-xenial-4.4-arm64-$(date +%Y%m%d).img
partprobe ${DEV}
mkdir -p /mnt/rootfs
mount -t ext4 ${DEV}p2 /mnt/rootfs
```
Now,  Change something under /mnt/rootfs directory, like this:
```
echo hello > /mnt/rootfs/root/welcome.txt
```
Save and release resources:
```
umount /mnt/rootfs
losetup -d ${DEV}
```
burn to sd card:
```
dd if=s5p6818-friendly-core-xenial-4.4-arm64-$(date +%Y%m%d).img of=/dev/sdX bs=1M
```
#### Custom rootfs for eMMC
Use FriendlyCore as an example, extract rootfs from rootfs.img:
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818.git
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xzf friendlycore-arm64-images.tgz
simg2img friendlycore-arm64/rootfs.img friendlycore-arm64/r.img
mkdir -p /mnt/rootfs
mount -t ext4 -o loop friendlycore-arm64/r.img /mnt/rootfs
mkdir rootfs
cp -af /mnt/rootfs/* rootfs
umount /mnt/rootfs
rm friendlycore-arm64/r.img
```
Now,  change something under rootfs directory, like this:
```
echo hello > rootfs/root/welcome.txt  
```
Remake rootfs.img  with the make_ext4fs utility:
```
./tools/make_ext4fs -s -l 5368709120 -a root -L rootfs rootfs.img rootfs
cp rootfs.img friendlycore-arm64/
```
One thing you should be aware of is that the size of the .img file needs to be larger than the rootfs directory size, 
below are the image size values for each system we've provided:  
eflasher: 1604321280  
friendlycore: 5368709120  
lubuntu: 5368709120  
  
### Build Android5
```
git clone https://gitlab.com/friendlyelec/s5pxx18-android5 android5-src
cd android5-src 
source build/envsetup.sh
lunch aosp_nanopi3-userdebug
make -j8
wget http://112.124.9.243/dvdfiles/S5P6818/images-for-eflasher/android-lollipop-images.tgz
tar xzf android-lollipop-images.tgz
cp out/target/product/nanopi3/boot.img \
    out/target/product/nanopi3/cache.img \
    out/target/product/nanopi3/userdata.img \
    out/target/product/nanopi3/system.img \
    out/target/product/nanopi3/partmap.txt \
    android/
```
Copy the new image files to the exfat partition of the eflasher sd card:
```
cp -af android /mnt/exfat/
```
