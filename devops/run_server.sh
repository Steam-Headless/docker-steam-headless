#!/usr/bin/env bash
###
# File: run.sh
# Project: docker-steamos
# File Created: Saturday, 8th January 2022 2:34:23 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 11th January 2022 9:43:50 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
project_base_path=$(realpath ${script_path}/..);


# Parse params
additional_docker_params=""
container_name="steam"
for ARG in ${@}; do
    case ${ARG} in
        *primary)
            primary="true";
            ;;
        *nvidia)
            nvidia="true";
            ;;
        *hostx)
            hostx="true";
            ;;
        *fb)
            framebuffer="true";
            ;;
        stop)
            script_mode="stop"
            ;;
        tail)
            script_mode="tail"
            ;;
        user)
            script_mode="user"
            ;;
        root)
            script_mode="root"
            ;;
        *)
            ;;
    esac
done
if [[ "${primary}" == "true" ]]; then
    container_name="${container_name}-p"
    additional_docker_params="${additional_docker_params} -e MODE='primary'"
    hostx="false"
else
    container_name="${container_name}-s"
    additional_docker_params="${additional_docker_params} -e MODE='secondary'"
    framebuffer="false"
fi
if [[ "${hostx}" == "true" ]]; then
    container_name="${container_name}-hx"
    additional_docker_params="${additional_docker_params} -v /tmp/.X11-unix:/tmp/.X11-unix"
    additional_docker_params="${additional_docker_params} -e MODE='secondary'"
    nvidia="false"
    framebuffer="false"
else
    additional_docker_params="${additional_docker_params} -v /tmp/headless/.X11-unix:/tmp/.X11-unix"
fi
if [[ "${nvidia}" == "true" ]]; then
    container_name="${container_name}-hw"
    additional_docker_params="${additional_docker_params} --runtime=nvidia"
    framebuffer="false"
fi
if [[ "${framebuffer}" == "true" ]]; then
    # TODO: Enable xvfb
    container_name="${container_name}-fb"
fi


# If a mode was given, run that instead
if [[ "${script_mode}" == "stop" ]]; then
    docker stop ${container_name}
    docker rm ${container_name}
    exit $?
elif [[ "${script_mode}" == "tail" ]]; then
    docker logs -f ${container_name}
    exit $?
elif [[ "${script_mode}" == "user" ]]; then
    docker exec -ti --user default ${container_name} bash
    exit $?
elif [[ "${script_mode}" == "root" ]]; then
    docker exec -ti --user 0 ${container_name} bash
    exit $?
fi


# Stop previous instance
docker stop ${container_name}
docker rm ${container_name}
sleep 1


# Run
docker run -d --name="${container_name}" \
    --privileged=true \
    --ipc="host" \
    -e PUID="99"  \
    -e PGID="100"  \
    -e UMASK="000"  \
    -e USER_PASSWORD="password" \
    -e USER="default" \
    -e USER_HOME="/home/default" \
    -e TZ="Pacific/Auckland" \
    -e USER_LOCALES="en_US.UTF-8 UTF-8" \
    -e DISPLAY_CDEPTH="24" \
    -e DISPLAY_DPI="96" \
    -e DISPLAY_REFRESH="60" \
    -e DISPLAY_SIZEH="720" \
    -e DISPLAY_SIZEW="1280" \
    -e DISPLAY_VIDEO_PORT="DFP" \
    -e DISPLAY=":55" \
    -e NVIDIA_DRIVER_CAPABILITIES="all" \
    -e NVIDIA_VISIBLE_DEVICES="all" \
    -p 8083:8083 \
    -p 32123:32123 \
    -v "${project_base_path}/config/home/default-${container_name}":"/home/default":"rw"  \
    -v "/tmp/":"/tmp/":"rw"  \
    --hostname="${container_name}" \
    --shm-size=2G \
    ${additional_docker_params} \
    josh5/steam-headless:develop


docker logs -f ${container_name}
