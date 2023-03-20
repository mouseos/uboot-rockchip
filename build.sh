#!/bin/bash
# Create a directory to work in
mkdir ~/evb_rk3399
cd ~/evb_rk3399

# Clone the necessary repositories
git clone https://github.com/ARM-software/arm-trusted-firmware.git
git clone https://github.com/rockchip-linux/rkbin.git
git clone https://github.com/rockchip-linux/rkdeveloptool.git
git clone https://github.com/u-boot/u-boot.git

# Compile the ATF
cd arm-trusted-firmware
make realclean
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3399 bl31
cp bl31.elf ../u-boot/

# Compile U-Boot
cd ../u-boot
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make evb-rk3399_defconfig
make
make u-boot.itb

# The resulting images will be in the spl/ and . directories respectively.
