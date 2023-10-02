
# Configure dbus
print_header "Configure pulseaudio"

# Always enable the pulseaudio service
print_step_header "Enable pulseaudio service."
sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/pulseaudio.ini

if [ "${MODE}" == "s" ] | [ "${MODE}" == "secondary" ]; then
    print_step_header "Configure pulseaudio as simple dummy audio"
    sed -i 's|^; autospawn.*$|autospawn = no|' /etc/pulse/client.conf
    sed -i 's|^; daemon-binary.*$|daemon-binary = /bin/true|' /etc/pulse/client.conf

    sed -i 's|^; flat-volumes.*$|flat-volumes = yes|' /etc/pulse/daemon.conf
else
    print_step_header "Configure pulseaudio to pipe audio to a socket"

    # Ensure pulseaudio directories have the correct permissions
    mkdir -p \
        ${PULSE_SOCKET_DIR} \
        ${USER_HOME:?}/.config/pulse
    chmod -R a+rw ${PULSE_SOCKET_DIR}
    chown -R ${PUID}:${PGID} ${USER_HOME:?}/.config/pulse

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
fi
chown -R ${USER} /etc/pulse

echo -e "\e[34mDONE\e[0m"
