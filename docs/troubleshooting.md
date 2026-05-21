## Steam does not launch on ZimaOS / CasaOS

Symptoms:

- Steam appears in the process list but no window opens
- Desktop autostart logs show `Permission denied` under `~/.steam/`
- Running `steam` reports it is already running

This commonly affects ZimaOS and CasaOS App Store deployments. See [ZimaOS setup](./zimaos.md) for the full guide.

### Fix checklist

1. **Set `PUID=1000` and `PGID=1000`** in your environment. App Store templates sometimes default to `PUID=65534` (`nobody`), which cannot write to the persistent home volume.
2. **Clear `STEAM_ARGS`** — remove `-silent` until you have logged in at least once. A silent launch hides the Steam window and matches reports in [issue #207](https://github.com/Steam-Headless/docker-steam-headless/issues/207).
3. **Fix ownership** on the persistent home directory:

```shell
sudo chown -R 1000:1000 /opt/container-data/steam-headless/home
```

4. **Recreate** the container after changing environment variables (do not only restart).
5. Check logs:

```shell
docker exec steam-headless tail -50 /home/default/.cache/log/desktop.err.log
docker exec steam-headless tail -50 /home/default/.steam/debian-installation/logs/console-linux.txt
```

### NVIDIA hosts

If the above steps succeed but the Steam UI still does not render on NVIDIA hardware, try `NVIDIA_DRIVER_VERSION=535.154.05` and review [issue #207](https://github.com/Steam-Headless/docker-steam-headless/issues/207).

## Flatpaks not working

Steam runs with Flatpak. These Flatpaks are instlled into the `default` user's home directory so they persist between container updates. Sometimes Flatpaks can get into a knot between major Steam Headless updates. In such cases, it may not work correctly. To fix this, just delete the Flatpak runtime in your `default` user's home directory a restart the container.

1) Stop the container.
2) Delete the directory `<SteamHeadless Home>/.local/share/flatpak`
3) Re-create the container. Don't just restart it. This will trigger an update of the required Flatpak runtimes in the home directory.
4) Reinstall any missing Flatpaks from the Software app.

Once your Flatpak refresh is complete, everything should work correctly and your configuration for each application should have remained intact.

## An error occurred while installing <game>: "disk write error"

![img.png](./images/disk_write_error.png)

1) Stop the container
2) Verify your mounted /mnt/games volume is owned by the executing UID/GID, and 777 permissions are set.
3) Verify the `steamapps` directory exists within the library location. 

> __Note__
>
> The directory in the below commands are the default /mnt/games library locations installed upon first execution of this container.
> 
> Depending on how you have installed this, the directory path may vary.

```shell
sudo mkdir /mnt/games/GameLibrary/SteamLibrary/steamapps
sudo chmod -R 777 /mnt/games
sudo chown -R $(id -u):$(id -g) /mnt/games
```
