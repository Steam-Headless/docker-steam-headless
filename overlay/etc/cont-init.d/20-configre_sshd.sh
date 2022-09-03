
echo "**** Configure SSH server ****"

if [[ "X${PORT_SSH:-}" != "X" ]]; then
    # Generate new SSH host keys if they dont exist
    if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
        echo "**** Generating SSH keys ****";
        /usr/bin/ssh-keygen -A
    fi
    mkdir -p /run/sshd
    chmod 744 /run/sshd

    echo "Set port to '${PORT_SSH}'"
    sed -i "s|^#   Port 22.*$|Port ${PORT_SSH}|" /etc/ssh/ssh_config
else
    echo "Disable SSH server"
    # Disable supervisord script
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/sshd.ini
fi

echo "DONE"
