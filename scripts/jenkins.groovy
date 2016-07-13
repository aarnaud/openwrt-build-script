#!/usr/bin/env groovy

// Mark the code build 'stage'....
stage 'Build'
// Run build script
sh "./scripts/build.sh ${env.TARGET}"

//Upload artifact
stage 'Publish artifact'
def UPLOAD_FILE = "../${env.UPLOAD_FILE}"
archive "${UPLOAD_FILE}"

//Upload on github if tag
sh "git tag --contains `git rev-parse HEAD` > .git-tag"
def GIT_TAG = readFile('.git-tag').trim()
sh "rm .git-tag"
if (GIT_TAG) {
    stage 'Publish github release'
    withCredentials([[$class: 'StringBinding', credentialsId: 'GithubToken', variable: 'GITHUB_TOKEN']]) {
        sh "github-release release -u aarnaud -r openwrt-build-script -t ${GIT_TAG}"
        sh "github-release upload -u aarnaud -r openwrt-build-script -t ${GIT_TAG} -n ${env.ARCHIVE_NAME} -f ${UPLOAD_FILE}"
    }
}