
echo "**** Configure VNC ****"

if ([ ${WEB_UI_MODE} = "vnc" ] && [ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    
    echo "Enable VNC server"
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/vnc.ini

    if [[ "${ENABLE_VNC_AUDIO}" == "true" ]]; then
        # Credits for this audio patch:
        #   - https://github.com/novnc/noVNC/issues/302
        #   - https://github.com/vexingcodes/dwarf-fortress-docker
        #   - https://github.com/calebj/noVNC
        if [ -f /opt/noVNC/audio.patch ]; then
            echo "Patching noVNC with audio websocket"
            # Enable supervisord script
            sed -i "s|32123|${PORT_AUDIO_WEBSOCKET}|" /opt/noVNC/audio.patch
            # Apply patch
            pushd /opt/noVNC/ &> /dev/null
            patch -p1 --input=/opt/noVNC/audio.patch --batch --quiet
            popd &> /dev/null
            rm /opt/noVNC/audio.patch
        fi
        # Enable supervisord script
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/vnc-audio.ini

        # Remove x11vnc from applications menu
        if !  grep -q 'Hidden=true' /usr/share/applications/x11vnc.desktop; then
            echo 'Hidden=true' >> /usr/share/applications/x11vnc.desktop
        fi
    else
        echo "Disable audio stream"
        echo "Disable audio websock"
        # Disable supervisord script
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/vnc-audio.ini
    fi

fi

echo "DONE"
