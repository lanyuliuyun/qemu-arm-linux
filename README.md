# qemu-arm-linux

This repo provides shell scripts to build arm linux from scratch. We can use the result runtime as a environment for kernel model/driver development.

## prepare the needed tools
```bash
wget -c https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
sudo tar -C /opt -Jxf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz

sudo apt-get install qemu-system-aarch64 ipxe-qemu flex bison -y
```

## Usage
- download and build all arm linux components
```bash
chmod +x r.sh build.sh

./build.sh
```

- start arm linux from initramdisk
```bash
r.sh initrd
 ```

- start arm linux from vhd
```bash
r.sh vhd
 ```

- start arm linux from uboot
```bash
r.sh uboot
 ```
