
echo "**** Configure Flatpak ****"

if [ "X${NVIDIA_VISIBLE_DEVICES:-}" != "X" ]; then
    # Fix some flatpak quirks (not sure what is happening here) for NVIDIA containers
    mount -t proc none /proc
    flatpak list
    echo "Flatpak configured for running inside a Docker container"
else
    echo "Flatpak already configured for running inside a Docker container"
fi

echo "DONE"
