if [ "${MODE}" == "s" ] | [ "${MODE}" == "secondary" ]; then
    echo "Configure container as secondary"
    # Disable dbus
    echo " - Disable dbus"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/dbus.ini
    # Disable desktop
    echo " - Disable desktop"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/desktop.ini
    # Disable sshd
    echo " - Disable sshd"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/sshd.ini
    # Disable vnc
    echo " - Disable vnc"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/vnc.ini
    # Disable vnc
    echo " - Disable vnc"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/vnc.ini
    # Disable vnc-audio
    echo " - Disable vnc audio stream"
    echo " - Disable vnc audio websock"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/vnc-audio.ini
    # Disable xorg
    echo " - Disable xorg"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/xorg.ini

    # Enable pulseaudio
    echo " - Enable pulseaudio"
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/pulseaudio.ini
    # Enable steam
    echo " - Enable steam"
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/steam.ini
    # Enable udev
    echo " - Enable udev"
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/udev.ini
fi

echo "DONE"
