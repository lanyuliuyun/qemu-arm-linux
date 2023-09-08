#!/bin/bash

export ARCH=arm
export CROSS_COMPILE=/opt/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

download_packs() {
    if [ ! -d linux-4.9.37 ]; then
        if [ ! -f linux-4.9.37.tar.gz ]; then
            wget -c https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.37.tar.gz
        fi
        tar zxf linux-4.9.37.tar.gz
    fi

    if [ ! -d u-boot-2023.04 ]; then
        git clone --depth 1 https://github.com/u-boot/u-boot.git -b v2023.04 u-boot-2023.04
    fi

    if [ ! -d busybox-1.25.1 ]; then
        if [ ! -f busybox-1.25.1.tar.bz2 ]; then
            wget -c https://www.busybox.net/downloads/busybox-1.25.1.tar.bz2
        fi
        tar jxf busybox-1.25.1.tar.bz2
    fi
}

init_rootfs() {
    mkdir -p ./arm/vfs
    cp -Pvr rootfs ./arm/
    mkdir -p ./arm/rootfs/{dev,sys,proc,lib,tmp,mnt,root,vfs}
}

build_linux() {
  echo "build_linux ..."
  cd linux-4.9.37
  make distclean
  #make defconfig
  cp -vf ../arm/run/linux.config .config
  make olddefconfig
  make zImage modules -j4 > /dev/null
  #make uImage LOADADDR=0x40080000
  #make dtbs 

  cp -fv arch/arm/boot/zImage ../arm/run/
  cp -fv vmlinux ../arm/run/
  #cp -fv arch/arm/boot/uImage ../arm/run/
  qemu-system-arm -nographic -machine virt,dumpdtb=../arm/run/virt.dtb -m 512M -cpu cortex-a17
  make modules_install INSTALL_MOD_PATH=../arm/vfs
  #cp -fv .config ../arm/run/linux.config

  cd -
}

build_uboot() {
    cd u-boot-2023.04
    make distclean
    #make qemu_arm_defconfig
    cp -vf ../arm/run/uboot.config  .config
    make olddefconfig
    make -j4 CROSS_COMPILE=${CROSS_COMPILE} > /dev/null
    cp -vf u-boot-nodtb.bin ../arm/run/
    #cp -vf .config ../arm/run/uboot.config

    cd -
}

build_busybox() {
  echo "build_busybox..."
  cd busybox-1.25.1
  make distclean
  cp -vf ../arm/run/busybox.config .config
  #make defconfig
  make CROSS_COMPILE=${CROSS_COMPILE} -j4 > /dev/null
  make install CONFIG_PREFIX=../arm/rootfs
  #cp -vf .config ../arm/run/busybox.config
  
  cd -
}

build_initrd() {
    echo "build init ramdisk"
    cd arm/rootfs
    find ./ | cpio -o -H newc | gzip > ../run/initrd.gz

    cd -
}

make_boot_image() {
    dd if=/dev/zero of=arm/run/flash.img bs=1MiB count=64
    dd if=/dev/zero of=./arm/run/vda.ext4 bs=1MiB count=128
    mkfs.ext4 arm/run/vda.ext4
    
    sudo mount -o loop arm/run/vda.ext4 /mnt/
    cd arm/rootfs
    sudo cp -Pvr ./* /mnt/
    cd -
    sudo cp -vf ./arm/run/zImage /mnt
    sudo umount /mnt
}

download_packs
init_rootfs
build_linux
build_uboot
build_busybox
build_initrd
make_boot_image
