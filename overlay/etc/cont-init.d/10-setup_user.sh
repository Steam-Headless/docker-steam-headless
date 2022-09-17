
PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-000}
USER_PASSWORD=${USER_PASSWORD:-password}

echo "**** Configure default user ****"

echo "Setting run user uid=${PUID}(${USER}) gid=${PGID}(${USER})"
usermod -o -u "${PUID}" ${USER}
groupmod -o -g "${PGID}" ${USER}


echo "Adding run user to video, audio, input and pulse groups"
usermod -a -G video,audio,input,pulse ${USER}


echo "Adding run user to render group (for HW accelerated encoding)"
render_guid=$(stat -c "%g" /dev/dri/render* | tail -n 1)
if [[ ! -z ${render_guid} ]]; then
    render_group=$(getent group "${render_guid}" | cut -d: -f1)
    if [[ -z ${render_group} ]]; then
        groupadd -g "${render_guid}" "videorender"
        render_group="videorender"
    fi
    usermod -a -G ${render_group} ${USER}
fi


echo "Setting umask to ${UMASK}";
umask ${UMASK}


export XDG_RUNTIME_DIR=/run/user/${PUID}
echo "Create the user XDG_RUNTIME_DIR path '${XDG_RUNTIME_DIR}'"
mkdir -p ${XDG_RUNTIME_DIR}
chown -R ${PUID}:${PGID} ${XDG_RUNTIME_DIR}
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:/home/${USER}/.local/share/flatpak/exports/share"


# Setup home directory and permissions
echo "Adding default home directory template"
mkdir -p ${USER_HOME}
chown -R ${PUID}:${PGID} /etc/home_directory_template
rsync -aq --ignore-existing /etc/home_directory_template/ ${USER_HOME}/
chmod +x /usr/bin/start-desktop.sh


# Set the root and user password
echo "Setting root password"
echo "root:${USER_PASSWORD}" | chpasswd
echo "Setting user password"
echo "${USER}:${USER_PASSWORD}" | chpasswd

echo "DONE"
