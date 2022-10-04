#!/bin/bash

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

setup_noVNC () {
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
        # sed -i '/    desktopName: "",/c\    desktopName: "Steam Headless - noVNC",' app/ui.js
    echo "**** Section cleanup ****"
        rm -rf \
            /tmp/noVNC* \
            /tmp/novnc.tar.gz
}

setup_websockify () {
    echo "**** Fetch Websockify ****"
        wget -O /tmp/websockify.tar.gz https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.tar.gz
    echo "**** Extract Websockify ****"
        tar -xvf /tmp/websockify.tar.gz -C /tmp
    echo "**** Install Websockify to noVNC path ****"
        mv -v /tmp/websockify-${WEBSOCKETIFY_VERSION} /opt/noVNC/utils/websockify
    echo "**** Install Websockify to main ****"
        cd /opt/noVNC/utils/websockify
        python ./setup.py install
    echo "**** Section cleanup ****"
        rm -rf \
            /tmp/websockify-* \
            /tmp/websockify.tar.gz

}

setup_noVNC
# setup_websockify