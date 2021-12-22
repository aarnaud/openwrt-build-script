#!/usr/bin/env groovy

def build(TARGET) {
    // Mark the code build 'stage'....
    stage('Build') {
      def builder = docker.build("openwrt:${env.BUILD_ID}", ".")
      builder.inside("-v ${HOME}/.ccache:/mnt/ccache") {
        // Run build script
        sh "./scripts/build.sh ${TARGET}"
      }
    }
}

def publishArtifact(UPLOAD_FILE) {
    //Upload artifact
    stage('Publish artifact') {
      archiveArtifacts artifacts: "${UPLOAD_FILE}"
    }
}

def githubRelease(UPLOAD_FILE, ARCHIVE_NAME) {
    //Upload on github if tag
    sh "git tag --contains `git rev-parse HEAD` > .git-tag"
    def GIT_TAG = readFile('.git-tag').trim()
    sh "rm .git-tag"
    if (GIT_TAG) {
        stage('Publish github release') {
          withCredentials([[$class: 'StringBinding', credentialsId: 'GithubToken', variable: 'GITHUB_TOKEN']]) {
              sh "github-release info -u aarnaud -r openwrt-build-script -t ${GIT_TAG} || github-release release -u aarnaud -r openwrt-build-script -t ${GIT_TAG}"
              sh "github-release upload -u aarnaud -r openwrt-build-script -t ${GIT_TAG} -n ${ARCHIVE_NAME} -f ${UPLOAD_FILE}"
          }
        }
    }
}

this