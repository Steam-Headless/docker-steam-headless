
echo "**** Configure Sunshine ****"

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [ "${ENABLE_SUNSHINE:-}" = "true" ]; then
        echo "Enable Sunshine server"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/sunshine.ini
        chmod +x /usr/bin/start-sunshine.sh
    else
        echo "Disable Sunshine server"
    fi
else
    echo "Sunshine server not available when container is run in 'secondary' mode"
fi

echo "DONE"
