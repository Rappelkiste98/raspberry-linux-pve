#! /bin/bash -e
run_dir=/home/quenter/build-pve

# Prepare Raspberry-Linux
sleep 5
echo "\n============================ ! Prepare Raspberry-Linux ! ============================\n"

cd $repo_dir/raspberry-pve-linux

git reset --hard

KERNEL=kernel8

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
make -s -j$(nproc) bcm2711_defconfig

sleep 2

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
make menuconfig

sleep 2

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
make prepare scripts -j$(nproc)

# Build zfs
sleep 5
echo "\n============================ ! Build ZFS ! ============================\n"

cd ./zfs

git reset --hard

./autogen.sh

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
./configure \
--build=x86_64-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu \
--enable-linux-builtin \
--with-linux=$repo_dir/raspberry-pve-linux \
--with-linux-obj=$repo_dir/raspberry-pve-linux

make -s -j$(nproc)

# Build raspberry-pve-linux
sleep 5
echo "\n============================ ! Build Raspberry-Linux ! ============================\n"

#ARCH=arm64 \
#CROSS_COMPILE=aarch64-linux-gnu- \
#CC=aarch64-linux-gnu-gcc \
#make menuconfig -j$(nproc)

#ARCH=arm64 \
#CROSS_COMPILE=aarch64-linux-gnu- \
#CC=aarch64-linux-gnu-gcc \
#make deb-pkg -j$(nproc)

