#!/bin/sh

boot_initrd() {
    qemu-system-aarch64 -nographic -machine virt -m 512M -cpu cortex-a53 \
        -kernel arm64/run/Image.gz -append "root=/dev/ram0 rootfstype=ramfs rw init=/init" \
        -initrd arm64/run/initrd.gz \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm64/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm64/run/vda.ext4,if=none,id=vda,format=raw
}

boot_vda() {
    qemu-system-aarch64 -nographic -machine virt -m 512M -cpu cortex-a53 \
        -kernel arm64/run/Image.gz -append "root=/dev/vda rootfstype=ext4 rw init=/init" \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm64/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm64/run/vda.ext4,if=none,id=vda,format=raw
}

boot_uboot() {
    qemu-system-aarch64 -nographic -machine virt -m 512M -cpu cortex-a53 \
        -bios ./arm64/run/u-boot-nodtb.bin \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm64/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm64/run/vda.ext4,if=none,id=vda,format=raw \
        -drive if=pflash,format=raw,index=1,file=arm64/run/flash.img

    # setenv bootargs "root=/dev/vda rootfstype=ext4 rw init=/init"
    # setenv bootcmd "load virtio 0:0 0x40080000 Image;booti 0x40080000 - 0x40000000"
    # saveenv
    # run bootcmd
}

if [ $# -lt 1 ]; then
    echo "error: run mode needed"
    echo 'Usage:' $0 '{ initrd | vhd | uboot }'
    exit 0
fi

if [ $1 = 'initrd' ]; then
    boot_initrd
elif [ $1 = 'vhd' ]; then
    boot_vda
elif [ $1 = 'uboot' ]; then
    boot_uboot
else
    echo "error: bad run mode"
    echo 'Usage:' $0 '{ initrd | vhd | uboot }'
fi
