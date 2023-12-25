# uboot startup process

the basic code call flow is as follows
```
arch/arm/cpu/armv8/start.S:_start
  apply_core_errata
  lowlevel_init
  
  arch/arm/lib/crt0_64.S:_main
    common/init/board_init.c:
      board_init_f_alloc_reserve
      board_init_f_init_reserve

    drivers/serial/serial_pl01x.c:debug_uart_init

    common/board_f.c:board_init_f
      board/emulation/qemu-arm/qemu-arm.c:
        dram_init
        dram_init_banksize
        ...

    arch/arm/lib/relocate_64.S:relocate_code
    arch/arm/cpu/armv8/start.S:c_runtime_cpu_setup

    common/board_r.c:board_init_r
      board/emulation/qemu-arm/qemu-arm.c:
        board_init
        board_late_init
        ..
        common/board_r.c:run_main_loop
```

block-size 0x20000, 128K

# partition plan
name         size         offset        addr
loader       0x0E0000     0x0           0x4000000      822332
env          0x020000     0x0E0000      0x40E0000      65536
fdt          0x020000     0x100000      0x4100000      65536
kernel       0x520000     0x120000      0x4120000      5138944
rootfs       -            0x620000      0x4620000

bootargs中的分区参数
mtdparts=nor0:896k(loader),128k(env),128k(fdt),5248k(kernel),-(rootfs)
