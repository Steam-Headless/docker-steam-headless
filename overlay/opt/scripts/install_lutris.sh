#!/usr/bin/env bash
###
# File: install_lutris.sh
# Project: scripts
# File Created: Thursday, 1st January 1970 12:45:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Sunday, 16th January 2022 2:17:37 am
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

pkg=lutris
script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
script_name=$( basename "${BASH_SOURCE[0]}" )


install() {
    if ! dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
        echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ ./" | tee /etc/apt/sources.list.d/lutris.list
        wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_10/Release.key -O- | apt-key add -
        apt-get update
        apt-get -y install \
            lutris \
            python3-dbus

        sed -i '/Exec=lutris %U/c\Exec=/usr/games/lutris %U' /usr/share/applications/net.lutris.Lutris.desktop
    fi
}


#INSTALLER:
source "${script_path}/installer.sh"
