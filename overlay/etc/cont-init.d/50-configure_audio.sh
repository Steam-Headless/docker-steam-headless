
echo "**** Configure pulseaudio ****"
if [[ "${ENABLE_VNC_AUDIO}" == "true" ]]; then
    echo "Configure pulseaudio to use a socket to pipe audio to VNC"
    sed -i 's|^; default-server.*$|default-server = unix:/tmp/pulseaudio.socket|' /etc/pulse/client.conf
    sed -i 's|^load-module module-native-protocol-unix.*$|load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket auth-anonymous=1|' \
        /etc/pulse/default.pa
    chown -R ${USER} /etc/pulse

    # Credits for this audio patch:
    #   - https://github.com/novnc/noVNC/issues/302
    #   - https://github.com/vexingcodes/dwarf-fortress-docker
    #   - https://github.com/calebj/noVNC
    if [ -f /opt/noVNC/audio.patch ]; then
        echo "Patching noVNC with audio websocket"
        pushd /opt/noVNC/ &> /dev/null
        patch -p1 --input=/opt/noVNC/audio.patch --batch --quiet
        popd &> /dev/null
        rm /opt/noVNC/audio.patch
    fi
    # Enable supervisord script
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor/conf.d/audio.conf
else
    echo "Disable pulseaudio"
    # Disable supervisord script
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor/conf.d/audio.conf

fi

echo "DONE"
