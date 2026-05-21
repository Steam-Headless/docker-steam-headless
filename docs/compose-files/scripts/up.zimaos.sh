#!/usr/bin/env bash
# ZimaOS helper: prepare persistent home ownership, then recreate the container.
# See docs/zimaos.md for setup instructions.
set -euo pipefail

cd "$(dirname "$0")"

export DOCKER_CONFIG="${DOCKER_CONFIG:-/tmp/dockercfg-steam-headless}"
mkdir -p "$DOCKER_CONFIG"

PUID="$(grep -E '^PUID=' ./.env | cut -d= -f2-)"
PGID="$(grep -E '^PGID=' ./.env | cut -d= -f2-)"
HOME_DIR="$(grep -E '^HOME_DIR=' ./.env | cut -d= -f2-)"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
HOME_DIR="${HOME_DIR:-/opt/container-data/steam-headless/home}"

if [ "${PUID}" = "65534" ]; then
  cat >&2 <<'EOF'
ERROR: PUID=65534 (nobody) prevents Steam from writing to its home directory.
Set PUID=1000 and PGID=1000 in .env, then rerun this script.
See docs/zimaos.md for details.
EOF
  exit 1
fi

steamdir="${HOME_DIR}/.steam/debian-installation"
steam_home="${HOME_DIR}/.steam"
steam_version="1.0.0.83"
steam_sha256="791682b0cc7efd946c7002f917c9dd474d2619b7f9ed00891216a8a6b4ac8f82"
steam_url="https://repo.steampowered.com/steam/archive/beta/steam_${steam_version}.tar.gz"

if [ ! -x "$steamdir/steam.sh" ] || \
   [ ! -x "$steamdir/ubuntu12_32/steam" ] || \
   [ ! -x "$steamdir/ubuntu12_32/steam-runtime/run.sh" ] || \
   [ ! -x "$steamdir/ubuntu12_32/steam-runtime/setup.sh" ] || \
   [ "$(cat "$steamdir/deb-installer/version" 2>/dev/null || true)" != "$steam_version" ]; then
  mkdir -p "$steamdir/deb-installer"
  steam_tmp="$steamdir/deb-installer/steam_${steam_version}.tar.gz.$$"
  curl -fsSL -o "$steam_tmp" "$steam_url"
  printf '%s  %s\n' "$steam_sha256" "$steam_tmp" | sha256sum -c -
  tar -C "$steamdir/deb-installer" -zxf "$steam_tmp" \
    steam-launcher/bootstraplinux_ubuntu12_32.tar.xz \
    steam-launcher/icons \
    steam-launcher/steam.desktop
  mv "$steamdir/deb-installer/steam-launcher/bootstraplinux_ubuntu12_32.tar.xz" "$steamdir/bootstrap.tar.xz"
  rm -f "$steam_tmp"
  tar -C "$steamdir" -xf "$steamdir/bootstrap.tar.xz"
  printf '%s\n' "$steam_version" > "$steamdir/deb-installer/version"
fi

chown -R "${PUID}:${PGID}" "${HOME_DIR}" 2>/dev/null || \
  sudo chown -R "${PUID}:${PGID}" "${HOME_DIR}" 2>/dev/null || true

if [ -d "$steam_home/steam" ] && [ ! -L "$steam_home/steam" ]; then
  if [ -d "$steam_home/steam/steamapps" ] && [ ! -e "$steamdir/steamapps" ]; then
    mv "$steam_home/steam/steamapps" "$steamdir/steamapps"
  fi
  if [ -d "$steam_home/steam/config" ] && [ ! -e "$steamdir/config" ]; then
    mv "$steam_home/steam/config" "$steamdir/config"
  fi
  mv "$steam_home/steam" "$steam_home/steam.legacy"
  ln -sfn debian-installation "$steam_home/steam"
  ln -sfn debian-installation "$steam_home/root"
fi

xbindkeys_config="${HOME_DIR}/.xbindkeysrc"
if [ ! -e "$xbindkeys_config" ]; then
  : > "$xbindkeys_config" 2>/dev/null || true
fi

if docker version >/dev/null 2>&1; then
  DOCKER_BIN=(docker)
elif sudo docker version >/dev/null 2>&1; then
  DOCKER_BIN=(sudo docker)
else
  cat >&2 <<'EOF'
Docker daemon access is not available.
Add your user to the docker group or run this script with sudo.
EOF
  exit 1
fi

exec "${DOCKER_BIN[@]}" --config "$DOCKER_CONFIG" compose \
  -f docker-compose.yml \
  --env-file .env \
  up -d --force-recreate
