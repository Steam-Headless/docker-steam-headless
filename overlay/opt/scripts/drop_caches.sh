#!/usr/bin/env bash
###
# File: drop_caches.sh
# Project: docker-steam-headless
# File Created: Wednesday, 12th January 2022 5:08:46 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Wednesday, 12th January 2022 5:44:17 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

# Clear out the memory page cache
echo 1 > /proc/sys/vm/drop_caches

# Flush any FS buffers
sync
