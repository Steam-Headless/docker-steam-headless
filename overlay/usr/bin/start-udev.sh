#!/usr/bin/env bash
###
# File: start-xorg.sh
# Project: bin
# File Created: Tuesday, 12th January 2022 8:46:47 am
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 14th January 2022 9:21:00 am
# Modified By: Josh.5 (jsunnex@gmail.com)
###

# Start udev
# Source: https://github.com/balena-io-playground/balena-base-images/
if command -v udevd &> /dev/null; then
    unshare --net udevd --daemon &> /dev/null
else
    unshare --net /lib/systemd/systemd-udevd --daemon &> /dev/null
fi
udevadm trigger &> /dev/null


# Monitry kernel uevents
udevadm monitor
