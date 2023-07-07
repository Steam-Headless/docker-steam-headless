#!/usr/bin/env bash
###
# File: start-kasmvnc.sh
# Project: bin
# File Created: Thursday, 1st January 1970 12:00:00 pm
# Author: Console and webGui login account (jsunnex@gmail.com)
# -----
# Last Modified: Saturday, 8th July 2023 4:44:25 am
# Modified By: Console and webGui login account (jsunnex@gmail.com)
###
set -e
source /usr/bin/common-functions.sh

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$kasmxproxy_pid" 2>/dev/null
    pkill --signal TERM -P "$xvnc_pid" 2>/dev/null
}
trap _term SIGTERM SIGINT


# EXECUTE PROCESS:
# Wait for the X server to start
wait_for_x
# Start the Xvnc server
# vncserver :88 -fg -noxstartup -websocketPort ${PORT_NOVNC_WEB:?} -disableBasicAuth -interface 0.0.0.0 -dry-run
#eval "$(vncserver :88 -fg -noxstartup -websocketPort ${PORT_NOVNC_WEB:?} -disableBasicAuth -interface 0.0.0.0 -dry-run)" &
## xvnc_command="$(vncserver :88 -fg -noxstartup -websocketPort 8438 -disableBasicAuth -interface 0.0.0.0 -dry-run)"
## bash -c "${xvnc_command}" &
# NOTE: I've run it like this because the -fg is not doing anything when executed with vncserver.
#   This prints the Xvnc command which is then executed.
vnc_server_args="${vnc_server_args:-} -hw3d -drinode /dev/dri/renderD128"

eval "$(vncserver :88 -fg -noxstartup -websocketPort ${PORT_NOVNC_WEB:?} -disableBasicAuth -interface 0.0.0.0 ${vnc_server_args:-} -dry-run)" &
xvnc_pid=$!
# Wait a few seconds for the Xvnc service to start
sleep 3
# Start the Kasm X Proxy
kasmxproxy -a :55 -v :88 &
kasmxproxy_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$xvnc_pid"
wait "$kasmxproxy_pid"
