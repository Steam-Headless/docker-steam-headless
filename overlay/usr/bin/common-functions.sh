#!/usr/bin/env bash
###
# File: common-functions.sh
# Project: bin
# File Created: Tuesday, 6th October 2022 9:30:00 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 6th October 2022 9:30:00 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

wait_for_x() {
    # Wait for X server to start
    #   (Credit: https://gist.github.com/tullmann/476cc71169295d5c3fe6)
    MAX=60 # About 30 seconds
    CT=0
    while ! xdpyinfo >/dev/null 2>&1; do
        sleep 0.50s
        CT=$(( CT + 1 ))
        if [ "$CT" -ge "$MAX" ]; then
            LOG "FATAL: $0: Gave up waiting for X server $DISPLAY"
            exit 11
        fi
    done
}
