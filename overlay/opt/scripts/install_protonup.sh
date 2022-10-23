#!/usr/bin/env bash
###
# File: install_protonup.sh
# Project: scripts
# File Created: Thursday, 1st January 1970 12:45:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Sunday, 16th January 2022 4:55:12 am
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

pkg=protonup-ng
script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
script_name=$( basename "${BASH_SOURCE[0]}" )


install() {
    if ! command -v ${pkg} >/dev/null; then
        # Install application
        python3 -m pip install ${pkg}
        # Set installation path as user
        # Note: Run command with su because init processes are run as root but this is a user thing...
        su ${USER} -c "${pkg} -d '/home/${USER}/.steam/root/compatibilitytools.d/'"
        # Update to the latest version on startup using the users Downloads directory
        su ${USER} -c "${pkg} -y -o '/home/${USER}/Downloads/'" &
    fi

    # Remove installer shortcut
    rm -f /usr/share/applications/install.protonup.desktop
}


#INSTALLER:
source "${script_path}/installer.sh"
