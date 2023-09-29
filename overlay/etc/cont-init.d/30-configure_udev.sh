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

# Since this container may also be run with CAP_SYS_ADMIN, ensure we can actually execute "udevadm trigger"
run_dumb_udev="false"
if [ ! -w /sys ]; then
    # Disable supervisord script since we are not able to write to sysfs
    echo "**** Disable udevd - /sys is mounted RO ****";
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/udev.ini
    run_dumb_udev="true"
elif [ ! -d /run/udev ]; then
    # Disable supervisord script since we are not able to write to udev/data path
    echo "**** Disable udevd - /run/udev does not exist ****";
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/udev.ini
    run_dumb_udev="true"
elif [ ! -w /run/udev ]; then
    # Disable supervisord script since we are not able to write to udev/data path
    echo "**** Disable udevd - /run/udev is mounted RO ****";
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/udev.ini
    run_dumb_udev="false"
elif udevadm trigger &> /dev/null; then
    echo "**** Configure container to run udev management ****";
    # Enable supervisord script
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/udev.ini
    # Configure udev permissions
    if [[ -f /lib/udev/rules.d/60-steam-input.rules ]]; then
        sed -i 's/MODE="0660"/MODE="0666"/' /lib/udev/rules.d/60-steam-input.rules
    fi
    run_dumb_udev="false"
else
    # Disable supervisord script since we are not able to execute "udevadm trigger"
    echo "**** Disable udev service due to privilege restrictions ****";
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/udev.ini
    run_dumb_udev="true"
fi

if [ "${run_dumb_udev}" = "true" ]; then
    # Enable dumb-udev instead of udevd
    echo "**** Enable dumb-udev service ****";
    sed -i 's|^command.*=.*$|command=start-dumb-udev.sh|' /etc/supervisor.d/udev.ini
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/udev.ini
fi


if [[ -e /dev/uinput ]]; then
    echo "**** Ensure the default user has permission to r/w on input devices ****";
    chmod 0666 /dev/uinput
fi

echo "DONE"
