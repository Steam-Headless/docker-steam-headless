#!/usr/bin/env bash
###
# File: entrypoint.sh
# Project: docker-steam-headless
# File Created: Saturday, 8th January 2022 7:08:46 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Saturday, 22nd January 2022 8:03:33 pm
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###

set -e

# If a command was passed, run that instead of the usual init process
if [ ! -z "$@" ]; then
    exec $@
    exit $?
fi

# Print the current version (if the file exists)
if [[ -f /version.txt ]]; then
    cat /version.txt
fi

function print_header {
    # Magenta
    echo -e "\e[35m**** ${@} ****\e[0m"
}

function print_step_header {
    # Cyan
    echo -e "\e[36m  - ${@}\e[0m"
}

function print_warning {
    # Yellow
    echo -e "\e[33mWARNING: ${@}\e[0m"
}

function print_error {
    # Red
    echo -e "\e[31mERROR: ${@}\e[0m"
}

# Execute all container init scripts
for init_script in /etc/cont-init.d/*.sh ; do
    echo
    echo -e "\e[34m[ ${init_script:?}: executing... ]\e[0m"
    sed -i 's/\r$//' "${init_script:?}"
    source "${init_script:?}"
done
touch /tmp/.first-run-init-scripts

# Execute any user generated init scripts
mkdir -p ${USER_HOME:?}/init.d
chown -R ${USER:?} ${USER_HOME:?}/init.d
for user_init_script in ${USER_HOME:?}/init.d/*.sh ; do

    # Check that a file was found 
    # (If no files exist in this directory, then user_init_script will be empty)
    if [[ -e "${user_init_script:?}" ]]; then
        
        echo
        echo -e "\e[34m[ USER:${user_init_script:?}: executing... ]\e[0m"
        sed -i 's/\r$//' "$(readlink -e "${user_init_script:?}")"

        # Execute user script in sub process with 'set +e'. 
        # This way if it is messed up, we dont get caught in an init loop.
        chmod +x "${user_init_script:?}"
        (
            set +e
            "${user_init_script:?}" ||  echo -e "\e[31mERROR: \e[33mFailed to execute user script '${user_init_script:?}'\e[0m" 
        )

    fi

done
touch /tmp/.first-run-user-init-scripts

# Start supervisord
echo
print_header "Starting supervisord";
print_step_header "Logging all root services to '/var/log/supervisor/'"
print_step_header "Logging all user services to '/home/${USER:?}/.cache/log/'"
echo
mkdir -p /var/log/supervisor
chmod a+rw /var/log/supervisor
exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon --user root
