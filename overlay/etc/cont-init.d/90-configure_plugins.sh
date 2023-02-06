
echo "**** Configure Plugins ****"

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [ "X${ENABLED_PLUGINS:-}" != "X" ]; then
        echo "Enable Plugins"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/plugins.ini
        chmod +x /usr/bin/start-plugins.sh
    else
        echo "Disable Plugins"
    fi
else
    echo "Plugins not available when container is run in 'secondary' mode"
fi

echo "DONE"
