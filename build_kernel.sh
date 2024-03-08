#! /bin/bash -e
run_dir=/home/niklas/kernel-build
repo_dir=$run_dir/pve-raspbian
root_dir=$run_dir/rootfs

# RootFS Ordner zurücksetzen
echo "\n============================ ! RootFS Directory reset ! ============================\n"

rm -r $root_dir
mkdir $root_dir

# zLib Compilieren
sleep 2
echo "\n============================ ! Build zLib ! ============================\n"

cd $repo_dir/zlib

git reset --hard

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
./configure \
--prefix=$root_dir/usr/local

make -s -j$(nproc)
make install

libtool --finish $root_dir/usr/local/lib

# LibTirPc Compilieren
sleep 2
echo "\n============================ ! Build libtirpc ! ============================\n"

cd $repo_dir/libtirpc

git reset --hard

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
./configure \
--host=aarch64-linux-gnu \
--prefix=$root_dir/usr \
--disable-gssapi \
--disable-static

make -s -j$(nproc)
make install

libtool --finish $root_dir/usr/lib

# Linux Utils Libs Compilieren
sleep 2
echo "\n============================ ! Build linux-utils ! ============================\n"

cd $repo_dir/util-linux

git reset --hard

./autogen.sh

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
./configure \
--host=aarch64-linxu-gnu \
--prefix=$root_dir/usr \
--disable-all-programs \
--enable-lib=yes \
--enable-libuuid=yes \
--enable-libblkid=yes \

make -s -j$(nproc)
make install

libtool --finish $root_dir/usr/lib

# openSSL Complilieren
sleep 2
echo "\n============================ ! Build openSSL ! ============================\n"

cd $repo_dir/openssl

git reset --hard

./Configure \
--cross-compile-prefix=aarch64-linux-gnu- \
--openssldir=$root_dir/usr/local/ssl \
--prefix=$root_dir/usr/local \
--with-zlib-include=$root_dir/usr/local/include \
--with-zlib-lib=$root_dir/usr/local/lib \
zlib-dynamic linux-aarch64

make -s -j$(nproc)
make install

# curl Complilieren
sleep 2
#echo "\n============================ ! Build curl ! ============================\n"

cd $repo_dir/curl

git reset --hard

autoreconf -fi

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
CPPFLAGS="-I$root_dir/usr/local/include" \
LDFLAGS="-L$root_dir/usr/local/lib" \
./configure \
--host=aarch64-linux-gnu \
--prefix=$root_dir/usr/local \
--without-libpsl

make -s -j$(nproc)
make install

# Prepare Raspberry-Linux
sleep 2
echo "\n============================ ! Prepare Raspberry-Linux ! ============================\n"

cd $repo_dir/raspberry-pve-linux

git reset --hard

KERNEL=kernel8

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
make -s -j$(nproc) bcm2711_defconfig

sleep 1

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
make menuconfig

sleep 1

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
make prepare scripts

# Build zfs
sleep 2
echo "\n============================ ! Build ZFS ! ============================\n"

cd $repo_dir/zfs

git reset --hard

./autogen.sh

ARCH=arm64 \
CROSS_COMPILE=aarch64-linux-gnu- \
CC=aarch64-linux-gnu-gcc \
ZLIB_CFLAGS="-I$root_dir/usr/local/include/ -L$root_dir/usr/local/lib/" \
LIBUUID_CFLAGS="-I$root_dir/usr/include/ -L$root_dir/usr/lib/" \
LIBBLKID_CFLAGS="-I$root_dir/usr/include/ -L$root_dir/usr/lib/" \
LIBCRYPTO_CFLAGS="-I$root_dir/usr/local/include/ -L$root_dir/usr/local/lib/" \
LIBTIRPC_CFLAGS="-I$root_dir/usr/include/tirpc/ -L$root_dir/usr/lib/" \
./configure \
--host=aarch64-linux-gnu \
--enable-linux-builtin \
--with-linux=$repo_dir/raspberry-pve-linux \
--with-linux-obj=$repo_dir/raspberry-pve-linux

make -s -j$(nproc)

# Build raspberry-pve-linux
sleep 2
echo "\n============================ ! Build Raspberry-Linux ! ============================\n"

#ARCH=arm64 \
#CROSS_COMPILE=aarch64-linux-gnu- \
#CC=aarch64-linux-gnu-gcc \
#make menuconfig -j$(nproc)

#ARCH=arm64 \
#CROSS_COMPILE=aarch64-linux-gnu- \
#CC=aarch64-linux-gnu-gcc \
#make deb-pkg -j$(nproc)
