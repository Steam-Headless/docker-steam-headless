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

state_dir=/run/udev-input-fix

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "${sync_pid:-}" 2>/dev/null
    kill -TERM "${dumb_udev_pid:-}" 2>/dev/null
    kill -TERM "${udevd_pid:-}" 2>/dev/null
}
trap _term SIGTERM SIGINT

sync_input_nodes() {
    mkdir -p /dev/input

    for sys in /sys/class/input/*/dev; do
        [[ -f "${sys}" ]] || continue

        node=$(basename "$(dirname "${sys}")")
        path="/dev/input/${node}"
        [[ -e "${path}" ]] && continue

        IFS=: read -r major minor < "${sys}"
        mknod "${path}" c "${major}" "${minor}" 2>/dev/null || continue
        chmod 0660 "${path}" 2>/dev/null || true
        chgrp input "${path}" 2>/dev/null || true
    done
}

sunshine_inputs_present() {
    for name_file in /sys/class/input/*/device/name; do
        [[ -f "${name_file}" ]] || continue
        case "$(cat "${name_file}" 2>/dev/null || true)" in
            *passthrough*|Sunshine*)
                return 0
                ;;
        esac
    done
    return 1
}

# EXECUTE PROCESS:
# If a real udev daemon can be started in this restricted environment, prefer
# that over dumb-udev. This gives us /run/udev/control and keeps the existing
# Xorg startup ordering intact, even when /sys is mounted read-only.
mkdir -p "${state_dir}"
if command -v udevd &>/dev/null; then
    unshare --net udevd --daemon &>/dev/null || true
else
    unshare --net /lib/systemd/systemd-udevd --daemon &>/dev/null || true
fi

if pgrep -x systemd-udevd >/dev/null 2>&1; then
    udevd_pid=$(pgrep -xo systemd-udevd || true)
fi

dumb-udev &
dumb_udev_pid=$!

while true; do
    sync_input_nodes

    if sunshine_inputs_present; then
        if [[ ! -e "${state_dir}/xorg-restarted" ]]; then
            # Sunshine creates its virtual input devices on client connect. In
            # restricted containers with a private /dev, the sysfs devices may
            # exist before /dev/input/event* nodes are visible to Xorg. Build
            # the missing nodes, then restart Xorg once so it enumerates them
            # cleanly.
            sleep 2
            sync_input_nodes
            supervisorctl restart xorg >/dev/null 2>&1 || true
            : > "${state_dir}/xorg-restarted"
        fi
    else
        rm -f "${state_dir}/xorg-restarted"
    fi

    sleep 1
done &
sync_pid=$!

# WAIT FOR CHILD PROCESS:
wait "$dumb_udev_pid"
