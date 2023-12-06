#!/bin/bash
set -e
set -x

TARGET=$1
OPENWRT_VERSION="v22.03.4"


SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=${SCRIPTS_DIR}/..
OPENWRT_DIR="${OPENWRT_DIR:-default ${ROOT_DIR}/openwrt}"
cd ${ROOT_DIR}

if [[ "${TARGET}" != "lamobo_R1" ]]
then
  # issue on lamobo_R1
  # ERROR: package/network/services/ppp failed to build (build variant: default)
  export CONFIG_CCACHE=y
  export CCACHE_DIR=${CCACHE_DIR:-default /mnt/ccache}
  export CCACHE_MAXSIZE=10G
  export CCACHE_COMPILERCHECK="%compiler% -dumpmachine; %compiler% -dumpversion"
  mkdir -p ${CCACHE_DIR}
else
  export CLEAN_BUILD=true
fi
# Install all necessary packages
#sudo apt-get install build-essential subversion libncurses5-dev zlib1g-dev gawk gcc-multilib flex git-core libssl-dev unzip python wget time

if [[ ! -d ${OPENWRT_DIR}/.git ]]
then
    rm -rf ${OPENWRT_DIR}
    git clone https://github.com/openwrt/openwrt.git ${OPENWRT_DIR}
fi

cd ${OPENWRT_DIR}
git fetch -a

git reset --hard HEAD^
git checkout -f ${OPENWRT_VERSION}

# Patch kernel config to enable nf_conntrack_events
patch ${OPENWRT_DIR}/target/linux/generic/config-5.10 < ${ROOT_DIR}/configs/kernel-config.patch

rm -rf ${OPENWRT_DIR}/files
cp -r ${ROOT_DIR}/root_files ${OPENWRT_DIR}/files
chmod 755 ${OPENWRT_DIR}/files/etc/dropbear

cp ${ROOT_DIR}/configs/${TARGET}.config ${OPENWRT_DIR}/.config
make defconfig

./scripts/feeds update -a -f
./scripts/feeds install -a -f

if [[ "${CLEAN_BUILD}" == "true" || "${CONFIG_CCACHE}" == "y" ]]
then
    make clean
fi

#  If you try compiling OpenWrt on multiple cores and don't download all source files for all dependency packages
#  it is very likely that your build will fail.
# https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem#download_sources_and_multi_core_compile
make download

make -j$(nproc) || make V=s # Retry with full log if failed

