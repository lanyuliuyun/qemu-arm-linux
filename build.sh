#!/bin/bash

export ARCH=arm64
export CROSS_COMPILE=/opt/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-

download_packs() {
    if [ ! -f linux-4.9.37.tar.gz ]; then
        wget -c https://mirrors.163.com/kernel/v4.x/linux-4.9.37.tar.gz
    fi
    if [ ! -d linux-4.9.37 ]; then
        tar zxf linux-4.9.37.tar.gz
    fi

    if [ ! -f u-boot-2023.04.tar.gz ]; then
        wget -c https://github.com/u-boot/u-boot/archive/refs/tags/v2023.04.tar.gz -O u-boot-2023.04.tar.gz
    fi
    if [ ! -d u-boot-2023.04 ]; then
        tar zxf u-boot-2023.04.tar.gz
    fi

    if [ ! -f busybox-1.25.1.tar.bz2 ]; then
        wget -c https://www.busybox.net/downloads/busybox-1.25.1.tar.bz2
    fi
    if [ ! -d busybox-1.25.1 ]; then
        tar jxf busybox-1.25.1.tar.bz2
    fi
}

build_linux() {
  echo "build_linux ..."
  cd linux-4.9.37
  #make defconfig
  cp -vf ../run/linux.config .config
  make olddefconfig
  make Image.gz modules -j4 > /dev/null
  #make uImage LOADADDR=0x40080000
  #make dtbs 

  cp -fv arch/arm64/boot/Image ../run/
  cp -fv arch/arm64/boot/Image.gz ../run/
  #cp -fv arch/arm64/boot/uImage ../run/
  qemu-system-aarch64 -nographic -machine virt,dumpdtb=../run/virt.dtb -m 512M -cpu cortex-a53
  make modules_install INSTALL_MOD_PATH=../vfs
  #cp -fv .config ../run/linux.config

  cd -
}

build_uboot() {
    cd u-boot-2023.04
    #make qemu_arm64_defconfig
    cp -vf ../run/ubooot.config  .config
    make olddefconfig
    make -j4 CROSS_COMPILE=${CROSS_COMPILE} > /dev/null
    # apt-get install ipxe-qemu
    cp -vf u-boot-nodtb.bin ../run/
    #cp -vf .config ../run/ubooot.config

    cd -
}

build_busybox() {
  echo "build_busybox..."
  cd busybox-1.25.1
  cp -vf ../run/busybox.config .config
  #make defconfig
  make CROSS_COMPILE=${CROSS_COMPILE} -j4 > /dev/null
  make install CONFIG_PREFIX=../rootfs
  #cp -vf .config ../run/busybox.config
  
  cd -
}

init_rootfs() {
    mkdir -p ./rootfs/{dev,sys,proc,lib,tmp,mnt,root,vfs}
}

build_initrd() {
    echo "build init ramdisk"
    cd rootfs
    find ./ | cpio -o -H newc | gzip > ../run/initrd.gz

    cd -
}

make_boot_image() {
    dd if=/dev/zero of=./run/vda.ext4 bs=1MiB count=128
    mkfs.ext4 run/vda.ext4
    
    sudo mount -o loop run/vda.ext4 /mnt/
    cd rootfs
    sudo cp -Pvr ./* /mnt/
    cd -
    sudo cp -vf ./run/Image /mnt
    sudo umount /mnt
}

download_packs
build_linux
build_uboot
build_busybox
init_rootfs
build_initrd
make_boot_image
