
# sd-fuse_s5p6818
## 简介
sd-fuse 提供一些工具和脚本, 用于制作SD卡固件, 具体用途如下:

* 制作分区镜像文件, 例如将rootfs目录打包成rootfs.img
* 将多个分区镜像文件打包成可直接写SD卡的单一镜像文件
* 简化内核和uboot的编译, 一键编译内核、第三方驱动, 并更新rootfs.img中的内核模块
  
*其他语言版本: [English](README.md)*  
  
## 运行环境
* 支持 x86_64 和 aarch64 平台
* 推荐的操作系统: Ubuntu 20.04及以上64位操作系统
* 针对x86_64用户，推荐运行此脚本初始化开发环境: https://github.com/friendlyarm/build-env-on-ubuntu-bionic
* Docker容器: https://github.com/friendlyarm/docker-cross-compiler-novnc

## 支持的内核版本
sd-fuse 使用不同的git分支来支持不同的内核版本, 当前支持的内核版本为:
* 4.4.y   
  
其他内核版本, 请切换到相应的git分支
## 支持的目标板OS

* lubuntu
* friendlycore
* friendlycore-arm64
* friendlycore-lite-focal
* friendlycore-lite-focal-arm64
* android
* android7
* friendlywrt

  
这些OS名称是分区镜像文件存放的目录名, 在脚本内亦有严格定义, 所以不能改动, 例如要制作friendlycore-arm64的SD固件, 可使用如下命令:
```
./mk-sd-image.sh friendlycore-arm64
```
  
## 获得打包固件所需要的素材
制作固件所需要的素材有:
* 内核源代码: 在[网盘](https://download.friendlyelec.com/s5p6818)的 "07_源代码" 目录中, 或者从[此github链接](https://github.com/friendlyarm/linux)下载, 分支为nanopi2-v4.4.y
* uboot源代码: 在[网盘](https://download.friendlyelec.com/s5p6818)的 "07_源代码" 目录中, 或者从[此github链接](https://github.com/friendlyarm/u-boot)下载, 分支为nanopi2-v2016.01
* 分区镜像文件: 在[网盘](https://download.friendlyelec.com/s5p6818)的 "03_分区镜像文件" 目录中, 或者从[此http链接](http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher)下载
* 文件系统压缩包: 在[网盘](https://download.friendlyelec.com/s5p6818)的 "06_文件系统" 目录中, 或者从[此http链接](http://112.124.9.243/dvdfiles/s5p6818/rootfs)下载
  
如果没有提前准备好文件, 脚本亦会使用wget命令从http server去下载, 不过因为http服务器带宽不足的关系, 速度可能会比较慢。

## 脚本功能
* fusing.sh: 将镜像烧写至SD卡
* mk-sd-image.sh: 制作SD卡镜像
* mk-emmc-image.sh: 制作eMMC卡刷固件(SD-to-eMMC)

* build-boot-img.sh: 将指定目录打包成boot镜像(boot.img)

* build-rootfs-img.sh: 将指定目录打包成文件系统镜像(rootfs.img)
* build-kernel.sh: 编译内核,或内核头文件
* build-uboot.sh: 编译uboot

## 如何使用
### 重新打包SD卡运行固件
*注: 这里以friendlycore-arm64系统为例进行说明*  
下载本仓库到本地, 然后下载并解压friendlycore-arm64系统的[分区镜像文件压缩包](http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher), 由于http服务器带宽的关系, wget命令可能会比较慢, 推荐从网盘上下载同名的文件:
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818 -b master --single-branch sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xvzf friendlycore-arm64-images.tgz
```
解压后, 会得到一个名为friendlycore-arm64的目录, 可以根据项目需要, 对目录里的文件进行修改, 例如把rootfs.img替换成自已修改过的文件系统镜像, 或者自已编译的内核和uboot等, 准备就绪后, 输入如下命令将系统映像写入到SD卡  (其中/dev/sdX是你的SD卡设备名):
```
sudo ./fusing.sh /dev/sdX friendlycore-arm64
```
或者, 打包成可用于SD卡烧写的单一镜像文件:
```
./mk-sd-image.sh friendlycore-arm64
```
命令执行成功后, 将生成以下文件, 此文件可烧写到SD卡运行:  
```
out/s5p6818-sd-friendly-core-xenial-4.4-arm64-YYYYMMDD.img
```


### 重新打包 SD-to-eMMC 卡刷固件
*注: 这里以friendlycore-arm64系统为例进行说明*  
下载本仓库到本地, 然后下载并解压[分区镜像文件压缩包](http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher), 这里需要下载friendlycore-arm64和eflasher系统的文件:
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818 -b master --single-branch sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xvzf friendlycore-arm64-images.tgz
wget http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher/emmc-flasher-images.tgz
tar xvzf emmc-flasher-images.tgz
```
再使用以下命令, 打包卡刷固件, autostart=yes参数表示使用此固件开机时,会自动进入烧写流程:
```
./mk-emmc-image.sh friendlycore-arm64 autostart=yes
```
命令执行成功后, 将生成以下文件, 此文件可烧写到SD卡运行:  
```
out/s5p6818-eflasher-friendly-core-xenial-4.4-arm64-YYYYMMDD.img
```
### 备份文件系统并创建SD映像(将系统及应用复制到另一块开发板)
#### 备份根文件系统
开发板上执行以下命令，备份整个文件系统（包括OS与数据)：  
```
sudo passwd root
su root
cd /
tar --warning=no-file-changed -cvpzf /rootfs.tar.gz \
    --exclude=/rootfs.tar.gz --exclude=/var/lib/docker/runtimes \
    --exclude=/etc/firstuser --exclude=/etc/friendlyelec-release \
    --exclude=/usr/local/first_boot_flag --one-file-system /
```
#### 从根文件系统制作一个可启动的SD卡
*注: 这里以friendlycore-arm64系统为例进行说明*  
下载本仓库到本地, 然后下载并解压[分区镜像压缩包](http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818 -b master --single-branch sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xvzf friendlycore-arm64-images.tgz
```
解压上一章节中从开发板上导出的rootfs.tar.gz, 需要使用root权限, 因此解压命令需要加上sudo:
```
mkdir friendlycore-arm64/rootfs
./tools/extract-rootfs-tar.sh rootfs.tar.gz friendlycore-arm64/rootfs
```
或者从以下网址下载文件系统压缩包并解压:
```
wget http://112.124.9.243/dvdfiles/s5p6818/rootfs/rootfs-friendlycore.tgz
./tools/extract-rootfs-tar.sh rootfs-friendlycore.tgz
```
用以下命令将文件系统目录打包成 rootfs.img:
```
sudo ./build-rootfs-img.sh friendlycore-arm64/rootfs friendlycore-arm64
```
最后打包成SD卡镜像文件:
```
./mk-sd-image.sh friendlycore-arm64
```
或生成SD-to-eMMC卡刷固件:
```
./mk-emmc-image.sh friendlycore-arm64 autostart=yes
```
如果文件过大导致无法打包，可以使用RAW_SIZE_MB环境变量重新指定固件大小，比如指定为16g:
```
RAW_SIZE_MB=16000 ./mk-sd-image.sh friendlycore-arm64
RAW_SIZE_MB=16000 ./mk-emmc-image.sh friendlycore-arm64
```
### 编译内核
*注: 这里以friendlycore-arm64系统为例进行说明*  
下载本仓库到本地, 然后下载并解压[分区镜像压缩包](http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818 -b master --single-branch sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xvzf friendlycore-arm64-images.tgz
```
从github克隆内核源代码到本地:
```
git clone https://github.com/friendlyarm/linux -b nanopi2-v4.4.y --depth 1 kernel
```
根据需要配置内核:
```
cd kernel
touch .scmversion
make ARCH=arm nanopi3_linux_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux- menuconfig     # 根据需要改动配置
make ARCH=arm CROSS_COMPILE=arm-linux- savedefconfig
cp defconfig ./arch/arm/configs/my_defconfig                  # 保存配置 my_defconfig
git add ./arch/arm/configs/my_defconfig
cd -
```
编译内核，使用环境变量KERNEL_SRC和KCFG分别指定源代码目录与内核的defconfig配置:
```
KERNEL_SRC=kernel KCFG=my_defconfig ./build-kernel.sh friendlycore-arm64
```

### 编译 u-boot
*注: 这里以friendlycore-arm64系统为例进行说明* 
下载本仓库到本地, 然后下载并解压[分区镜像压缩包](http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher):
```
git clone https://github.com/friendlyarm/sd-fuse_s5p6818 -b master --single-branch sd-fuse_s5p6818
cd sd-fuse_s5p6818
wget http://112.124.9.243/dvdfiles/s5p6818/images-for-eflasher/friendlycore-arm64-images.tgz
tar xvzf friendlycore-arm64-images.tgz
```
从github克隆与OS版本相匹配的u-boot源代码到本地, 环境变量UBOOT_SRC用于指定本地源代码目录:
```
git clone https://github.com/friendlyarm/u-boot -b nanopi2-v2016.01 --depth 1 uboot
UBOOT_SRC=uboot ./build-uboot.sh friendlycore-arm64
```

## Tips: 如何查询SD卡的设备文件名
在未插入SD卡的情况下输入:
```
ls -1 /dev > ~/before.txt
```
插入SD卡,输入以下命令查询:
```
ls -1 /dev > ~/after.txt
diff ~/before.txt ~/after.txt
```


