FROM ubuntu:24.04

RUN apt-get update &&\
    apt-get install -y \
        sudo ccache time git-core subversion build-essential clang bison gcc-multilib g++ g++-multilib bash make \
        libssl-dev patch libncurses6 libncurses-dev zlib1g-dev gawk \
        flex gettext wget unzip xz-utils python3-setuptools \
        python3 python3-distutils-extra rsync swig curl wget file libsnmp-dev liblzma-dev \
        libpam0g-dev cpio && \
    wget https://github.com/cli/cli/releases/download/v2.67.0/gh_2.67.0_linux_amd64.deb && \
    apt-get install -f ./gh_2.67.0_linux_amd64.deb && \
    apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

USER user
WORKDIR /home/user

# set dummy git config
RUN git config --global user.name "user" && git config --global user.email "user@example.com"
