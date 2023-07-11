#!/usr/bin/env bash

echo "**** Configure Steam /mnt/games steamapps folder ****"

# Upon first execution of this container, /opt/scripts/install_steam.sh will create a library location named "Mounted
# Games into the /mnt/games/GameLibrary/SteamLibrary location, but not create the required steamapps folder"
# Check /mnt/games to see if it is configured as a Steam Library, and if it is, make sure the steamapps folder exists
MNT_LIBRARY_PATH="/mnt/games/GameLibrary/SteamLibrary"

if [ -f "$MNT_LIBRARY_PATH/libraryfolder.vdf" ] && [ ! -d "$MNT_LIBRARY_PATH/steamapps" ]; then
  mkdir -pm 777 "$MNT_LIBRARY_PATH/steamapps"
fi
