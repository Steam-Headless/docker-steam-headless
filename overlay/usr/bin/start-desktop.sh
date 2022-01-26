#!/usr/bin/env bash
###
# File: start-desktop.sh
# Project: bin
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Wednesday, 26th January 2022 3:29:47 pm
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###
#
# I made this wrapper script so that I could easily try a range of desktop environments
#

XDG_RUNTIME_DIR=/run/user/$(id -u ${USER})
#XAUTHORITY=${XDG_RUNTIME_DIR:-/home/${USER}/.xauthority}
XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/${USER}/.local/share/flatpak/exports/share"
export $(dbus-launch)

# TODO: Set the default background

# Run the desktop environment in order of priority
if [[ -e /usr/bin/cinnamon-session ]]; then
    /usr/bin/cinnamon-session --display=${DISPLAY}
elif [[ -e /usr/bin/startplasma-x11 ]]; then
    /usr/bin/startplasma-x11
elif [[ -e /usr/bin/startxfce4 ]]; then
    /usr/bin/startxfce4
fi
