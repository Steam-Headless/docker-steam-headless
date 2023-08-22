#!/usr/bin/env bash

echo "**** Installing/upgrading Sunshine via flatpak ****"

# Install Sunshine
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak --user install --assumeyes --or-update flathub dev.lizardbyte.app.Sunshine
# Configure any required overrides
flatpak --user override --talk-name=org.freedesktop.Flatpak dev.lizardbyte.app.Sunshine

# Configure Sunshine as the default browser
echo "Configure Sunshine..."
sunshine_autostart_desktop="$(cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Sunshine
Comment=Launch sunshine on login
Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=dev.lizardbyte.app.Sunshine.sh dev.lizardbyte.app.Sunshine
Icon=sunshine
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOF
)"
mkdir -p "${USER_HOME:?}/.config/autostart"
if [[ ! -f "${USER_HOME:?}/.config/autostart/Sunshine.desktop" ]]; then
    echo "${sunshine_autostart_desktop:?}" > "${USER_HOME:?}/.config/autostart/Sunshine.desktop"
fi
# Configure default launchers:
sunshine_apps_json="$(cat <<EOF
{
    "env": {
        "PATH": "\$(PATH):\$(HOME)\/.local\/bin"
    },
    "apps": [
        {
            "name": "Desktop",
            "image-path": "desktop.png"
        },
        {
            "name": "Low Res Desktop",
            "image-path": "desktop.png",
            "prep-cmd": [
                {
                    "do": "xrandr --output HDMI-1 --mode 1920x1080",
                    "undo": "xrandr --output HDMI-1 --mode 1920x1200"
                }
            ]
        },
        {
            "name": "Steam Big Picture",
            "image-path": "steam.png",
            "exclude-global-prep-cmd": "false",
            "detached": [
                "flatpak-spawn --host \/usr\/games\/steam steam:\/\/open\/bigpicture"
            ]
        }
    ]
}
EOF
)"
mkdir -p "${USER_HOME:?}/.config/sunshine"
if [[ ! -f "${USER_HOME:?}/.config/sunshine/apps.json" ]]; then
    echo "${sunshine_apps_json:?}" > "${USER_HOME:?}/.config/sunshine/apps.json"
fi

echo "DONE"
