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

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$xorg_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# EXECUTE PROCESS:
# Wait for udev
MAX=10
CT=0
while [ ! -f /tmp/.udev-started ]; do
    sleep 1
    CT=$(( CT + 1 ))
    if [ "$CT" -ge "$MAX" ]; then
        LOG "FATAL: $0: Gave up waiting for udev server to start"
        exit 11
    fi
done
# Run X server
/usr/bin/Xorg -ac -noreset -novtswitch -sharevts -dpi "${DISPLAY_DPI}" +extension "GLX" +extension "RANDR" +extension "RENDER" vt7 "${DISPLAY}" &
xorg_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$xorg_pid"
