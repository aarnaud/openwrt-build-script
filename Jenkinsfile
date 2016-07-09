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
   sh "git tag --contains `git rev-parse HEAD` > .git-tag"
   def GIT_TAG = readFile('.git-tag').trim()
   sh "rm .git-tag"
   if(GIT_TAG?.trim()){
       stage 'Publish github release'
       withCredentials([[$class: 'StringBinding', credentialsId: 'GithubToken', variable: 'GITHUB_TOKEN']]) {
           sh "github-release release -s ${GITHUB_TOKEN} -u aarnaud -r banana-pi-r1-build-script -t ${GIT_TAG}"
           sh "github-release upload -s ${GITHUB_TOKEN} -u aarnaud -r banana-pi-r1-build-script -t ${GIT_TAG} -n openwrt-sunxi-Lamobo_R1-sdcard-vfat-ext4.img.gz -f ${UPLOAD_FILE}"
       }
   }
}