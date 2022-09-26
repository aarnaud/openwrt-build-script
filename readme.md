# OpenWRT build script

## Jenkins build

You can download [here](https://github.com/aarnaud/openwrt-build-script/releases)

## Build script

````
./scripts/build.sh sunxi_Lamobo_R1
````

## Build manually

````
cd openwrt
make menuconfig
make defconfig
make V=s
````

## Write your SD card

````
gzip -k -d openwrt/bin/sunxi/openwrt-sunxi-Lamobo_R1-sdcard-vfat-ext4.img.gz
dd if=openwrt/bin/sunxi/openwrt-sunxi-Lamobo_R1-sdcard-vfat-ext4.img of=/dev/YOURSDCARD
````

## Cleaning Up (in openwrt directory)

### Clean

````
make clean
````

deletes contents of the directories /bin and /build_dir. make clean does not remove the toolchain, it also avoids cleaning architectures/targets other than the one you have selected in your .config


### Dirclean

````
make dirclean
````

deletes contents of the directories /bin and /build_dir and additionally /staging_dir and /toolchain (=the cross-compile tools) and /logs. 'Dirclean' is your basic "Full clean" operation.

### Distclean

````
make distclean
````

nukes everything you have compiled or configured and also deletes all downloaded feeds contents and package sources.

*CAUTION* : In addition to all else, this will erase your build configuration (<buildroot_dir>/.config), your toolchain and all other sources. Use with care!
