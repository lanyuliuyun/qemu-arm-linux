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