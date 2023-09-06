# qemu-arm-linux

This repo provides shell scripts to build arm linux from scratch. We can use the result runtime as a environment for kernel model/driver development.

## prepare the needed tools
```bash
wget -c https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
wget -c https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
sudo tar -C /opt -Jxf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
sudo tar -C /opt -Jxf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz

sudo apt-get install qemu-system-arm ipxe-qemu flex bison -y
```

## Usage
- download and build all arm linux components
```bash
./build32.sh
./build64.sh
```

- start arm linux from initramdisk / vhd / uboot
```bash
./r32.sh { initrd | vhd | uboot }
./r64.sh { initrd | vhd | uboot }
 ```
