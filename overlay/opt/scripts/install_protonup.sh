#!/usr/bin/env bash

echo "**** Installing/upgrading ProtonUp-Qt via flatpak ****"

# Install ProtonUp-Qt
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
flatpak --user install --assumeyes --noninteractive --or-update net.davidotek.pupgui2

# Configure Firefox as the default browser
echo "Configure ProtonUp-Qt..."
sed -i 's/^Categories=.*$/Categories=Utility;/' \
    ${USER_HOME}/.local/share/flatpak/exports/share/applications/net.davidotek.pupgui2.desktop

echo "DONE"
