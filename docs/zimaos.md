# ZimaOS / CasaOS

Use these instructions to install **Steam Headless** on [ZimaOS](https://www.zimaos.com/) (or other CasaOS-based systems).

ZimaOS deploys containers through its App Store UI, which generates a `docker-compose.yml` and `.env` automatically. That works well for basic setup, but a few ZimaOS defaults commonly prevent Steam from auto-launching or downloading its client on first boot. This guide documents the fixes validated on ZimaOS hardware.

> **Note**
>
> These steps assume Docker is already available on your ZimaOS device and that you can SSH in or use the terminal to edit files under your app install path (commonly `/opt/container-services/steam-headless` or a bind-mounted path such as `/DATA/.opt/container-services/steam-headless`).

---

## Known ZimaOS issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| Steam never opens; process exits immediately | `PUID=65534` (`nobody`) set by the App Store | Set `PUID=1000` and `PGID=1000` |
| `Permission denied` writing to `~/.steam/steam/logs` | Bootstrap or home files owned by `root` after host-side install | Run the helper script below to `chown` the persistent home |
| Steam runs but no window appears | `STEAM_ARGS=-silent` hides the UI | Leave `STEAM_ARGS` empty for first login |
| Desktop session errors on startup | Missing `~/.xbindkeysrc` | Add the `10-fix-xbindkeys.sh` init script |
| Slow first boot / Steam update prompt fails | Client bootstrap not yet present | Add the `00-install-steam.sh` init script |

These symptoms overlap with [issue #207](https://github.com/Steam-Headless/docker-steam-headless/issues/207). On ZimaOS with AMD or Intel GPUs, the root cause is usually **UID/GID and file ownership**, not NVIDIA driver version.

---

## Recommended paths

ZimaOS often stores application data on a large data volume. Adjust these to match your system:

| Purpose | Example path |
|---------|--------------|
| Compose + `.env` | `/opt/container-services/steam-headless` |
| Persistent home | `/opt/container-data/steam-headless/home` |
| Shared X11 / Pulse sockets | `/opt/container-data/steam-headless/sockets` |
| Games library | `/DATA/Games` (or any path you prefer) |

Inside the container, mount the games path to `/mnt/games`. Steam will use `/mnt/games/GameLibrary/Steam` as a library folder when initialized by the container.

---

## Quick setup (Docker Compose)

### 1. Prepare directories

Run as your normal user (not root):

```shell
sudo mkdir -p /opt/container-services/steam-headless
sudo mkdir -p /opt/container-data/steam-headless/{home,sockets/.X11-unix,sockets/pulse}
sudo mkdir -p /DATA/Games/GameLibrary/Steam/steamapps
sudo chown -R "$(id -u):$(id -g)" /opt/container-services/steam-headless
sudo chown -R "$(id -u):$(id -g)" /opt/container-data/steam-headless
sudo chown -R "$(id -u):$(id -g)" /DATA/Games
```

### 2. Copy the example files

From this repository:

- [docker-compose.zimaos.yml](./compose-files/docker-compose.zimaos.yml) → `/opt/container-services/steam-headless/docker-compose.yml`
- [.env.zimaos](./compose-files/.env.zimaos) → `/opt/container-services/steam-headless/.env`
- [scripts/up.zimaos.sh](./compose-files/scripts/up.zimaos.sh) → `/opt/container-services/steam-headless/up.sh`

Make the helper script executable:

```shell
chmod +x /opt/container-services/steam-headless/up.sh
```

### 3. Copy init scripts into the persistent home

These run on every container start via `~/init.d/*.sh`:

```shell
mkdir -p /opt/container-data/steam-headless/home/init.d
cp docs/compose-files/init.d/00-install-steam.sh /opt/container-data/steam-headless/home/init.d/
cp docs/compose-files/init.d/10-fix-xbindkeys.sh /opt/container-data/steam-headless/home/init.d/
chmod +x /opt/container-data/steam-headless/home/init.d/*.sh
```

If you cloned the repo elsewhere, adjust the `cp` source paths accordingly.

### 4. Edit `.env`

At minimum, verify:

```dotenv
PUID=1000
PGID=1000
STEAM_ARGS=
FORCE_X11_DUMMY_CONFIG=true
ENABLE_EVDEV_INPUTS=false
HOME_DIR=/opt/container-data/steam-headless/home
SHARED_SOCKETS_DIR=/opt/container-data/steam-headless/sockets
GAMES_DIR=/DATA/Games
USER_PASSWORD=your-secure-password
```

> **Warning**
>
> Do **not** use `PUID=65534`. ZimaOS/CasaOS App Store templates sometimes default to the `nobody` user, which breaks writes under `/home/default`.

### 5. Start the container

```shell
cd /opt/container-services/steam-headless
./up.sh
```

The helper script:

1. Pre-downloads the Steam bootstrap into the persistent home (optional but speeds first boot)
2. Fixes ownership on the home volume to match `PUID`/`PGID`
3. Migrates legacy `~/.steam/steam` directory layouts
4. Recreates the container with `docker compose`

### 6. Open the Web UI

Browse to:

```text
http://<zimaos-ip>:8083/
```

Default password is the value of `USER_PASSWORD` in `.env` (change it before exposing the host).

Log in to Steam from the XFCE desktop. Confirm **Settings → Storage** lists `/mnt/games/GameLibrary/Steam`.

---

## Deploying through the ZimaOS App Store

If you install from the App Store instead of manual Compose:

1. After install, open the app's compose / environment editor.
2. Set **`PUID=1000`** and **`PGID=1000`**.
3. Clear **`STEAM_ARGS`** (remove `-silent`).
4. Set **`FORCE_X11_DUMMY_CONFIG=true`** when no monitor is attached.
5. Add the two `init.d` scripts to your persistent home volume (see step 3 above).
6. **Recreate** the container (not just restart).

App Store-generated compose files may omit GPU device mappings. For AMD/Intel acceleration, compare your generated file with [docker-compose.zimaos.yml](./compose-files/docker-compose.zimaos.yml) and add the appropriate `/dev/dri/*` entries.

---

## NVIDIA on ZimaOS

If your ZimaOS device has an NVIDIA GPU and Steam starts but the window never appears, see [issue #207](https://github.com/Steam-Headless/docker-steam-headless/issues/207):

1. Remove `-silent` from `STEAM_ARGS`.
2. Try pinning the in-container driver: `NVIDIA_DRIVER_VERSION=535.154.05`
3. Use the modern Compose GPU reservation block (documented in the issue) instead of legacy `runtime: nvidia` where possible.

Also follow the [Ubuntu Server](./ubuntu-server.md) NVIDIA Container Toolkit steps if GPU passthrough is required.

---

## Troubleshooting

See the [Troubleshooting](./troubleshooting.md) page, especially **Steam does not launch on ZimaOS / CasaOS**.

Useful log locations inside the container:

```text
/home/default/.cache/log/desktop.err.log
/home/default/.steam/debian-installation/logs/console-linux.txt
/home/default/.steam/debian-installation/logs/bootstrap_log.txt
```

Quick checks:

```shell
docker exec steam-headless id default
docker exec steam-headless ls -la /home/default/.steam/debian-installation/
docker exec steam-headless ps aux | grep steam
```

Expected `id` output:

```text
uid=1000(default) gid=1000(default) groups=...
```
