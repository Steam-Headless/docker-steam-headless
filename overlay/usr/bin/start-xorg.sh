#!/usr/bin/env bash
###
# File: start-xorg.sh
# Project: bin
# File Created: Tuesday, 11th January 2022 8:28:52 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 6th October 2022 9:21:00 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$xorg_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# EXECUTE PROCESS:
# Wait for udev
if [ $(grep autostart /etc/supervisor.d/udev.ini 2> /dev/null) == "autostart=true" ]; then
    wait_for_udev
fi
# Run X server
/usr/bin/Xorg \
    -ac \
    -noreset \
    -novtswitch \
    -sharevts \
    +extension RANDR \
    +extension RENDER \
    +extension GLX \
    +extension XVideo \
    +extension DOUBLE-BUFFER \
    +extension SECURITY \
    +extension DAMAGE \
    +extension X-Resource \
    -extension XINERAMA -xinerama \
    +extension Composite +extension COMPOSITE \
    -dpms \
    -s off \
    -nolisten tcp \
    -iglx \
    -verbose \
    vt7 "${DISPLAY:?}" &
xorg_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$xorg_pid"
