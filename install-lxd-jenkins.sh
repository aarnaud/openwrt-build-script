#!/bin/bash

CONTAINER_NAME=jenkins

lxc info ${CONTAINER_NAME} &> /dev/null || {
    lxc launch images:ubuntu/xenial/amd64 ${CONTAINER_NAME}
    sleep 5 # Wait network DHCP
    lxc exec ${CONTAINER_NAME} -- bash << EOF
        apt-get update
        apt-get install -y apt-transport-https wget ca-certificates
        wget -O- https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
        echo 'deb http://pkg.jenkins-ci.org/debian binary/' > /etc/apt/sources.list.d/jenkins.list
        apt-get update
        # Add OpenWRT Prerequisites
        apt-get install -y git-core build-essential libssl-dev libncurses5-dev unzip gawk subversion mercurial
        # Add github-release
        wget https://github.com/aktau/github-release/releases/download/v0.6.2/linux-amd64-github-release.tar.bz2 -O- | tar -xjvf - bin/linux/amd64/github-release -C /usr/local/bin/ --strip 3
        # Install Jenkins
        apt-get install -y jenkins
        sleep 5
        wget -q http://127.0.0.1:8080
        initialAdminPassword=\$(cat /var/lib/jenkins/secrets/initialAdminPassword)
        echo "initialAdminPassword: \$initialAdminPassword"
EOF
}

lxc list ${CONTAINER_NAME} -c s | grep STOPPED &> /dev/null && lxc start ${CONTAINER_NAME}

#lxc exec ${CONTAINER_NAME} -- sudo -u ubuntu -i
