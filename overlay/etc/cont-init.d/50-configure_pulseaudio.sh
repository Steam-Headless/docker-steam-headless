
echo "**** Configure pulseaudio ****"

if [ "${MODE}" == "s" ] | [ "${MODE}" == "secondary" ]; then
    echo "Configure pulseaudio as simple dummy audio"
    sed -i 's|^; autospawn.*$|autospawn = no|' /etc/pulse/client.conf
    sed -i 's|^; daemon-binary.*$|daemon-binary = /bin/true|' /etc/pulse/client.conf

    sed -i 's|^; flat-volumes.*$|flat-volumes = yes|' /etc/pulse/daemon.conf
else
    echo "Configure pulseaudio to pipe audio to a socket"

    # Ensure pulseaudio directories have the correct permissions
    mkdir -p \
        ${PULSE_SOCKET_DIR} \
        /home/${USER}/.config/pulse
    chmod -R a+rw ${PULSE_SOCKET_DIR}
    chown -R ${PUID}:${PGID} /home/${USER}/.config/pulse

    # Configure the palse audio socket
    sed -i "s|^; default-server.*$|default-server = ${PULSE_SERVER}|" /etc/pulse/client.conf
    sed -i "s|^load-module module-native-protocol-unix.*$|load-module module-native-protocol-unix socket=${PULSE_SOCKET_DIR}/pulse-socket auth-anonymous=1|" \
        /etc/pulse/default.pa

    # Disable pulseaudio from respawning (https://unix.stackexchange.com/questions/204522/how-does-pulseaudio-start)
    sed -i 's|^; autospawn.*$|autospawn = no|' /etc/pulse/client.conf
    sed -i 's|^; daemon-binary.*$|daemon-binary = /bin/true|' /etc/pulse/client.conf

    # Enable debug logging
    if [ "X${DEBUGGING:-}" == "X" ]; then
        sed -i 's|^; log-level.*$|log-level = debug|' /etc/pulse/daemon.conf
    fi

    # Make startup script executable
    chmod +x /usr/bin/start-pulseaudio.sh
fi
chown -R ${USER} /etc/pulse

echo "DONE"
