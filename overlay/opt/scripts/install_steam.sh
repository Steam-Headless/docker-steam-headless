#!/usr/bin/env bash

echo "**** Installing/upgrading Steam via flatpak ****"

# Install Steam client
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
flatpak --user install --assumeyes --or-update flathub com.valvesoftware.Steam
# Configure any required overrides
flatpak --user override --filesystem=/mnt/games com.valvesoftware.Steam
# TODO: Check if we should add /dev/dri here??

# Configure default steam library paths
echo "Configure Steam default libraries..."
mkdir -p /mnt/games/GameLibrary/SteamLibrary
libraryfolders="$(cat <<EOF
"libraryfolders"
{
        "0"
        {
                "path"          "${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam"
                "label"         ""
                "contentid"             "5619710282499379610"
                "totalsize"             "0"
                "update_clean_bytes_tally"              "0"
                "time_last_update_corruption"           "0"
                "apps"
                {
                }
        }
        "1"
        {
                "path"          "/mnt/games/GameLibrary/SteamLibrary"
                "label"         "Mounted Games"
                "contentid"             "4437054932394438372"
                "totalsize"             "0"
                "update_clean_bytes_tally"              "0"
                "time_last_update_corruption"           "0"
                "apps"
                {
                }
        }
}
EOF
)"
if [[ ! -f ${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf ]]; then
    mkdir -p ${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps
    echo "${libraryfolders}" > ${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/libraryfolders.vdf
fi
if [[ ! -f ${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam/config/libraryfolders.vdf ]]; then
    mkdir -p ${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam/config
    echo "${libraryfolders}" > ${USER_HOME:?}/.var/app/com.valvesoftware.Steam/.local/share/Steam/config/libraryfolders.vdf
fi
# Remove old autostart script if pointing to old native debian steam launcher
mkdir -p "${USER_HOME:?}/.config/autostart"
if grep "Exec=/usr/games/steam %U" "${USER_HOME:?}/.config/autostart/Steam.desktop" &> /dev/null; then
    rm -fv  "${USER_HOME:?}/.config/autostart/Steam.desktop"
fi
# Create autostart script if missing
steam_autostart_desktop="$(cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Steam
Comment=Launch steam on login
Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/bin/steam-wrapper --file-forwarding com.valvesoftware.Steam -silent
Icon=steam
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF
)"
if [[ ! -f "${USER_HOME:?}/.config/autostart/Steam.desktop" ]]; then
    echo "${steam_autostart_desktop:?}" > "${USER_HOME:?}/.config/autostart/Steam.desktop"
fi

echo "DONE"
