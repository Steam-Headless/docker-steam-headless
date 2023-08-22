#!/usr/bin/env bash
###
# File: 30-configure_udev.sh
# Project: cont-init.d
# File Created: Friday, 12th January 2022 8:54:01 am
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 4th October 2022 11:20:48 am
# Modified By: Josh.5 (jsunnex@gmail.com)
###

# Running udev only works in privileged container
# Source: https://github.com/balena-io-playground/balena-base-images/
tmp_mount='/tmp/privileged_test'
mkdir -p "${tmp_mount}"
if mount -t devtmpfs none "${tmp_mount}" &> /dev/null; then
	is_privileged=true
	umount "${tmp_mount}"
else
	is_privileged=false
fi
rm -rf "${tmp_mount}"


if [[ "${is_privileged}" == "true" ]]; then
    # Since this container may also be run with CAP_SYS_ADMIN, ensure we can actually execute "udevadm trigger"
    if udevadm trigger &> /dev/null; then
        echo "**** Configure container to run udev management ****";
        # Enable supervisord script
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/udev.ini
        # Configure udev permissions
        if [[ -f /lib/udev/rules.d/60-steam-input.rules ]]; then
            sed -i 's/MODE="0660"/MODE="0666"/' /lib/udev/rules.d/60-steam-input.rules
        fi
    else
        # Disable supervisord script since we are not able to execute "udevadm trigger"
        echo "**** Disable udev service due to privilege restrictions ****";
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/udev.ini
    fi
else
    # Disable supervisord script
    echo "**** Disable udev service ****";
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/udev.ini
fi


if [[ -e /dev/uinput ]]; then
    echo "**** Ensure the default user has permission to r/w on input devices ****";
    chmod 0666 /dev/uinput
fi

echo "DONE"
