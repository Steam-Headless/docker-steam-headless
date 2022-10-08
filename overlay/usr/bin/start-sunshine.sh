#!/usr/bin/env bash
###
# File: start-sunshine.sh
# Project: bin
# File Created: Tuesday, 4th October 2022 8:22:17 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 4th October 2022 8:22:17 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$sunshine_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# CONFIGURE:
# Install default configurations
mkdir -p /home/${USER}/sunshine
if [[ ! -f /home/${USER}/sunshine/sunshine.conf ]]; then
    cp -vf /templates/sunshine/* /home/${USER}/sunshine/
    # TODO: Set the default encoder '# encoder = nvenc'
    # nvidia_gpu_id=$(get_nvidia_gpu_id)
    # if [[ "X${nvidia_gpu_id:-}" != "X" ]]; then
    #     if [[ "all video" == *"${NVIDIA_DRIVER_CAPABILITIES}"* ]]; then
    #         # Check if we have a nvidia GPU available
    #         sed -i 's|^# encoder.*=.*$|encoder = nvenc|' /home/${USER}/sunshine/sunshine.conf 
    #     fi
    # else
    #     # TODO: Enable the vaapi device if not using nvenc
    #     #       vainfo --display drm --device /dev/dri/renderD128 2> /dev/null | grep -E "((VAProfileH264High|VAProfileHEVCMain|VAProfileHEVCMain10).*VAEntrypointEncSlice)"
    #     # Loop over any render devices
    #     echo 
    # fi
fi

# Reset the default username/password
if ([ "X${SUNSHINE_USER:-}" != "X" ] && [ "X${SUNSHINE_PASS:-}" != "X" ]); then
    sunshine /home/${USER}/sunshine/sunshine.conf --creds ${SUNSHINE_USER:-} ${SUNSHINE_PASS:-}
fi


# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Start the sunshine server
sunshine /home/${USER}/sunshine/sunshine.conf &
sunshine_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$sunshine_pid"
