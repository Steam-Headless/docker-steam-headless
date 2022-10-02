#!/usr/bin/env bash
###
# File: start-udev.sh
# Project: bin
# File Created: Tuesday, 12th January 2022 8:46:47 am
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 14th January 2022 9:21:00 am
# Modified By: Josh.5 (jsunnex@gmail.com)
###

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$monitor_pid" 2>/dev/null
    kill -TERM "$trigger_pid" 2>/dev/null
    kill -TERM "$udevd_pid" 2>/dev/null
}
trap _term SIGTERM


# EXECUTE PROCESS:
# Start udev
# Source: https://github.com/balena-io-playground/balena-base-images/
if command -v udevd &>/dev/null; then
    unshare --net udevd --daemon &>/dev/null
    udevd_pid=$!
else
    unshare --net /lib/systemd/systemd-udevd --daemon &>/dev/null
    udevd_pid=$!
fi
udevadm trigger &>/dev/null
trigger_pid=$!
# Monitor kernel uevents
udevadm monitor &
monitor_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$monitor_pid"
wait "$trigger_pid"
wait "$udevd_pid"
