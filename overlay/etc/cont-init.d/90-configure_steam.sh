
print_header "Configure Steam"

steam_autostart_desktop="$(
    cat <<EOF
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

default_steam_config="$(
    cat <<EOF
"InstallConfigStore"
{
        "Software"
        {
                "Valve"
                {
                        "Steam"
                        {
                                "CompatToolMapping"
                                {
                                        "0"
                                        {
                                                "name"          "proton_hotfix"
                                                "config"                ""
                                                "priority"              "75"
                                        }
                                }
                        }
                }
        }
}
EOF
)"

default_steam_library_config="$(
    cat <<EOF
"libraryfolders"
{
        "0"
        {
                "path"          "/home/default/.steam/steam"
                "label"         "Home"
                "totalsize"     "0"
                "update_clean_bytes_tally" "0"
                "time_last_update_verified" "0"
                "apps"
                {
                }
        }
        "1"
        {
                "path"          "/mnt/games/GameLibrary/Steam"
                "label"         "Games"
                "contentid"     "4532270033051814356"
                "totalsize"     "0"
                "update_clean_bytes_tally" "0"
                "time_last_update_verified" "0"
                "apps"
                {
                }
        }
}
EOF
)"

games_steam_library_config="$(
    cat <<EOF
"libraryfolder"
{
        "contentid"     "4532270033051814356"
        "label"         "Games"
}
EOF
)"

if [ "${ENABLE_STEAM:-}" = "true" ]; then
    if [ "${MODE}" == "s" ] || [ "${MODE}" == "secondary" ]; then
        print_step_header "Enable Steam supervisor.d service"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/steam.ini
    else
        print_step_header "Enable Steam auto-start script"
        mkdir -p "${USER_HOME:?}/.config/autostart"
        echo "${steam_autostart_desktop:?}" >"${USER_HOME:?}/.config/autostart/Steam.desktop"
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/steam.ini
    fi

    # Ensuring Steam Play is enabled for all titles
    CONFIG_VDF="${USER_HOME:?}/.steam/steam/config/config.vdf"
    if [ ! -f "${CONFIG_VDF}" ]; then
        print_step_header "Initializing Steam config"
        mkdir -p "$(dirname "${CONFIG_VDF}")"
        echo "${default_steam_config}" >"${CONFIG_VDF}"
        chown -R "${USER:?}:${USER:?}" "${USER_HOME:?}/.steam"
    else
        print_step_header "Steam config already exists, skipping initialization"
    fi

    # Ensure Steam library folder is set to /mnt/games if not already
    LIBRARY_VDF="${USER_HOME:?}/.steam/steam/steamapps/libraryfolders.vdf"
    if [ ! -f "${LIBRARY_VDF}" ]; then
        print_step_header "Initializing Steam library"
        mkdir -p "$(dirname "${LIBRARY_VDF}")"
        echo "${default_steam_library_config}" >"${LIBRARY_VDF}"
        chown -R "${USER:?}:${USER:?}" "${USER_HOME:?}/.steam"
        # Only if we have mounted a /mnt/games path, then make the default games library for steam
        if [ -d "/mnt/games" ]; then
            mkdir -p "/mnt/games/GameLibrary/Steam/steamapps"
            chown "${USER:?}:${USER:?}" \
                "/mnt/games/GameLibrary" \
                "/mnt/games/GameLibrary/Steam" \
                "/mnt/games/GameLibrary/Steam/steamapps"
            echo "${games_steam_library_config}" >"/mnt/games/GameLibrary/Steam/libraryfolder.vdf"
        fi
    else
        print_step_header "Steam library config already exists, skipping initialization"
    fi
else
    print_step_header "Disable Steam service"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/steam.ini
fi

echo -e "\e[34mDONE\e[0m"
