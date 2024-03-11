#! /bin/bash -e
work_dir=$(pwd)

# Prepare Raspberry-Linux
echo "\n============================ ! Prepare System APT ! ============================\n"

sudo apt install git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64 -y
sudo apt install curl:arm64 zlib1g-dev:arm64 libblkid-dev:arm64 uuid-dev:arm64 libtirpc-dev:arm64 libudev-dev:arm64 libcrypt-dev:arm64 libssl-dev:arm64 libaio-dev:arm64 libattr1-dev:arm64 libelf-dev:arm64 libffi-dev:arm64 libcurl4-openssl-dev:arm64 libtool-bin -y
sudo apt install build-essential autoconf automake libtool gawk alien fakeroot dkms libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev linux-headers-generic python3 python3-dev python3-setuptools python3-cffi libffi-dev python3-packaging git libcurl4-openssl-dev debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx parallel -y

# Prepare Raspberry-Linux
sleep 10
echo "\n============================ ! Prepare Raspberry-Linux ! ============================\n"

cd $work_dir/linux

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

cd $work_dir/zfs

git reset --hard

./autogen.sh

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
./configure \
--build=x86_64-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu \
--enable-linux-builtin \
--with-linux=$work_dir/linux \
--with-linux-obj=$work_dir/linux

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

