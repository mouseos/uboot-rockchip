#!/bin/bash
# Install toolchains
sudo apt install device-tree-compiler gcc-arm-none-eabi curl python2 gcc-aarch64-linux-gnu libusb-1.0-0 libusb-1.0-0-dev
#Change default python and pip version to python2
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip2 1
#Install pip2
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
pip install pyelftools
# Create a directory to work in
mkdir ~/evb_rk3399
cd ~/evb_rk3399

# Clone the necessary repositories
git clone https://github.com/ARM-software/arm-trusted-firmware.git
git clone https://github.com/rockchip-linux/rkbin.git
git clone https://github.com/rockchip-linux/rkdeveloptool.git
git clone https://github.com/rockchip-linux/u-boot.git

# Compile the ATF
cd arm-trusted-firmware
make realclean
make CROSS_COMPILE=aarch64-linux-gnu- PLAT=rk3399 bl31
cp ~/evb_rk3399/arm-trusted-firmware/build/rk3399/release/bl31/bl31.elf ~/evb_rk3399/u-boot/

# Compile U-Boot
cd ../u-boot
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
sed -i 's/-Werror//' Makefile
make evb-rk3399_defconfig
make
make u-boot.itb

# Compile the rkdeveloptool
cd ../rkdeveloptool
autoreconf -i
./configure
make
sudo make install

# Package the image for Rockchip miniloader
cd ..
cp arm-trusted-firmware/build/rk3399/release/bl31/bl31.elf rkbin/rk33
./rkbin/tools/trust_merger rkbin/RKTRUST/RK3399TRUST.ini
./rkbin/tools/loaderimage --pack --uboot u-boot/u-boot-dtb.bin uboot.img
