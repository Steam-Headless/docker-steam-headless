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

# Install Steam
install_steam() {
    echo "**** Update apt database ****" #Different
        dpkg --add-architecture i386
        apt-get update

    echo "**** Install steam ****"
        echo steam steam/question 'select' 'I AGREE' | debconf-set-selections
        echo steam steam/license 'note' '' | debconf-set-selections
        apt-get install -y #Twice?
        apt-get install -y \
            steam \
            steam-devices
    
    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install firefox
install_firefox() {
    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install firefox ****"
        apt-get install -y \
            firefox-esr

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Setup audio streaming deps
install_audio() {
    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install audio streaming deps ****"
        apt-get install -y --no-install-recommends \
            bzip2 \
            gstreamer1.0-alsa \
            gstreamer1.0-gl \
            gstreamer1.0-gtk3 \
            gstreamer1.0-libav \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-ugly \
            gstreamer1.0-pulseaudio \
            gstreamer1.0-qt5 \
            gstreamer1.0-tools \
            gstreamer1.0-vaapi \
            gstreamer1.0-x \
            libgstreamer1.0-0 \
            libncursesw5 \
            libopenal1 \
            libsdl-image1.2 \
            libsdl-ttf2.0-0 \
            libsdl1.2debian \
            libsndfile1 \
            ucspi-tcp

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Setup video streaming deps
install_video() {
    echo "**** Update apt database ****"
        apt-get update \

    echo "**** Install Intel media drivers and VAAPI ****"
        apt-get install -y --no-install-recommends \
            intel-media-va-driver-non-free \
            i965-va-driver-shaders \
            libva2 \
            vainfo

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

# Install sunshine
SUNSHINE_VERSION=0.11.1
install_sunshine() {
    echo "**** Fetch Sunshine deb package ****"
        cd /tmp
        wget -O /tmp/sunshine-debian.deb \
            https://github.com/loki-47-6F-64/sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-debian.deb

    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install Sunshine ****"
        apt-get install -y /tmp/sunshine-debian.deb

    echo "**** Section cleanup ****"
        section_cleanup
    echo
}

install_steam
install_firefox
install_audio
install_video
install_sunshine
