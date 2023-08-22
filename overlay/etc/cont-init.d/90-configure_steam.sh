
echo "**** Configure Steam ****"

steam_autostart_desktop="$(cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Steam
Comment=Launch steam on login
Exec=/usr/games/steam %U ${STEAM_ARGS:-}
Icon=steam
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF
)"

if [ "${ENABLE_STEAM:-}" = "true" ]; then
    if [ "${MODE}" == "s" ] | [ "${MODE}" == "secondary" ]; then
        echo "Enable Steam supervisor.d service"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/steam.ini
    else
        echo "Enable Steam auto-start script"
        mkdir -p "${USER_HOME:?}/.config/autostart"
        echo "${steam_autostart_desktop:?}" > "${USER_HOME:?}/.config/autostart/Steam.desktop"
    fi
else
    echo "Disable Steam service"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/steam.ini
fi

echo "DONE"
