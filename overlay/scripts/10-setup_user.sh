
PUID=${PUID:-99}
PGID=${PGID:-100}
UMASK=${UMASK:-000}
USER_PASSWORD=${USER_PASSWORD:-password}

echo "**** Configure default user  ****"

echo "Setting run user uid=${PGID}(${USER}) gid=${PUID}(${USER})"
groupmod -o -g "${PGID}" ${USER}
usermod -o -u "${PUID}" ${USER}


echo "Setting umask to ${UMASK}";
umask ${UMASK}


# Setup home directory and permissions
echo "Adding default home directory template"
mkdir -p ${USER_HOME}
chown -R ${PUID}:${PGID} /etc/home_directory_template
rsync -aq /etc/home_directory_template/ ${USER_HOME}/


# Set the root and user password
echo "Setting root password"
echo "root:${USER_PASSWORD}" | chpasswd
echo "Setting user password"
echo "${USER}:${USER_PASSWORD}" | chpasswd

echo "DONE"
