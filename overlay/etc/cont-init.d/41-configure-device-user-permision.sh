#!/usr/bin/env bash
###
# File: configure-device-user-permision.sh
# Project: bin
# File Created: Thursday, 13th January 2022 10:30:36 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Thursday, 13th January 2022 10:37:28 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###


chmod +x /usr/bin/ensure-groups

/usr/bin/ensure-groups /dev/uinput /dev/input/event*
