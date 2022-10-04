#!/bin/bash

# Installs packages needed for compilation inside docker image.

# Exit on error
set -o errexit
set -o errtrace

# Enable tracing of what gets executed
#set -o xtrace

update_repo() {
    echo "**** Update package manager ****"
    sed -i 's/^NoProgressBar/#NoProgressBar/g' /etc/pacman.conf
    pacman -Syu --noconfirm
    pacman-key --init
    pacman-key --populate archlinux
}

set_locales() {
    echo "**** Configure locales ****"
    echo -e "${USER_LOCALES}" > "/etc/locale.gen"
    locale-gen
}

# Batch install from list ~85s
paclist_build() {
    echo "**** Install packages from backup list ****"
    pacman -S --needed --noconfirm - < /tmp/pkglist.txt

    echo "Done installing packages, cleaning up"
    pacman -Scc --noconfirm
    echo ""
}

update_repo
set_locales
paclist_build