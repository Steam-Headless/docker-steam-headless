#!/usr/bin/env bash
###
# File: start-plugins.sh
# Project: bin
# File Created: Sunday, 5th February 2023 10:07:02 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Sunday, 5th February 2023 11:55:11 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
set -e
source /usr/bin/common-functions.sh


# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$plugins_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


echo "USER: $USER"
echo "HOME: $HOME"
echo "ENABLED_PLUGINS: $ENABLED_PLUGINS"

# CONFIGURE:
# Set the plugins project directory
plugins_dir="/home/${USER}/.local/share/steam-headless-plugins2"
# Clone plugins project
mkdir -p "/home/${USER}/.local/share"
if [[ ! -d "${plugins_dir}" ]]; then
    git clone --depth=1 \
        https://github.com/Steam-Headless/plugins.git \
        "${plugins_dir}"
fi
# Pull latest project
pushd "${plugins_dir}" &> /dev/null || exit 1
git clean -fdx
git checkout . 2> /dev/null
git checkout master 2> /dev/null
git pull origin master 2> /dev/null
popd &> /dev/null || exit 1


# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_docker
pushd "${plugins_dir}" &> /dev/null || exit 1
## # Pull latest Docker images
## ${plugins_dir}/plugins-run pull
## # Run docker images (not in background)
## ${plugins_dir}/plugins-run up &
sleep 300
plugins_pid=$!
popd &> /dev/null || exit 1


# WAIT FOR CHILD PROCESS:
wait "$plugins_pid"
