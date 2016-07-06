node {
   // Mark the code checkout 'stage'....
   stage 'Checkout'

   // Get some code from a GitHub repository
   checkout scm

   // Mark the code build 'stage'....
   stage 'Build'
   // Run build script
   sh "./build.sh"
   
   //Upload artifact
   stage 'Publish artifact'
   archive 'openwrt/bin/sunxi/openwrt-sunxi-Lamobo_R1-sdcard-vfat-ext4.img.gz'
   
}