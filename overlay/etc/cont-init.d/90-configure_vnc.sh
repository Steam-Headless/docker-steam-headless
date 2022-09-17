
echo "**** Configure VNC ****"

function get_unused_port() {
    __start_port=${1}
    __start_port=$((__start_port+1))
    for __check_port in $(seq ${__start_port} 65000); do
        [[ -z $(netstat -ap 2> /dev/null | grep ${__check_port}) ]] && break;
    done
    echo ${__check_port}
}

# Export empty values to start
# Without this, supervisor will not be able to parse the ini configs
export PORT_VNC
export PORT_NOVNC_SERVICE
export PORT_AUDIO_WEBSOCKET
export PORT_AUDIO_STREAM

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [ ${WEB_UI_MODE} = "vnc" ]; then
        echo "Enable VNC server"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/vnc.ini

        # Configure random ports for VNC service, pulseaudio socket, noVNC service and audio transport websocket
        # Note: Ports 32035-32248 are unallocated port ranges. We should be able to find something in here that we can use
        #   REF: https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?&page=130
        export PORT_VNC=$(get_unused_port 32035)
        echo "Configure VNC service port '${PORT_VNC}'"
        export PORT_NOVNC_SERVICE=$(get_unused_port ${PORT_VNC})
        echo "Configure noVNC service port '${PORT_NOVNC_SERVICE}'"
        export PORT_AUDIO_WEBSOCKET=$(get_unused_port ${PORT_NOVNC_SERVICE})
        echo "Configure audio websocket port '${PORT_AUDIO_WEBSOCKET}'"
        export PORT_AUDIO_STREAM=$(get_unused_port ${PORT_AUDIO_WEBSOCKET})
        echo "Configure pulseaudio encoded stream port '${PORT_AUDIO_STREAM}'"
        
        # Configure Nginx proxy for the websocket and VNC
        cp -f /opt/noVNC/nginx.template.conf /opt/noVNC/nginx.conf
        sed -i "s|<USER>|${USER}|" /opt/noVNC/nginx.conf
        sed -i "s|<PORT_NOVNC_WEB>|${PORT_NOVNC_WEB}|" /opt/noVNC/nginx.conf
        sed -i "s|<PORT_NOVNC_SERVICE>|${PORT_NOVNC_SERVICE}|" /opt/noVNC/nginx.conf
        sed -i "s|<PORT_AUDIO_WEBSOCKET>|${PORT_AUDIO_WEBSOCKET}|" /opt/noVNC/nginx.conf
        mkdir -p /var/log/vncproxy
        chown -R ${USER} /var/log/vncproxy


        if [[ "${ENABLE_VNC_AUDIO}" == "true" ]]; then
            # Credits for this audio patch:
            #   - https://github.com/novnc/noVNC/issues/302
            #   - https://github.com/vexingcodes/dwarf-fortress-docker
            #   - https://github.com/calebj/noVNC
            if [ -f /opt/noVNC/audio.patch ]; then
                echo "Patching noVNC with audio websocket"
                # Update port specification in patch file
                sed -i "s|<PORT_AUDIO_WEBSOCKET>|${PORT_AUDIO_WEBSOCKET}|" /opt/noVNC/audio.patch
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
    else
        echo "Disable VNC server"
    fi
else
    echo "VNC server not available when container is run in 'secondary' mode"
fi

echo "DONE"
