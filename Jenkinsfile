#!/usr/bin/env groovy

def ARCHIVES_PATH = [
    "lamobo_R1": "openwrt/bin/targets/sunxi/cortexa7/openwrt-sunxi-cortexa7-sun7i-a20-lamobo-r1-ext4-sdcard.img.gz",
    "linksys-wrt1200ac": "openwrt/bin/targets/mvebu/cortexa9/openwrt-mvebu-cortexa9-linksys_wrt1200ac-squashfs-sysupgrade.bin",
    "linksys-wrt1900ac": "openwrt/bin/targets/mvebu/cortexa9/openwrt-mvebu-cortexa9-linksys_wrt1900ac-squashfs-sysupgrade.bin",
    "ubnt-erx": "openwrt/bin/targets/ramips/mt7621/openwrt-ramips-mt7621-ubnt-erx-squashfs-sysupgrade.bin",
    "unifiac": "openwrt/bin/targets/ath79/generic/openwrt-ath79-generic-ubnt_unifiac-pro-squashfs-sysupgrade.bin",
    "x86": "openwrt/bin/targets/x86/64/openwrt-x86-64-combined-ext4.img.gz"
]


pipeline {
    agent none
    parameters {
        booleanParam(name: 'CLEAN_BUILD', defaultValue: false, description: 'deletes contents of the directories /bin and /build_dir.')
    }
    stages {
        stage('BuildAndPublish') {
            matrix {
                agent any
                axes{
                    axis {
                        name 'TARGET'
                        values 'lamobo_R1', 'linksys-wrt1200ac', 'linksys-wrt1900ac', 'ubnt-erx', 'unifiac', 'x86'
                    }
                }
                stages {
                    stage('Build') {
                        environment {
                            CLEAN_BUILD  = "${params.CLEAN_BUILD}"
                        }
                        steps {
                            sh "./scripts/build.sh ${TARGET}"
                        }
                    }
                    stage('Publish artifact') {
                        steps {
                            archive "${ARCHIVES_PATH[TARGET]}"
                        }
                    }
                    stage('Publish github release') {
                        when {
                            buildingTag()
                        }
                        environment {
                            UPLOAD_FILE  = "${ARCHIVES_PATH[TARGET]}"
                            ARCHIVE_NAME = "${new File(UPLOAD_FILE).getName()}"
                        }
                        steps {
                            withCredentials([[$class: 'StringBinding', credentialsId: 'GithubToken', variable: 'GITHUB_TOKEN']]) {
                                sh "github-release info -u aarnaud -r openwrt-build-script -t ${TAG_NAME} || github-release release -u aarnaud -r openwrt-build-script -t ${TAG_NAME}"
                                sh "github-release upload -u aarnaud -r openwrt-build-script -t ${TAG_NAME} -n ${ARCHIVE_NAME} -f ${UPLOAD_FILE}"
                            }
                        }
                    }
                }
            }
        }
    }
}