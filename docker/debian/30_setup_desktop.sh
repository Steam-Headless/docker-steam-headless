#!/bin/bash

# Installs packages needed for compilation inside docker image.

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

# Section cleanup to reduce duplicate code
section_cleanup() {
    apt-get clean autoclean -y
    apt-get autoremove -y
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
}

# Add support for flatpaks
install_flatpacks() {
    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install flatpak support ****" 
        apt-get install -y \
            bridge-utils \
            flatpak \
            libpam-cgfs \
            libvirt0 \
            lxc \
            uidmap

    echo "**** Configure flatpak ****"
        chmod u+s /usr/bin/bwrap

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install desktop environment
install_desktop() {
    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install desktop environment ****"
        apt-get install -y \
            xfce4 \
            xfce4-terminal \
            msttcorefonts \
            fonts-vlgothic \
            gedit

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

install_flatpacks
install_desktop
