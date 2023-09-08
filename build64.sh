#!/bin/bash

export ARCH=arm64
export CROSS_COMPILE=/opt/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

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
    mkdir -p ./arm64/vfs
    cp -Pvr rootfs ./arm64/
    mkdir -p ./arm64/rootfs/{dev,sys,proc,lib,tmp,mnt,root,vfs}
}

build_linux() {
  echo "build_linux ..."
  cd linux-4.9.37
  make distclean
  #make defconfig
  cp -vf ../arm64/run/linux.config .config
  make olddefconfig
  make Image.gz modules -j4 > /dev/null
  #make uImage LOADADDR=0x40080000
  #make dtbs 

  cp -fv arch/arm64/boot/Image ../arm64/run/
  cp -fv arch/arm64/boot/Image.gz ../arm64/run/
  #cp -fv arch/arm64/boot/uImage ../arm64/run/
  qemu-system-aarch64 -nographic -machine virt,dumpdtb=../arm64/run/virt.dtb -m 512M -cpu cortex-a53
  make modules_install INSTALL_MOD_PATH=../vfs
  #cp -fv .config ../arm64/run/linux.config

  cd -
}

build_uboot() {
    cd u-boot-2023.04
    make distclean
    #make qemu_arm64_defconfig
    cp -vf ../arm64/run/uboot.config  .config
    make olddefconfig
    make -j4 CROSS_COMPILE=${CROSS_COMPILE} > /dev/null
    cp -vf u-boot-nodtb.bin ../arm64/run/
    #cp -vf .config ../arm64/run/uboot.config

    cd -
}

build_busybox() {
  echo "build_busybox..."
  cd busybox-1.25.1
  make distclean
  cp -vf ../arm64/run/busybox.config .config
  #make defconfig
  make CROSS_COMPILE=${CROSS_COMPILE} -j4 > /dev/null
  make install CONFIG_PREFIX=../arm64/rootfs
  #cp -vf .config ../arm64/run/busybox.config
  
  cd -
}

build_initrd() {
    echo "build init ramdisk"
    cd arm64/rootfs
    find ./ | cpio -o -H newc | gzip > ../run/initrd.gz

    cd -
}

make_boot_image() {
    dd if=/dev/zero of=arm64/run/flash.img bs=1MiB count=64
    dd if=/dev/zero of=./arm64/run/vda.ext4 bs=1MiB count=128
    mkfs.ext4 arm64/run/vda.ext4
    
    sudo mount -o loop arm64/run/vda.ext4 /mnt/
    cd arm64/rootfs
    sudo cp -Pvr ./* /mnt/
    cd -
    sudo cp -vf ./arm64/run/Image /mnt
    sudo umount /mnt
}

download_packs
init_rootfs
build_linux
build_uboot
build_busybox
build_initrd
make_boot_image
