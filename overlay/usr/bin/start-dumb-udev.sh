#!/usr/bin/env bash
###
# File: start-dumb-udev.sh
# Project: bin
# File Created: Tuesday, 12th January 2022 8:46:47 am
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 14th January 2022 9:21:00 am
# Modified By: Josh.5 (jsunnex@gmail.com)
###
set -e

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$dumb_udev_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# EXECUTE PROCESS:
# Start dumb-udev
dumb-udev &
dumb_udev_pid=$!

# WAIT FOR CHILD PROCESS:
wait "$dumb_udev_pid"
