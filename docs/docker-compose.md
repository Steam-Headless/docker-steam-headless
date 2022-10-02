# Unraid

Follow these instructions to configure a docker-compose.yml for your system.

> __Note__
>
> These instructions assume that you have docker and docker-compose installed for your system.
> Depending on how you have installed this, the commands to execute docker compose may vary.


## PREPARE DIRECTORY:

> __Note__
>
> These commands are ment to be run as your user. Do not run them as root. If you do you should manually fix the permissions and ownership after.

Create a directory for your service:
```
sudo mkdir -p /opt/container-services/steam-headless
sudo chown -R $(id -u):$(id -g) /opt/container-services/steam-headless
```

Create a directory for your service config data:
```
sudo mkdir -p /opt/container-data/steam-headless/{home,.X11-unix,pulse}
sudo chown -R $(id -u):$(id -g) /opt/container-data/steam-headless
```

Create a Steam Headless docker-compose.yml file:
```
touch /opt/container-services/steam-headless/docker-compose.yml
```

Select from the [COMPOSE FILES](#compose-files) list below the link that best describes your hardware.

Copy the contents of this file to `/opt/container-services/steam-headless/docker-compose.yml`


## CONFIGURE ENV:

Create a Steam Headless `/opt/container-services/steam-headless/.env` file with the contents found in this example [Env File](./compose-files/.env).

Edit these variables as requied.


## COMPOSE FILES:

- [Intel CPU only](../docker-compose.intel.yml) 
