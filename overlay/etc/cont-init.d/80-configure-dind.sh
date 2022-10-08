
echo "**** Configure Dockerd ****"

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [ ! -S /var/run/docker.sock ]; then
        echo "Enable Dockerd daemon"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/dind.ini
        chmod +x /usr/bin/start-dind.sh
    else
        echo "Docker socket has been passed in from host. Using that instead"
    fi
    # Configure 'default' user to run docker commands without sudo
    echo "Add user '${USER}' to docker group for sudoless execution"
    groupadd docker
    usermod -aG docker ${USER}
    mkdir -p /home/${USER}/.docker
    chown -R ${PUID}:${PGID} /home/${USER}/.docker
    chmod -R g+rwx /home/${USER}/.docker
else
    echo "Dockerd daemon not available when container is run in 'secondary' mode"
fi

echo "DONE"
