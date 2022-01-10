# Configure system paths
echo "**** Configure system paths ****";
sed -i "/  <user>/c\  <user>${USER}</user>" /usr/share/dbus-1/system.conf
if [ ! -d /tmp/xdg ]; then
	mkdir -p /tmp/xdg
fi

echo "Configure dbus";
# Remove old dbus session
rm -rf ${USER_HOME}/.dbus/session-bus/* 2> /dev/null
# Remove old dbus pids
mkdir -p /var/run/dbus
chown -R ${PUID}:${PGID} /var/run/dbus/
chmod -R 770 /var/run/dbus/
# Generate a dbus machine ID
dbus-uuidgen > /var/lib/dbus/machine-id

echo "Configure X Windows context"
chown -R ${PUID}:${PGID} /tmp/xdg
chmod -R 0700 /tmp/xdg

echo "Configure X Windows session"
rm -rfv /tmp/.ICE-unix*
mkdir -p /tmp/.ICE-unix
chown root:root /tmp/.ICE-unix/
chmod 1777 /tmp/.ICE-unix/

echo "Remove old lockfiles"
find /var/run/dbus -name "pid" -exec rm -f {} \;
find /tmp -name ".X99*" -exec rm -f {} \;

echo "DONE"
