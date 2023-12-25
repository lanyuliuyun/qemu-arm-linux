#!/bin/sh

boot_initrd() {
    qemu-system-arm -nographic -machine virt -m 512M -cpu cortex-a15 \
        -kernel arm/run/zImage -append "root=/dev/ram0 rootfstype=ramfs rw init=/init" \
        -initrd arm/run/initrd.gz \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm/run/vda.ext4,if=none,id=vda,format=raw
}

boot_vda() {
    qemu-system-arm -nographic -machine virt -m 512M -cpu cortex-a15 \
        -kernel arm/run/zImage -append "root=/dev/vda rootfstype=ext4 rw init=/init" \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm/run/vda.ext4,if=none,id=vda,format=raw
}

boot_uboot() {
    qemu-system-arm -nographic -machine virt -m 512M -cpu cortex-a15 \
        -bios ./arm/run/u-boot-nodtb.bin \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm/run/vda.ext4,if=none,id=vda,format=raw \
        -drive if=pflash,format=raw,index=1,file=arm/run/flash.img

    # setenv bootargs "root=/dev/vda rootfstype=ext4 rw init=/init"
    # setenv bootcmd "load virtio 0:0 0x40080000 zImage;bootz 0x40080000 - 0x5edf0eb0"
    # saveenv
    # run bootcmd
}

boot_raw() {
    qemu-system-arm -nographic -machine virt -m 512M -cpu cortex-a15 \
        -drive if=pflash,format=raw,index=0,file=arm/run/flash-raw.img,readonly=off \
        -device virtio-9p-device,fsdev=vfs0,mount_tag=vfs_d0 -fsdev local,id=vfs0,path=arm/vfs,security_model=mapped-xattr \
        -device virtio-blk-device,drive=vda -drive file=arm/run/vda.ext4,if=none,id=vda,format=raw

    # setenv bootargs "root=/dev/vda rootfstype=ext4 rw init=/init"
    # setenv bootcmd "mtd read nor0 0x40080000 0x120000 0x4E6A08;bootz 0x40080000 - 0x40000000"
    # saveenv
    # run bootcmd
}

if [ $# -lt 1 ]; then
    echo "error: run mode needed"
    echo 'Usage:' $0 '{ initrd | vhd | uboot | raw }'
    exit 0
fi

if [ $1 = 'initrd' ]; then
    boot_initrd
elif [ $1 = 'vhd' ]; then
    boot_vda
elif [ $1 = 'uboot' ]; then
    boot_uboot
elif [ $1 = 'raw' ]; then
    boot_raw
else
    echo "error: bad run mode"
    echo 'Usage:' $0 '{ initrd | vhd | uboot | raw }'
fi
