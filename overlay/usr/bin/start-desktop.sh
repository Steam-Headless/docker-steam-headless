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
export $(dbus-launch)


# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Install/Upgrade user apps
if [[ ! -f /tmp/.desktop-apps-updated.lock ]]; then
    xterm -geometry 200x50+0+0 -ls -e /bin/bash -c "
        source /opt/scripts/install_firefox.sh;
        source /opt/scripts/install_protonup.sh;
        source /opt/scripts/install_sunshine.sh;
        sleep 1;
    "
    touch /tmp/.desktop-apps-updated.lock
fi

# Run the desktop environment
echo "**** Starting Xfce4 ****"
/usr/bin/startxfce4 &
desktop_pid=$!

if [ "${ENABLE_STEAM:-}" = "true" ]; then
    echo "Start Steam service"
    sudo supervisorctl start steam
fi

# WAIT FOR CHILD PROCESS:
wait "$desktop_pid"
