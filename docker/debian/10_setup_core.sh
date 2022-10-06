#!/bin/bash

# Installs packages needed for compilation inside docker image.

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

# Update package repos
update_repo() {
    echo "**** Update apt database ****"
    sed -i '/^.*main/ s/$/ contrib non-free/' /etc/apt/sources.list
    echo

}

# Section cleanup to reduce duplicate code
section_cleanup() {
    apt-get clean autoclean -y
    apt-get autoremove -y
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
}

# Update locale
update_locale() {
    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install and configure locals ****"
        apt-get install -y --no-install-recommends \
            locales
        echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
        locale-gen

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Re-install certificates
reinstall_cert() {
    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install certificates ****"
        apt-get install -y --reinstall \
            ca-certificates

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install core packages
install_core() {
    echo "**** Update apt database ****"
        apt-get update
    echo "**** Install tools ****"
        apt-get install -y --no-install-recommends \
            bash \
            bash-completion \
            curl \
            git \
            less \
            man-db \
            mlocate \
            nano \
            net-tools \
            patch \
            pciutils \
            pkg-config \
            procps \
            rsync \
            screen \
            sudo \
            unzip \
            vim \
            wget \
            xz-utils

    echo "**** Install python ****"
        apt-get install -y --no-install-recommends \
            python3 \
            python3-numpy \
            python3-pip \
            python3-setuptools

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install supervisor
install_supervisor() {
    echo "**** Update apt database ****"
        apt-get update
        
    echo "**** Install supervisor ****"
        apt-get install -y \
            supervisor

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install mesa requirements
install_mesa() {
    echo "**** Update apt database ****"
        dpkg --add-architecture i386
        apt-get update
    
    echo "**** Install mesa and vulkan requirements ****"
        apt-get install -y --no-install-recommends \
            libegl1 \
            libgl1-mesa-dri \
            libgl1-mesa-dri:i386 \
            libgl1-mesa-glx \
            libglu1-mesa \
            libglx-mesa0:i386 \
            libgtk-3-0 \
            libgtk2.0-0 \
            libsdl2-2.0-0 \
            libvulkan1 \
            libvulkan1:i386 \
            mesa-utils \
            mesa-utils-extra \
            mesa-vulkan-drivers \
            mesa-vulkan-drivers:i386 \
            vainfo \
            vulkan-tools 
    
    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install X Server requirements
install_X_server() {
    echo "**** Update apt database ****"
        apt-get update
    
    echo "**** Install X Server requirements ****"
        apt-get install -y --no-install-recommends \
            avahi-utils \
            dbus-x11 \
            libxcomposite-dev \
            libxcursor1 \
            x11-xfs-utils \
            x11vnc \
            xauth \
            xfonts-base \
            xorg \
            xserver-xorg-core \
            xserver-xorg-input-libinput \
            xserver-xorg-legacy \
            xserver-xorg-video-all \
            xvfb
    
    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install audio requirements
install_audio() {
    echo "**** Update apt database ****"
        apt-get update \
    
    echo "**** Install X Server requirements ****"
        apt-get install -y --no-install-recommends \
            pulseaudio \
            alsa-utils \
            libasound2 \
            libasound2-plugins
    
    echo "**** Section cleanup ****"
        section_cleanup
    echo
}


# Install openssh server
install_openssh() {
    echo "**** Update apt database ****"
        apt-get update
    
    echo "**** Install openssh server ****"
        apt-get install -y \
            openssh-server
        echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    
    echo "**** Section cleanup ****"
        section_cleanup
    echo
}


update_repo
update_locale
reinstall_cert
install_core
install_supervisor
install_mesa
install_X_server
install_audio
install_openssh
