
echo "**** Configure pulseaudio ****"

if [ "${MODE}" == "s" ] | [ "${MODE}" == "secondary" ]; then
    echo "Configure pulseaudio as simple dummy audio"
    sed -i 's|^; autospawn.*$|autospawn = no|' /etc/pulse/client.conf
    sed -i 's|^; daemon-binary.*$|daemon-binary = /bin/true|' /etc/pulse/client.conf

    sed -i 's|^; flat-volumes.*$|flat-volumes = yes|' /etc/pulse/daemon.conf
else
    echo "Configure pulseaudio to pipe audio to a socket"
    sed -i 's|^; default-server.*$|default-server = unix:/tmp/pulseaudio.socket|' /etc/pulse/client.conf
    sed -i 's|^load-module module-native-protocol-unix.*$|load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket auth-anonymous=1|' \
        /etc/pulse/default.pa
fi
chown -R ${USER} /etc/pulse

echo "DONE"
