#!/usr/bin/env bash
###
# File: run.sh
# Project: docker-steamos
# File Created: Saturday, 8th January 2022 2:34:23 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Monday, 10th January 2022 11:04:51 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

script_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
project_base_path=$(realpath ${script_path}/..);


if [[ ${1} == "stop" ]]; then
    docker stop steam-headless
    docker rm steam-headless
    exit $?
elif [[ ${1} == "tail" ]]; then
    docker logs -f steam-headless
    exit $?
elif [[ ${1} == "user" ]]; then
    docker exec -ti --user default steam-headless bash
    exit $?
elif [[ ${1} == "root" ]]; then
    docker exec -ti --user 0 steam-headless bash
    exit $?
fi


docker stop steam-headless
docker rm steam-headless
sleep 1


docker run -d --name='steam-headless' \
    --privileged=true  \
    --net='br0' --ip='192.168.1.208' \
    --cpuset-cpus='3,9,4,10,5,11'  \
    -e PUID="99"  \
    -e PGID="100"  \
    -e UMASK='000'  \
    -e USER_PASSWORD="password" \
    -e USER="default" \
    -e HOME="/home/test" \
    -e USER_HOME="/home/default" \
    -e TZ="Pacific/Auckland" \
    -e USER_LOCALES="en_US.UTF-8 UTF-8" \
    -e DISPLAY_CDEPTH="24" \
    -e DISPLAY_DPI="96" \
    -e DISPLAY_REFRESH="60" \
    -e DISPLAY_SIZEH="720" \
    -e DISPLAY_SIZEW="1280" \
    -e DISPLAY_VIDEO_PORT="DFP" \
    -e DISPLAY=":0" \
    -e NVIDIA_DRIVER_CAPABILITIES="all" \
    -e NVIDIA_VISIBLE_DEVICES="all" \
    -v "${project_base_path}/config/home/default":'/home/default':'rw'  \
    --hostname='steam-headless'  \
    --shm-size=2G \
    --runtime=nvidia \
    josh5/steam-headless:latest


docker logs -f steam-headless
