#!/usr/bin/env bash

echo "**** Installing/upgrading Flatseal via flatpak ****"

# Install Flatseal
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
flatpak --user install --assumeyes --or-update com.github.tchx84.Flatseal

# Configure Flatseal
echo "Configure Flatseal..."
sed -i 's/^Categories=.*$/Categories=Utility;/' \
    ${USER_HOME}/.local/share/flatpak/exports/share/applications/com.github.tchx84.Flatseal.desktop

echo "DONE"
