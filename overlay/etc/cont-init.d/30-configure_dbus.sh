
# Configure dbus
print_header "Configure container dbus"

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [[ "${HOST_DBUS}" == "true" ]]; then
        print_step_header "Container configured to use the host dbus";
        # Disable supervisord script
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/dbus.ini
    else
        print_step_header "Container configured to run its own dbus";
        # Enable supervisord script
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/dbus.ini
        # Configure dbus to run as USER
        sed -i "/  <user>/c\  <user>${USER}</user>" /usr/share/dbus-1/system.conf
        # Remove old dbus session
        rm -rf ${USER_HOME}/.dbus/session-bus/* 2> /dev/null
        # Remove old dbus pids
        mkdir -p /var/run/dbus
        chown -R ${PUID}:${PGID} /var/run/dbus/
        chmod -R 770 /var/run/dbus/
        # Generate a dbus machine ID
        dbus-uuidgen > /var/lib/dbus/machine-id
        # Remove old lockfiles
        find /var/run/dbus -name "pid" -exec rm -f {} \;
    fi
else
    print_step_header "Dbus service not available when container is run in 'secondary' mode."
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/dbus.ini
fi

echo -e "\e[34mDONE\e[0m"
