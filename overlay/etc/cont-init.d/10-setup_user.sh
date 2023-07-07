#!/usr/bin/env bash
###
# File: 10-setup_user.sh
# Project: cont-init.d
# File Created: Friday, 12th January 2022 8:54:01 am
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 4th October 2022 11:27:10 am
# Modified By: Josh.5 (jsunnex@gmail.com)
###

PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-000}
USER_PASSWORD=${USER_PASSWORD:-password}

echo "**** Configure default user ****"

echo "Setting default user uid=${PUID}(${USER}) gid=${PGID}(${USER})"
usermod -o -u "${PUID}" ${USER}
groupmod -o -g "${PGID}" ${USER}


echo "Adding default user to video, audio, input and pulse groups"
usermod -a -G video,audio,input,pulse ${USER}


echo "Adding default user to any additional required device groups"
device_nodes=( /dev/uinput /dev/input/event* /dev/dri/* )
added_groups=""
for dev in "${device_nodes[@]}"; do
    # Only process $dev if it's a character device
    if [[ ! -c "${dev}" ]]; then
        continue
    fi

    # Get group name and ID
    dev_group=$(stat -c "%G" "${dev}")
    dev_gid=$(stat -c "%g" "${dev}")

    # Dont add root
    if [[ "${dev_gid}" = 0 ]]; then
        continue
    fi

    # Create a name for the group ID if it does not yet already exist
    if [[ "${dev_group}" = "UNKNOWN" ]]; then
        dev_group="user-gid-${dev_gid}"
        groupadd -g $dev_gid "${dev_group}"
    fi

    # Add group to user
    if [[ "${added_groups}" != *"${dev_group}"* ]]; then
        echo "Adding user '${USER}' to group: '${dev_group}' for device: ${dev}"
        usermod -a -G ${dev_group} ${USER}
        added_groups=" ${added_groups} ${dev_group} "
    fi
done


echo "Setting umask to ${UMASK}";
umask ${UMASK}


# TODO: Move this to its own 'display' init script. It does not really belong here
# Configure the 'XDG_RUNTIME_DIR' path
echo "Create the user XDG_RUNTIME_DIR path '${XDG_RUNTIME_DIR}'"
mkdir -p ${XDG_RUNTIME_DIR}
# Ensure it is owned by the 'default' user
chown -R ${PUID}:${PGID} ${XDG_RUNTIME_DIR}
# Ensure only the 'default' user can access this directory
chmod 700 ${XDG_RUNTIME_DIR}
# Set the default background
mkdir -p /etc/alternatives
ln -sf /usr/share/backgrounds/steam.jpg /etc/alternatives/desktop-background
chmod a+r /etc/alternatives/desktop-background


# Setup home directory and permissions
echo "Adding default home directory template"
mkdir -p ${USER_HOME}
chown -R ${PUID}:${PGID} /etc/home_directory_template
rsync -aq --ignore-existing /etc/home_directory_template/ ${USER_HOME}/


# Setup services log path
echo "Setting ownership of all log files in '${USER_HOME}/.cache/log'"
mkdir -p "${USER_HOME}/.cache/log"
chown -R ${PUID}:${PGID} "${USER_HOME}/.cache/log"


# Set the root and user password
echo "Setting root password"
echo "root:${USER_PASSWORD}" | chpasswd
echo "Setting user password"
echo "${USER}:${USER_PASSWORD}" | chpasswd

# Set root XDG_RUNTIME_DIR path
mkdir -p /tmp/runtime-root
chown root:root /tmp/runtime-root

echo "DONE"
