#!/usr/bin/env bash
###
# File: entrypoint.sh
# Project: docker-steamos
# File Created: Saturday, 8th January 2022 7:08:46 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 11th January 2022 8:44:17 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

set -e

# If a command was passed, run that instead of the usual init process
if [ ! -z "$@" ]; then
    exec $@
    exit $?
fi

# Execute all init scripts
for init_script in /scripts/*.sh ; do
    echo
    echo "[ ${init_script}: executing... ]"
    sed -i 's/\r$//' "${init_script}"
    source "${init_script}"
done

# Execute any user generated init scripts
mkdir -p ${USER_HOME}/init.d
chown -R ${USER} ${USER_HOME}/init.d
for user_init_script in ${USER_HOME}/init.d/*.sh ; do

    # Check that a file was found 
    # (If no files exist in this directory, then user_init_script will be empty)
    if [[ -e "${user_init_script}" ]]; then
        
        echo
        echo "[ USER:${user_init_script}: executing... ]"
        sed -i 's/\r$//' "${user_init_script}"
        source "${user_init_script}"

    fi

done

echo "**** Starting supervisord ****";
mkdir -p /var/log/supervisor
chmod a+rw /var/log/supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon --user root
