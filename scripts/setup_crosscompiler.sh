#!/bin/bash

set -e

# Setup environment variables
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

export LDFLAGS="-L/opt/homebrew/opt/zlib/lib"
export CPPFLAGS="-I/opt/homebrew/opt/zlib/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig"

export PROJECTROOT="$HOME/Documents/Dev/GreenWire"
export PREFIX="$PROJECTROOT/tools"
export TARGET="x86_64-linux-gnu"
export SYSROOT="$PROJECTROOT/sysroot"
export PATH="$PREFIX/bin:$PATH"

mkdir -p $PROJECTROOT/{
  tools,
  sysroot,
  src,
  build/binutils,
  build/gcc-bootstrap,
  build/gcc-final
}

cd $PROJECTROOT/src

# Download and extract binutils
BINUTILS_VER="2.44"
wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz
tar -xf binutils-$BINUTILS_VER.tar.xz

cd ../build/binutils
../../src/binutils-$BINUTILS_VER/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$SYSROOT \
    --disable-nls \
    --disable-werror
make -j$(sysctl -n hw.ncpu)
make install

# Download and extract GCC
cd $PROJECTROOT/src
GCC_VER="15.1.0"
wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz
tar -xf gcc-$GCC_VER.tar.xz
cd gcc-$GCC_VER
./contrib/download_prerequisites

cd $PROJECTROOT/build/gcc-bootstrap
../../src/gcc-$GCC_VER/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --without-headers \
    --with-newlib \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --disable-multilib \
    --enable-languages=c
make all-gcc -j$(sysctl -n hw.ncpu)
make install-gcc

cd $SYSROOT
UBUNTU_VER="noble"
mkdir -p debs
cd debs

wget https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-libc-dev_6.14.0-22.22_amd64.deb
wget https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-17_6.14.0-17.17_all.deb
wget https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-22-generic_6.14.0-22.22_amd64.deb

# Extract
ar x linux-libc-dev_*.deb && tar -xf data.tar.*
ar x linux-headers-6.14.0-22_*.deb && tar -xf data.tar.*
ar x linux-headers-6.14.0-22-generic_*.deb && tar -xf data.tar.*

# Final GCC with glibc headers
cd $PROJECTROOT/build/gcc-final
../../src/gcc-$GCC_VER/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$SYSROOT \
    --enable-languages=c,c++ \
    --disable-nls \
    --disable-multilib
make -j$(sysctl -n hw.ncpu)
make install

echo "Cross-compilation toolchain successfully built and installed to $PREFIX"
