#!/usr/bin/env bash
###
# File: start-desktop.sh
# Project: bin
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Saturday, 8th July 2023 2:34:11 am
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$desktop_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# CONFIGURE:
export $(dbus-launch)


# EXECUTE PROCESS:
# Install/Upgrade user apps
if [[ ! -f /tmp/.desktop-apps-updated.lock ]]; then
    source /opt/scripts/install_steam.sh
    source /opt/scripts/install_firefox.sh
    source /opt/scripts/install_protonup.sh
    touch /tmp/.desktop-apps-updated.lock
fi
# Wait for the X server to start
wait_for_x
# Run the desktop environment
echo "**** Starting Xfce4 ****"
/usr/bin/startxfce4 &
desktop_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$desktop_pid"
