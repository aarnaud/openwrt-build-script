#!/bin/bash
set -e
set -x

OPENWRT_VERSION="chaos_calmer"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

# Install all necessary packages
#sudo apt-get install build-essential subversion libncurses5-dev zlib1g-dev gawk gcc-multilib flex git-core libssl-dev unzip

if [[ ! -d openwrt/.git ]]
then
    rm -rf openwrt
    git clone https://github.com/openwrt/openwrt.git openwrt
fi

cd ${DIR}/openwrt
git fetch -a

git reset --hard HEAD^
git checkout -f ${OPENWRT_VERSION}

./scripts/feeds update -a
./scripts/feeds install -a

cp -r ${DIR}/root_files ${DIR}/openwrt/files

cp ${DIR}/diffconfig ${DIR}/openwrt/.config
make defconfig

make clean

make -j$(nproc) || make V=s # Retry with full log if failed

