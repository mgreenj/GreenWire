#!/bin/bash

# Define ANSI color codes
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
BOLD="\033[1m"
RESET="\033[0m"

set -e

echo -e "${GREEN}${BOLD}[+] Setting up environment variables...${RESET}"

# Environment setup
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

export PROJECTROOT="$HOME/Documents/Dev/GreenWire"
export PREFIX="$PROJECTROOT/tools"
export TARGET="x86_64-linux-gnu"
export SYSROOT="$PROJECTROOT/sysroot"
export PATH="$PREFIX/bin:$PATH"

echo -e "${GREEN}${BOLD}[+] Creating project build and cross-compile directories...${RESET}"
for dir in tools sysroot src build/binutils build/gcc-bootstrap build/gcc-final; do
    mkdir -p "$PROJECTROOT/$dir"
done

echo -e "${GREEN}${BOLD}[+] Moving into sysroot and extracting Linux headers and libc...${RESET}"
cd $SYSROOT
mkdir -p debs && cd debs

wget -q https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-libc-dev_6.14.0-22.22_amd64.deb
wget -q https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-17_6.14.0-17.17_all.deb
wget -q https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-22-generic_6.14.0-22.22_amd64.deb

ar x linux-libc-dev_*.deb && tar -xf data.tar.*
ar x linux-headers-6.14.0-17_*.deb && tar -xf data.tar.*
ar x linux-headers-6.14.0-22-generic_*.deb && tar -xf data.tar.*

cd $PROJECTROOT/src

echo -e "${GREEN}${BOLD}[+] Fetching and extracting Binutils 2.44...${RESET}"
BINUTILS_VER="2.44"
wget -q https://mirrors.ibiblio.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz
tar -xf binutils-$BINUTILS_VER.tar.xz

echo -e "${GREEN}${BOLD}[+] Configuring and building Binutils...${RESET}"
cd $PROJECTROOT/build/binutils

../../src/binutils-$BINUTILS_VER/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$SYSROOT \
    --disable-nls \
    --disable-werror \
    --with-system-zlib

make -j$(sysctl -n hw.ncpu) V=1 > build.log 2>&1
make install

echo -e "${GREEN}${BOLD}[+] Fetching and extracting GCC 15.1.0...${RESET}"
cd $PROJECTROOT/src
GCC_VER="15.1.0"
wget -q https://mirrors.ibiblio.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz
tar -xf gcc-$GCC_VER.tar.xz

cd gcc-$GCC_VER
./contrib/download_prerequisites

echo -e "${GREEN}${BOLD}[+] Configuring and building GCC (bootstrap)...${RESET}"
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

echo -e "${GREEN}${BOLD}[+] Configuring and building GCC (final with sysroot)...${RESET}"
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

echo -e "${GREEN}${BOLD}✅ Cross-compilation toolchain successfully built and installed to $PREFIX${RESET}"