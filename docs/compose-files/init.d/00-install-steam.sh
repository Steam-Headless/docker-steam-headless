#!/bin/sh
# Pre-download the Steam bootstrap on container start when missing.
# Copy to: <HOME_DIR>/init.d/00-install-steam.sh
set -eu

steamdir=/home/default/.steam/debian-installation
version=1.0.0.83
sha256=791682b0cc7efd946c7002f917c9dd474d2619b7f9ed00891216a8a6b4ac8f82
url=https://repo.steampowered.com/steam/archive/beta/steam_1.0.0.83.tar.gz

if [ -x "$steamdir/steam.sh" ] && \
   [ -x "$steamdir/ubuntu12_32/steam" ] && \
   [ -x "$steamdir/ubuntu12_32/steam-runtime/run.sh" ] && \
   [ -x "$steamdir/ubuntu12_32/steam-runtime/setup.sh" ] && \
   [ "$(cat "$steamdir/deb-installer/version" 2>/dev/null || true)" = "$version" ]; then
  exit 0
fi

mkdir -p "$steamdir/deb-installer"
tmp="$steamdir/deb-installer/steam_${version}.tar.gz.$$"
curl -fsSL -o "$tmp" "$url"
echo "$sha256  $tmp" | sha256sum -c -
tar -C "$steamdir/deb-installer" -zxf "$tmp" \
  steam-launcher/bootstraplinux_ubuntu12_32.tar.xz \
  steam-launcher/icons \
  steam-launcher/steam.desktop
test -f "$steamdir/deb-installer/steam-launcher/bootstraplinux_ubuntu12_32.tar.xz"
mv "$steamdir/deb-installer/steam-launcher/bootstraplinux_ubuntu12_32.tar.xz" "$steamdir/bootstrap.tar.xz"
rm -f "$tmp"
tar -C "$steamdir" -xf "$steamdir/bootstrap.tar.xz"
mkdir -p "$steamdir/deb-installer"
printf "%s\n" "$version" > "$steamdir/deb-installer/version"
chown -R "${PUID:-1000}:${PGID:-1000}" "$steamdir" 2>/dev/null || true
