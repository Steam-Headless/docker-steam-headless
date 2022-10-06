#!/usr/bin/env bash
###
# File: start-desktop.sh
# Project: bin
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Wednesday, 26th January 2022 5:38:23 pm
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$desktop_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# CONFIGURE:
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-:/tmp/.X11-unix/run}
#XAUTHORITY=${XDG_RUNTIME_DIR:-/home/${USER}/.xauthority}
XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/${USER}/.local/share/flatpak/exports/share"
export $(dbus-launch)

# Set the default background for gnome based desktop
mkdir -p /etc/alternatives
ln -sf /usr/share/backgrounds/steam.jpg /etc/alternatives/desktop-background


# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Run the desktop environment in order of priority
if [[ -e /usr/bin/cinnamon-session ]]; then
    /usr/bin/cinnamon-session --display=${DISPLAY} &
    desktop_pid=$!
elif [[ -e /usr/bin/mate-session ]]; then
    /usr/bin/mate-session &
    desktop_pid=$!
elif [[ -e /usr/bin/startplasma-x11 ]]; then
    /usr/bin/startplasma-x11 &
    desktop_pid=$!
elif [[ -e /usr/bin/startxfce4 ]]; then
    /usr/bin/startxfce4 &
    desktop_pid=$!
fi


# WAIT FOR CHILD PROCESS:
wait "$desktop_pid"
