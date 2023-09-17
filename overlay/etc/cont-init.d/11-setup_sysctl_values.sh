#!/usr/bin/env bash
###
# File: 11-setup_sysctl_values.sh
# Project: cont-init.d
# File Created: Friday, 1st September 2023 3:56:17 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Monday, 1st September 2023 3:56:17 pm
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

echo "**** Configure some system kernel parameters ****"


if [ "$(cat /proc/sys/vm/max_map_count)" -ge 524288 ]; then
    if [ -w "/proc/sys/vm/max_map_count" ]; then
        echo "Setting the maximum number of memory map areas a process can create to 524288"
        echo 524288 > /proc/sys/vm/max_map_count
    else
        echo "WARNING: Unable to set max_map_count on unprivileged container"
    fi
else
    echo "NOTE: vm.max_map_count is already greater than '524288'"
fi

echo "DONE"
