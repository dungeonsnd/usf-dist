#!/bin/bash
#  Builds libevent for all three current iPhone targets: iPhoneSimulator-i386,
#  iPhoneOS-armv6, iPhoneOS-armv7.
#
#  Copyright 2013 sosoayaen <sosoayaen@gmail.com>
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################

# 当前最新版编译失败，报 editline 没找到类似错误。 暂时还是用老版本来编译。
#VERSION="3110000"
#DOWNLOADURL="http://sqlite.org/2016/sqlite-autoconf-${VERSION}.tar.gz"


VERSION="3080002"
DOWNLOADURL="http://sqlite.org/2013/sqlite-autoconf-${VERSION}.tar.gz"

SDKVERSION=`xcrun --sdk iphoneos --show-sdk-version`
MINIOSVERSION="6.0"
#
#
###########################################################################
#
# Don't change anything under this line!
#
###########################################################################

# No need to change this since xcode build will only compile in the
# necessary bits from the libraries we create
ARCHS="armv7 armv7s arm64 i386 x86_64"

DEVELOPER=`xcode-select -print-path`

cd "`dirname \"$0\"`"
REPOROOT=$(pwd)

# Where we'll end up storing things in the end
OUTPUTDIR="${REPOROOT}/dependencies"
mkdir -p ${OUTPUTDIR}/include
mkdir -p ${OUTPUTDIR}/lib


BUILDDIR="${REPOROOT}/build"

# where we will keep our sources and build from.
SRCDIR="${BUILDDIR}/src"
mkdir -p $SRCDIR
# where we will store intermediary builds
INTERDIR="${BUILDDIR}/built"
mkdir -p $INTERDIR


cd $SRCDIR
set -e

if [ ! -e "${SRCDIR}/sqlite-autoconf-${VERSION}.tar.gz" ]; then
	echo "Downloading sqlite-autoconf-${VERSION}.tar.gz"
	curl -LO $DOWNLOADURL
    tar zxvf sqlite-autoconf-${VERSION}.tar.gz -C $SRCDIR
else
	echo "Using sqlite-autoconf-${VERSION}.tar.gz"
fi

cd "${SRCDIR}/sqlite-autoconf-${VERSION}"

set +e
CCACHE=`which ccache`
if [ $? == "0" ]; then
	echo "Building with cache: $CCACHE"
	CCACHE="${CCACHE} "
else
	echo "Building without ccache"
	CCACHE=""
fi
set -e

export ORIGINALPATH=$PATH
for ARCH in ${ARCHS}
do
    if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
    then
        PLATFORM="iPhoneSimulator"
        EXTRA_CONFIG=""
    else
        PLATFORM="iPhoneOS"
        EXTRA_CONFIG="--host=arm-apple-darwin14"
    fi
    mkdir -p "${INTERDIR}/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

    export PATH="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/:${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/:${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin:${DEVELOPER}/usr/bin:${ORIGINALPATH}"
    export CC="${CCACHE}`which gcc` -arch ${ARCH} -miphoneos-version-min=${MINIOSVERSION}"

    ./configure --disable-shared --enable-static --disable-debug-mode ${EXTRA_CONFIG} \
    --prefix="${INTERDIR}/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" \
    LDFLAGS="$LDFLAGS -L${OUTPUTDIR}/lib" \
    CFLAGS="$CFLAGS -O2 -I${OUTPUTDIR}/include -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk  -fembed-bitcode" \
    CPPFLAGS="$CPPFLAGS -I${OUTPUTDIR}/include -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"
    # Build the application and install it to the fake SDK intermediary dir
    # we have set up. Make sure to clean up afterward because we will re-use
    # this source tree to cross-compile other targets.
    make -j4
    make install
    make clean
done

########################################

echo "Build library..."

# These are the libs that comprise sqlite3.
# may not be compiled if those dependencies aren't available.
OUTPUT_LIBS="libsqlite3.a"
for OUTPUT_LIB in ${OUTPUT_LIBS}; do
    INPUT_LIBS=""
    for ARCH in ${ARCHS}; do
        if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
        then
            PLATFORM="iPhoneSimulator"
        else
            PLATFORM="iPhoneOS"
        fi
        INPUT_ARCH_LIB="${INTERDIR}/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/lib/${OUTPUT_LIB}"
        if [ -e $INPUT_ARCH_LIB ]; then
            INPUT_LIBS="${INPUT_LIBS} ${INPUT_ARCH_LIB}"
        fi
    done
    # Combine the three architectures into a universal library.
    if [ -n "$INPUT_LIBS"  ]; then
        lipo -create $INPUT_LIBS \
        -output "${OUTPUTDIR}/lib/${OUTPUT_LIB}"
    else
        echo "$OUTPUT_LIB does not exist, skipping (are the dependencies installed?)"
    fi
done

for ARCH in ${ARCHS}; do
    if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
    then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi
    cp -R ${INTERDIR}/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/include/* ${OUTPUTDIR}/include/
    if [ $? == "0" ]; then
        # We only need to copy the headers over once. (So break out of forloop
        # once we get first success.)
        break
    fi
done


####################

echo "Building done."
echo "Cleaning up..."
rm -fr ${INTERDIR}
rm -fr "${SRCDIR}/sqlite-autoconf-${VERSION}"
echo "Done."
