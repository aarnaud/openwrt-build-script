#!/bin/bash
set -e
set -x

TARGET=$1
OPENWRT_VERSION="v19.07.8"


SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=${SCRIPTS_DIR}/..
cd ${ROOT_DIR}

export CONFIG_CCACHE=y
export CCACHE_DIR=/mnt/ccache
export CCACHE_MAXSIZE=10G

# Install all necessary packages
#sudo apt-get install build-essential subversion libncurses5-dev zlib1g-dev gawk gcc-multilib flex git-core libssl-dev unzip python wget time

if [[ ! -d openwrt/.git ]]
then
    rm -rf openwrt
    git clone https://github.com/openwrt/openwrt.git openwrt
fi

cd ${ROOT_DIR}/openwrt
git fetch -a

git reset --hard HEAD^
git checkout -f ${OPENWRT_VERSION}

./scripts/feeds update -a
./scripts/feeds install -a

# Patch kernel config to enable nf_conntrack_events
patch ${ROOT_DIR}/openwrt/target/linux/generic/config-4.14 < ${ROOT_DIR}/configs/kernel-config.patch

rm -rf ${ROOT_DIR}/openwrt/files
cp -r ${ROOT_DIR}/root_files ${ROOT_DIR}/openwrt/files
chmod 755 ${ROOT_DIR}/openwrt/files/etc/dropbear

cp ${ROOT_DIR}/configs/${TARGET}.config ${ROOT_DIR}/openwrt/.config
make defconfig

if [[ "${CLEAN_BUILD}" == "true" || "${CONFIG_CCACHE}" == "y" ]]
then
    make clean
fi

make -j$(nproc) || make V=s # Retry with full log if failed

