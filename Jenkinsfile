node {
   // Mark the code checkout 'stage'....
   stage 'Checkout'

   // Get some code from a GitHub repository
   checkout scm

   // Mark the code build 'stage'....
   stage 'Build'
   // Run build script
   sh './build.sh'
   
   def UPLOAD_FILE = 'openwrt/bin/sunxi/openwrt-sunxi-Lamobo_R1-sdcard-vfat-ext4.img.gz'
   
   //Upload artifact
   stage 'Publish artifact'
   archive "${UPLOAD_FILE}"
   
   //Upload on github if tag
   def GIT_TAG = ['git', 'tag', '--contains', env.GIT_COMMIT].execute().text
   if(GIT_TAG?.trim()){
       stage 'Publish github release'
       sh "github-release release -u aarnaud -r banana-pi-r1-build-script -t ${GIT_TAG}"
       sh "github-release upload -u aarnaud -r banana-pi-r1-build-script -t ${GIT_TAG} -n openwrt-sunxi-Lamobo_R1-sdcard-vfat-ext4.img.gz -f ${UPLOAD_FILE}"
   }
}