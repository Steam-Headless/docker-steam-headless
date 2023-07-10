## Flatpaks not working

Steam runs with Flatpak. These Flatpaks are instlled into the `default` user's home directory so they persist between container updates. Sometimes Flatpaks can get into a knot between major Steam Headless updates. In such cases, it may not work correctly. To fix this, just delete the Flatpak runtime in your `default` user's home directory a restart the container.

1) Stop the container.
2) Delete the directory `~/.local/share/flatpak`
3) Re-create the container. Don't just restart it. This will trigger an update of the required Flatpak runtimes in the home directory.
4) Reinstall any missing Flatpaks from the Software app.

Once your Flatpak refresh is complete, everything should work correclty and your configuration for each application should have remained intact.