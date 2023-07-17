
echo "**** Configure Steam ****"

if [ "${ENABLE_STEAM:-}" = "true" ]; then
    echo "Enable Steam service"
    sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/steam.ini
    # Remove old autostart script. We should be starting steam with the supervisor service
    mkdir -p "${USER_HOME:?}/.config/autostart"
    # if grep "Exec=/usr/bin/flatpak" "${USER_HOME:?}/.config/autostart/Steam.desktop" &> /dev/null; then
    #     rm -fv "${USER_HOME:?}/.config/autostart/Steam.desktop"
    # fi
    rm -fv "${USER_HOME:?}/.config/autostart/Steam.desktop"
else
    echo "Disable Steam service"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/steam.ini
fi

echo "DONE"
