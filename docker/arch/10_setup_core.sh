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
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
    sudo chmod 755 /etc # to fix permissions issues from arch base
    pacman -Syu --noconfirm
    pacman-key --init
    pacman-key --populate archlinux
}

set_locales() {
    echo "**** Configure locales ****"
    echo -e ${USER_LOCALES} > /etc/locale.gen
    locale-gen
}

# Batch install from list
paclist_build() {
    echo "**** Install packages from backup list ****"
    sed -e "/^#/d" -e "s/#.*//" /tmp/pkglist.txt | pacman -S --needed --noconfirm -
    echo "Done installing packages, cleaning up"
    pacman -Scc --noconfirm
    echo ""
}

update_repo
set_locales
paclist_build
