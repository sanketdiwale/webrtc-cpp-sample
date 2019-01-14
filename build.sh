#!/bin/bash

set -eu

readonly ROOT_PATH=$(cd $(dirname $0) && pwd)

# Get OS environment parameters.
if [ "$(uname -s)" = 'Darwin' ]; then
    # Mac OSX
    readonly ID='macos'
    readonly ARCH='x86_64'
    readonly IS_LINUX='false'

elif [ -e /etc/os-release ]; then
    . /etc/os-release
    readonly ARCH=`uname -p`
    readonly IS_LINUX='true'

else
    echo "Thank you for useing. But sorry, this platform is not supported yet."
    exit 1
fi

# Download libwebrtc
readonly LOCAL_ENV_PATH=${ROOT_PATH}/local
readonly WEBRTC_VER=71

mkdir -p ${LOCAL_ENV_PATH}/include
mkdir -p ${LOCAL_ENV_PATH}/src
cd ${LOCAL_ENV_PATH}/src

if [ "${ID}" = 'macos' ]; then
    readonly WEBRTC_FILE="libwebrtc-osx-${WEBRTC_VER}.zip"
else
    readonly WEBRTC_FILE="libwebrtc-ubuntu-16.04-x86_64-${WEBRTC_VER}.tar.gz"
fi

if ! [ -e "${WEBRTC_FILE}" ]; then
    if [ "${ID}" = 'macos' ]; then
	curl -OL https://github.com/llamerada-jp/libwebrtc/releases/download/v${WEBRTC_VER}/${WEBRTC_FILE}
	cd ${LOCAL_ENV_PATH}
	unzip -o src/${WEBRTC_FILE}
    else
	wget https://github.com/llamerada-jp/libwebrtc/releases/download/v${WEBRTC_VER}/${WEBRTC_FILE}
	cd ${LOCAL_ENV_PATH}
	tar zxf src/${WEBRTC_FILE}
    fi
fi

# Build
readonly BUILD_PATH=${ROOT_PATH}/build
mkdir -p ${BUILD_PATH}

cd ${ROOT_PATH}
git submodule init
git submodule update

cd ${BUILD_PATH}
cmake -DLIBWEBRTC_PATH=${LOCAL_ENV_PATH} ..
make
cp sample ${ROOT_PATH}
