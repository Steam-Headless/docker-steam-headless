#!/usr/bin/env bash
###
# File: install_heroic.sh
# Project: scripts
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Wednesday, 31st August 2022 10:01:31 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
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
github_get_release_download_url() {
    REPO="${1}";
    TAG="${2}";
    TYPE="${3}";
    IGNORE="${4}";
    curl --silent "https://api.github.com/repos/${REPO}/releases/tags/${TAG}" \
        | grep '"browser_download_url":' \
        | sed -E 's/.*"([^"]+)".*/\1/' \
        | grep -P "${TYPE}" \
        | grep -P "${TYPE}" \
        | head -n1;
}

install() {

    # Download Heroic deb package if it does not yet exist
    __latest_heroic_release=$(github_get_all_release "Heroic-Games-Launcher/HeroicGamesLauncher" | head -n1)
    if [[ ! -f "/home/${USER}/Downloads/heroic-${__latest_heroic_release}.deb" ]]; then
        __heroic_download_link=$(github_get_release_download_url "Heroic-Games-Launcher/HeroicGamesLauncher" "${__latest_heroic_release}" ".deb")
        wget -O /tmp/heroic.deb "${__heroic_download_link}"
        [[ $? -gt 0 ]] && echo "Error downloading pacakge. Exit!" && return 1
        mv /tmp/heroic.deb "/home/${USER}/Downloads/heroic-${__latest_heroic_release}.deb"
    fi

    # Install/Update the latest version of Heroic
    [[ "${APT_UPDATED:-false}" == 'false' ]] && apt-get update && APT_UPDATED=true
    apt-get install -y "/home/${USER}/Downloads/heroic-${__latest_heroic_release}.deb"

    # Install/Update deps for HeroicBashLauncher
    [[ "${APT_UPDATED:-false}" == 'false' ]] && apt-get update && APT_UPDATED=true
    apt-get install -y zenity

    # Install/Update the latest version HeroicBashLauncher
    __latest_hbl_release=$(github_get_all_release "redromnon/HeroicBashLauncher" | head -n1)
    if [[ ! -e "/home/${USER}/HeroicBashLauncher/.${__latest_hbl_release}" ]]; then
        # Download HeroicBashLauncher
        if [[ ! -f "/home/${USER}/Downloads/HeroicBashLauncher-${__latest_hbl_release}.zip" ]]; then
            __hbl_download_link=$(github_get_release_download_url "redromnon/HeroicBashLauncher" "${__latest_hbl_release}" "\d\.zip")
            wget -O /tmp/hbl.zip "${__hbl_download_link}"
            [[ $? -gt 0 ]] && echo "Error downloading pacakge. Exit!" && return 1
            mv /tmp/hbl.zip "/home/${USER}/Downloads/HeroicBashLauncher-${__latest_hbl_release}.zip"
        fi

        # Extract HeroicBashLauncher
        mkdir -p "/home/${USER}/HeroicBashLauncher"
        rm -rf "/tmp/hbl"
        su ${USER} -c "mkdir -p /tmp/hbl && cd /tmp/hbl && unzip -o /home/${USER}/Downloads/HeroicBashLauncher-${__latest_hbl_release}.zip"
        su ${USER} -c "cp -rfv /tmp/hbl/HeroicBashLauncher*/HeroicBashLauncher/* /home/${USER}/HeroicBashLauncher/"
        chmod +x "/home/${USER}/HeroicBashLauncher/HeroicBashLauncher"
        
        # Setup script in user PATH
        su ${USER} -c "mkdir -p /home/default/.local/bin"
        su ${USER} -c "ln -sf /home/${USER}/HeroicBashLauncher/HeroicBashLauncher /home/${USER}/.local/bin/HeroicBashLauncher"
    fi

    # Remove installer shortcut
    rm -f /usr/share/applications/install.heroic.desktop
}


#INSTALLER:
source "${script_path}/installer.sh"






