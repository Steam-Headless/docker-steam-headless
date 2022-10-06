#!/bin/bash

# Installs packages needed for compilation inside docker image.

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

NOVNC_VERSION=1.2.0
WEBSOCKETIFY_VERSION=0.10.0

# Install noVNC
install_noVNC() {
    cd /tmp
    echo "**** Fetch noVNC ****"
        wget -O /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz

    echo "**** Extract noVNC ****"
        tar -xvf /tmp/novnc.tar.gz

    echo "**** Configure noVNC ****"
        mkdir -p /opt
        rm -rf /opt/noVNC
        mv -f /tmp/noVNC-${NOVNC_VERSION} /opt/noVNC
        cd /opt/noVNC
        ln -s vnc.html index.html
        chmod -R 755 /opt/noVNC

    echo "**** Modify noVNC ****"
        sed -i 's/credentials: { password: password } });/credentials: { password: password },\n                           wsProtocols: ["'"binary"'"] });/g' app/ui.js
        sed -i '/    document.title =/c\    document.title = "Steam Headless - noVNC";' app/ui.js

    echo "**** Update apt database ****"
        apt-get update

    echo "**** Install nginx support ****"
        apt-get install -y \
            nginx

    echo "**** Section cleanup ****"
        apt-get clean autoclean -y
        apt-get autoremove -y
        rm -rf \
            /var/lib/apt/lists/* \
            /tmp/noVNC* \
            /tmp/novnc.tar.gz

}

# Install Websockify
install_Websockify() {
    cd /tmp
    echo "**** Fetch Websockify ****"
        wget -O /tmp/websockify.tar.gz https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.tar.gz

    echo "**** Extract Websockify ****"
        tar -xvf /tmp/websockify.tar.gz

    echo "**** Install Websockify to main ****"
        cd /tmp/websockify-${WEBSOCKETIFY_VERSION}
        python3 ./setup.py install
    
    echo "**** Install Websockify to noVNC path ****"
        mv -v /tmp/websockify-${WEBSOCKETIFY_VERSION} /opt/noVNC/utils/websockify

    echo "**** Section cleanup ****"
        rm -rf \
            /tmp/websockify-* \
            /tmp/websockify.tar.gz

}

install_noVNC
install_Websockify
