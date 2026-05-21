#!/bin/sh
# Prevent the XFCE xbindkeys autostart hook from failing when no config exists.
# Copy to: <HOME_DIR>/init.d/10-fix-xbindkeys.sh
install -m 0644 /dev/null /home/default/.xbindkeysrc
