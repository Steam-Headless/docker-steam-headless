#!/usr/bin/env bash
###
# File: install_legendary.sh
# Project: scripts
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Sunday, 16th January 2022 5:44:25 am
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

pkg=legendary
script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
script_name=$( basename "${BASH_SOURCE[0]}" )

github_get_all_release() {
    REPO="${1}";
    curl --silent "https://api.github.com/repos/${REPO}/releases" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/';
}

install() {
    if ! command -v ${pkg} >/dev/null; then
        # Download/install the latest legendary binary
        latest_release=$(github_get_all_release derrod/legendary | head -n1)
        download_url="https://github.com/derrod/legendary/releases/download/${latest_release}/legendary"
        wget -O "/tmp/legendary-${latest_release}" "${download_url}"
        chmod +x /tmp/legendary-${latest_release}
        cp -f /tmp/legendary-${latest_release} /usr/bin/legendary-${latest_release}
        rm -f /usr/bin/legendary
        ln -s /usr/bin/legendary-${latest_release} /usr/bin/legendary
    fi

    if ! command -v rare >/dev/null; then
        # Install rare for a gui
        python3 -m pip install Rare
    fi

    if ! command -v steam-legendary-wrapper >/dev/null; then
        # Download/install the steam-legendary-wrapper script 
        wget -O "/tmp/steam-legendary-wrapper.sh" \
            "https://raw.githubusercontent.com/toalex77/steam-legendary-wrapper/main/steam-legendary-wrapper.sh"
        chmod +x /tmp/steam-legendary-wrapper.sh
        rm -f /usr/bin/steam-legendary-wrapper
        cp -f /tmp/steam-legendary-wrapper.sh /usr/bin/steam-legendary-wrapper
    fi

    # Remove installer shortcut
    rm -f /usr/share/applications/install.legendary.desktop

# Add launcher shortcut
cat << EOF > /usr/share/applications/rare.desktop
[Desktop Entry]
Name=Rare - (Epic Games Store)
Comment=A frontend for legendary, the open source Epic Games Store alternative
GenericName=Rare - (Epic Games Store)
X-GNOME-FullName=Rare - (Epic Games Store)
Exec=/usr/local/bin/rare %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=rare
Categories=Game;
EOF
}


#INSTALLER:
source "${script_path}/installer.sh"
