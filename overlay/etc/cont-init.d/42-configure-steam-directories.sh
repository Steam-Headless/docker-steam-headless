#!/usr/bin/env bash
###
# File: 42-configure-steam-directories.sh
# Project: cont-init.d
# File Created: Thursday, 13th January 2022 10:41:17 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Friday, 14th January 2022 8:43:18 am
# Modified By: Josh.5 (jsunnex@gmail.com)
###


# TODO: Make this a symlink to the home directory
mkdir -p /tmp/dumps
chown -R ${PUID}:${PGID} /tmp/dumps
