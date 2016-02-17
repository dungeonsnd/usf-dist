#!/bin/bash
#export NDK=YOUR_NDK_PATH/android-ndk-r10e
export SYSROOT=$NDK/platforms/android-15/arch-arm/

export TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/

export PATH=$PATH:$TOOLCHAIN/bin

export CC="arm-linux-androideabi-gcc --sysroot $SYSROOT"
export CXX="arm-linux-androideabi-g++ --sysroot $SYSROOT"
export CXXSTL=$NDK/sources/cxx-stl/gnu-libstdc++/4.8

function build_one
{
    mkdir build

    ./configure --prefix=$(pwd)/build \
    --host=arm-linux-androideabi \
    --with-sysroot=$SYSROOT \
    --enable-static \
    --disable-shared \
    --enable-cross-compile \
    --with-protoc=protoc LIBS="-lc" \
    CFLAGS="-march=armv7-a" \
    CXXFLAGS="-march=armv7-a -I$CXXSTL/include -I$CXXSTL/libs/armeabi-v7a/include -L$CXXSTL/libs/armeabi-v7a/ -lgnustl_static"

    make clean
    make
    make install
}

CPU=arm
PREFIX=$(pwd)/android/$CPU
ADDI_CFLAGS="-marm"
build_one

# Inspect the library architecture specific information
# arm-linux-androideabi-readelf -A build/lib/libprotobuf-lite.a
