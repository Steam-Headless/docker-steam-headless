#!/usr/bin/env bash
###
# File: start-desktop.sh
# Project: bin
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Saturday, 8th July 2023 6:16:47 pm
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
# Remove lockfile
rm -f /tmp/.started-desktop
# Start a session bus instance of dbus-daemon
# Note: This script should be the only one that waits for X after exporting this dbus session
rm -fv /tmp/.dbus-desktop-session.env
export_desktop_dbus_session
# Configure some XDG environment variables
export XDG_CACHE_HOME="${USER_HOME:?}/.cache"
export XDG_CONFIG_HOME="${USER_HOME:?}/.config"
export XDG_DATA_HOME="${USER_HOME:?}/.local/share"

# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Install/Upgrade user apps
if [[ ! -f /tmp/.desktop-apps-updated ]]; then
    xterm -geometry 200x50+0+0 -ls -e /bin/bash -c "
        source /usr/bin/install_firefox.sh;
        source /usr/bin/install_protonup.sh;
        sleep 1;
    "
    touch /tmp/.desktop-apps-updated
fi

# Run the desktop environment
echo "**** Starting Xfce4 ****"
/usr/bin/startxfce4 &
desktop_pid=$!
touch /tmp/.started-desktop

# WAIT FOR CHILD PROCESS:
wait "$desktop_pid"
