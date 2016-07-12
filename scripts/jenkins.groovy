#!/usr/bin/env groovy

// Mark the code checkout 'stage'....
stage 'Checkout'
// Get some code from a GitHub repository
checkout scm

// Mark the code build 'stage'....
stage 'Build'
// Run build script
sh "./build.sh ${TARGET}"

//Upload artifact
stage 'Publish artifact'
archive "${UPLOAD_FILE}"

//Upload on github if tag
sh "git tag --contains `git rev-parse HEAD` > .git-tag"
def GIT_TAG = readFile('.git-tag').trim()
sh "rm .git-tag"
if (GIT_TAG) {
    stage 'Publish github release'
    withCredentials([[$class: 'StringBinding', credentialsId: 'GithubToken', variable: 'GITHUB_TOKEN']]) {
        sh "github-release release -u aarnaud -r openwrt-build-script -t ${GIT_TAG}"
        sh "github-release upload -u aarnaud -r openwrt-build-script -t ${GIT_TAG} -n ${ARCHIVE_NAME} -f ${UPLOAD_FILE}"
    }
}