#!/usr/bin/env groovy

import org.apache.commons.io.FilenameUtils

Map ARCHIVES_PATH = [
    "lamobo_R1": "openwrt/bin/targets/sunxi/cortexa7/openwrt-sunxi-cortexa7-lamobo_lamobo-r1-ext4-sdcard.img.gz",
    "linksys-wrt1200ac": "openwrt/bin/targets/mvebu/cortexa9/openwrt-mvebu-cortexa9-linksys_wrt1200ac-squashfs-sysupgrade.bin",
    "linksys-wrt1900ac": "openwrt/bin/targets/mvebu/cortexa9/openwrt-mvebu-cortexa9-linksys_wrt1900ac-v1-squashfs-sysupgrade.bin",
    "ubnt-erx": "openwrt/bin/targets/ramips/mt7621/openwrt-ramips-mt7621-ubnt_edgerouter-x-squashfs-sysupgrade.bin",
    "gl-mt1300": "openwrt/bin/targets/ramips/mt7621/openwrt-ramips-mt7621-glinet_gl-mt1300-squashfs-sysupgrade.bin",
    "unifiac": "openwrt/bin/targets/ath79/generic/openwrt-ath79-generic-ubnt_unifiac-pro-squashfs-sysupgrade.bin",
    "x86": "openwrt/bin/targets/x86/64/openwrt-x86-64-generic-ext4-combined-efi.img.gz"
]

String target_choices = (ARCHIVES_PATH.keySet() as String[]).join(',')

properties([
    parameters([
        booleanParam(name: 'CLEAN_BUILD', defaultValue: true, description: 'deletes contents of the directories /bin and /build_dir.'),
        extendedChoice(defaultValue: "${target_choices}", description: 'Which target to build', multiSelectDelimiter: ',', name: 'TARGETS', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_MULTI_SELECT', value: "${target_choices}", visibleItemCount: 6),
    ])
])

String[] TARGETS =  params.TARGETS.split(',')

// parallel task map
Map tasks = [failFast: false]

TARGETS.each { target ->
    tasks[target] = { ->
        node {
            def UPLOAD_FILE = ARCHIVES_PATH[target]
            def ARCHIVE_NAME = FilenameUtils.getBaseName(UPLOAD_FILE)
            ws("${WORKSPACE}/../openwrt-build-script") {
                stage('Checkout') {
                    // Get some code from a GitHub repository
                    checkout scm
                }
                // Mark the code checkout 'stage'....
                tools = load "scripts/jenkins.groovy"
                tools.build(target)
                tools.publishArtifact(UPLOAD_FILE)
                tools.githubRelease(UPLOAD_FILE, ARCHIVE_NAME)
            }
        }
    }
}


stage("Parallel builds") {
    parallel(tasks)
}