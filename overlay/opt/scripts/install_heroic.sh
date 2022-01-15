#!/usr/bin/env bash
###
# File: install_heroic.sh
# Project: scripts
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Sunday, 16th January 2022 6:14:06 am
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

pkg=heroic
script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
script_name=$( basename "${BASH_SOURCE[0]}" )


install() {
    if ! dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
        echo 'deb https://sourceforge.net/projects/madlinux/files/repo core main'|sudo tee /etc/apt/sources.list.d/madlinux.list
        wget -qO- Https://sourceforge.net/projects/madlinux/files/repo/madlinux.key|gpg --dearmor|sudo tee /etc/apt/trusted.gpg.d/madlinux.gpg>/dev/null

        apt-get update
        apt-get install -y heroic
    fi

    # Remove installer shortcut
    rm -f /usr/share/applications/install.heroic.desktop
}


#INSTALLER:
source "${script_path}/installer.sh"






