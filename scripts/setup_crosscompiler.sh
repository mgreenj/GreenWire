#!/bin/bash

# Define ANSI color codes
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
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

wget -q https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-libc-dev_6.14.0-22.22_amd64.deb
wget -q https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-17_6.14.0-17.17_all.deb
wget -q https://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-6.14.0-22-generic_6.14.0-22.22_amd64.deb
wget -q http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6-dev_2.39-0ubuntu8_amd64.deb
wget -q http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-14/libgcc-14-dev_14.3.0-1ubuntu1_amd64.deb

ar x linux-libc-dev_*.deb && tar -xf data.tar.*
ar x linux-headers-6.14.0-17_*.deb && tar -xf data.tar.*
ar x linux-headers-6.14.0-22-generic_*.deb && tar -xf data.tar.*
ar x libc6-dev_*.deb && tar -xf data.tar.*
ar x libgcc-14-dev_*.deb && tar -xf data.tar.*

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

echo -e "${MAGENTA}${BOLD}[+] Running make and make install for Binutils $BINUTILS_VER...${RESET}"
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

SDKROOT=$(xcrun --sdk macosx --show-sdk-path)

../../src/gcc-$GCC_VER/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --without-headers \
    --with-newlib \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --disable-multilib \
    --disable-bootstrap \
    --disable-libsanitizer \
    --enable-languages=c \
    --with-system-zlib


echo -e "${MAGENTA}${BOLD}[+] Running make all-gcc for GCC $GCC_VER...${RESET}"
if ! make all-gcc -j$(sysctl -n hw.ncpu) > build.log 2>&1; then
    echo -e "${RED}${BOLD}[!] Bootstrap GCC build failed. See build.log for details.${RESET}"
    exit 1
fi

echo -e "${MAGENTA}${BOLD}[+] Running make install-gcc for GCC $GCC_VER...${RESET}"
if ! make install-gcc >> build.log 2>&1; then
    echo -e "${RED}${BOLD}[!] Bootstrap GCC install failed. See build.log for details.${RESET}"
    exit 1
fi

echo -e "${GREEN}${BOLD}[+] Configuring and building GCC (final with sysroot)...${RESET}"
cd $PROJECTROOT/build/gcc-final

export PATH="$PREFIX/bin:$PATH"
export CC="$PREFIX/bin/$TARGET-gcc"
export CXX="$PREFIX/bin/$TARGET-g++"
export AR="$PREFIX/bin/$TARGET-ar"
export AS="$PREFIX/bin/$TARGET-as"
export RANLIB="$PREFIX/bin/$TARGET-ranlib"
export LD="$PREFIX/bin/$TARGET-ld"
export STRIP="$PREFIX/bin/$TARGET-strip"
export NM="$PREFIX/bin/$TARGET-nm"
export CFLAGS_FOR_TARGET="--sysroot=$SYSROOT"
export CXXFLAGS_FOR_TARGET="--sysroot=$SYSROOT"
export LDFLAGS_FOR_TARGET="--sysroot=$SYSROOT"

echo -e "${BLUE}${BOLD}[+] Copying target files to correct location...${RESET}"
ln -sfn ../usr/lib/x86_64-linux-gnu $SYSROOT/lib/x86_64-linux-gnu

# echo -e "${YELLOW}${BOLD}[+] Debug: Testing where ld is looking...${RESET}"
# echo 'int main() { return 0; }' > $PROJECTROOT/test.c
# $PREFIX/bin/$TARGET-gcc -v -Wl,--verbose $PROJECTROOT/test.c -o $PROJECTROOT/test.out 2>&1 | tee $PROJECTROOT/linker_debug.log

# print env to terminal for troubleshooting
env 

echo -e "${BLUE}${BOLD}[+] Configuring gcc-final $GCC_VER...${RESET}"
../../src/gcc-$GCC_VER/configure \
  --target=$TARGET \
  --prefix=$PREFIX \
  --with-sysroot=$SYSROOT \
  --with-native-system-header-dir=/usr/include \
  --with-glibc-version=2.39 \
  --with-gxx-include-dir=/usr/include/c++/$GCC_VER \
  --with-multilib-list= \
  --enable-languages=c,c++ \
  --disable-nls \
  --disable-multilib \
  --disable-bootstrap \
  --disable-libsanitizer \
  --with-libdir=lib/x86_64-linux-gnu


echo -e "${MAGENTA}${BOLD}[+] Running make for GCC $GCC_VER...${RESET}"
if ! make -j$(sysctl -n hw.ncpu) V=1 > build.log 2>&1; then
    echo -e "${RED}${BOLD}[!] Final GCC build failed. See build.log for details.${RESET}"
    exit 1
fi

echo -e "${MAGENTA}${BOLD}[+] Running make install for GCC $GCC_VER...${RESET}"
if ! make install >> build.log 2>&1; then
    echo -e "${RED}${BOLD}[!] Final GCC install failed. See build.log for details.${RESET}"
    exit 1
fi

echo -e "${GREEN}${BOLD} Cross-compilation toolchain successfully built and installed to $PREFIX${RESET}"