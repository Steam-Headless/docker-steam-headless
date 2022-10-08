#!/usr/bin/env bash
###
# File: start-dind.sh
# Project: bin
# File Created: Saturday, 8th October 2022 1:49:45 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Saturday, 8th October 2022 1:49:45 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###
set -e


# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$docker_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# CONFIGURE:
#   Refrences:
#       - https://raw.githubusercontent.com/docker/docker/42b1175eda071c0e9121e1d64345928384a93df1/hack/dind
#
# apparmor sucks and Docker needs to know that it's in a container (c) @tianon
export container=docker
if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security; then
	mount -t securityfs none /sys/kernel/security || {
		echo >&2 'Could not mount /sys/kernel/security.'
		echo >&2 'AppArmor detection and --privileged mode might break.'
	}
fi
# cgroup v2: enable nesting
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
	# move the processes from the root group to the /init group,
	# otherwise writing subtree_control fails with EBUSY.
	# An error during moving non-existent process (i.e., "cat") is ignored.
	mkdir -p /sys/fs/cgroup/init
	xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
	# enable controllers
	sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
		> /sys/fs/cgroup/cgroup.subtree_control
fi


# EXECUTE PROCESS:
/usr/local/bin/dockerd &
docker_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$docker_pid"
