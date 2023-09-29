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

# Wait for X server to start
#   (Credit: https://gist.github.com/tullmann/476cc71169295d5c3fe6)
wait_for_x() {
    MAX=60 # About 30 seconds
    CT=0
    while ! xdpyinfo >/dev/null 2>&1; do
        sleep 0.50s
        CT=$(( CT + 1 ))
        if [ "$CT" -ge "$MAX" ]; then
            echo "FATAL: $0: Gave up waiting for X server $DISPLAY"
            exit 11
        fi
    done
}

# Wait for udev init to complete
wait_for_udev() {
    MAX=10
    CT=0
    while [ ! -e /run/udev/control ]; do
        sleep 1
        CT=$(( CT + 1 ))
        if [ "$CT" -ge "$MAX" ]; then
            echo "FATAL: $0: Gave up waiting for udev server to start"
            exit 11
        fi
    done
}

# Wait for dockerd to start
wait_for_docker() {
    MAX=10
    CT=0
    while ! docker system info >/dev/null 2>&1; do
        sleep 1
        CT=$(( CT + 1 ))
        if [ "$CT" -ge "$MAX" ]; then
            echo "FATAL: $0: Gave up waiting for dockerd service to start"
            exit 11
        fi
    done
    echo "DOCKERD RUNNING!"
}

# Wait for desktop to start
wait_for_desktop() {
    MAX=30
    CT=0
    while [ ! -f /tmp/.started-desktop ]; do
        sleep 1
        CT=$(( CT + 1 ))
        if [ "$CT" -ge "$MAX" ]; then
            echo "FATAL: $0: Gave up waiting for Desktop to start"
            exit 11
        fi
    done
}

# Fech NVIDIA GPU device (if one exists)
get_nvidia_gpu_id() {
    if [ "${NVIDIA_VISIBLE_DEVICES:-}" == "all" ]; then
        gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
    elif [ -z "${NVIDIA_VISIBLE_DEVICES:-}" ]; then
        gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
    else
        gpu_select=$(nvidia-smi --format=csv --id=$(echo "${NVIDIA_VISIBLE_DEVICES:-}" | cut -d ',' -f1) --query-gpu=uuid | sed -n 2p)
        if [ -z "$gpu_select" ]; then
            gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
        fi
    fi
    echo ${gpu_select}
}

export_desktop_dbus_session() {
    if [ ! -f /tmp/.dbus-desktop-session.env ]; then
        echo "$(dbus-launch)" > /tmp/.dbus-desktop-session.env
    fi
    export $(cat /tmp/.dbus-desktop-session.env)
}

# Wait for desktop dbus session to start
wait_for_desktop_dbus_session() {
    MAX=10
    CT=0
    while [ ! -f /tmp/.dbus-desktop-session.env ]; do
        sleep 1
        CT=$(( CT + 1 ))
        if [ "$CT" -ge "$MAX" ]; then
            echo "FATAL: $0: Gave up waiting for Desktop dbus-launch session to be created"
            exit 11
        fi
    done
}
