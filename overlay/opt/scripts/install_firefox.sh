#!/usr/bin/env bash

echo "**** Installing/upgrading Firefox via flatpak ****"

# Install Firefox
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
flatpak --user install --assumeyes --or-update flathub org.mozilla.firefox

# Configure Firefox as the default browser
echo "Configure Firefox..."
custom_webbrowser="$(cat <<EOF
"libraryfolders"
[Desktop Entry]
NoDisplay=true
Version=1.0
Encoding=UTF-8
Type=X-XFCE-Helper
X-XFCE-Category=WebBrowser
X-XFCE-CommandsWithParameter=${USER_HOME:?}/.local/share/flatpak/exports/bin/org.mozilla.firefox "%s"
Icon=org.mozilla.firefox
Name=org.mozilla.firefox
X-XFCE-Commands=${USER_HOME:?}/.local/share/flatpak/exports/bin/org.mozilla.firefox
EOF
)"
if [[ ! -f "${USER_HOME:?}/.local/share/xfce4/helpers/custom-WebBrowser.desktop"  ]]; then
    mkdir -p "${USER_HOME:?}/.local/share/xfce4/helpers"
    echo "${custom_webbrowser}" > "${USER_HOME:?}/.local/share/xfce4/helpers/custom-WebBrowser.desktop"
    gio mime x-scheme-handler/http org.mozilla.firefox.desktop
fi

echo "DONE"
