FROM ubuntu:26.04

RUN apt-get update &&\
    apt-get install -y \
        sudo ccache time git-core subversion build-essential clang bison gcc-multilib bzip2 g++ g++-multilib glibc-source bash make \
        libssl-dev patch libncurses6 libncurses-dev zlib1g-dev gawk \
        flex gettext wget unzip xz-utils python3-setuptools \
        python3 python3-dev python3-distutils-extra rsync swig curl wget file libsnmp-dev liblzma-dev \
        libpam0g-dev cpio && \
    wget https://github.com/cli/cli/releases/download/v2.96.0/gh_2.96.0_linux_amd64.deb && \
    apt-get install -f ./gh_2.96.0_linux_amd64.deb && \
    apt-get clean && \
    useradd -m user && \
    echo 'ubuntu ALL=NOPASSWD: ALL' > /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# set dummy git config
RUN git config --global user.name builder && git config --global user.email builder@openwrt.local
