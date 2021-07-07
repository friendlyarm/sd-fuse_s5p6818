#!/bin/bash

TARGET_OS=${1,,}

case ${TARGET_OS} in
android)
        ROMFILE=android-lollipop-images.tgz;;
android7)
        ROMFILE=android-nougat-images.tgz;;
friendlywrt)
        ROMFILE=friendlywrt-images.tgz;;
friendlycore)
        ROMFILE=friendlycore-images.tgz;;
friendlycore-arm64)
        ROMFILE=friendlycore-arm64-images.tgz;;
friendlycore-lite-focal)
        ROMFILE=friendlycore-lite-focal-images.tgz;;
friendlycore-lite-focal-arm64)
        ROMFILE=friendlycore-lite-focal-arm64-images.tgz;;
lubuntu)
        ROMFILE=lubuntu-desktop-images.tgz;;
eflasher)
        ROMFILE=emmc-flasher-images.tgz;;
*)
	ROMFILE=
esac

echo $ROMFILE
