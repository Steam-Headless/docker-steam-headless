#!/usr/bin/env bash
###
# File: install_heroic.sh
# Project: scripts
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Monday, 17th January 2022 11:44:46 pm
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

pkg=heroic
script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
script_name=$( basename "${BASH_SOURCE[0]}" )

github_get_all_release() {
    REPO="${1}";
    curl --silent "https://api.github.com/repos/${REPO}/releases" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/';
}

install() {
    if ! dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
        echo 'deb https://sourceforge.net/projects/madlinux/files/repo core main'|sudo tee /etc/apt/sources.list.d/madlinux.list
        wget -qO- Https://sourceforge.net/projects/madlinux/files/repo/madlinux.key|gpg --dearmor|sudo tee /etc/apt/trusted.gpg.d/madlinux.gpg>/dev/null

        apt-get update
        apt-get install -y heroic
    fi

    if ! dpkg --get-selections | grep -q "^zenity[[:space:]]*install$" >/dev/null; then
        # Pre-install deps
        apt-get update
        apt-get install -y zenity
    fi

    if [[ ! -d "/home/${USER}/HeroicBashLauncher" ]]; then
        # Download HeroicBashLauncher
        latest_release=$(github_get_all_release redromnon/HeroicBashLauncher | head -n1)
        download_url="https://github.com/redromnon/HeroicBashLauncher/releases/download/${latest_release}/HeroicBashLauncher_${latest_release}.zip"
        wget -O "/tmp/HeroicBashLauncher-${latest_release}.zip" "${download_url}"

        # Extract HeroicBashLauncher
        su ${USER} -c "cd /home/${USER} && unzip -o /tmp/HeroicBashLauncher-${latest_release}.zip"
        
        # Setup as user
        chmod +x /home/${USER}/HeroicBashLauncher/setup.sh
        sed -i 's|^#!.*\/bash$|#!/usr/bin/env bash|' /home/${USER}/HeroicBashLauncher/setup.sh
    fi

    # Remove installer shortcut
    rm -f /usr/share/applications/install.heroic.desktop
}


#INSTALLER:
source "${script_path}/installer.sh"






