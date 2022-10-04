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

# CATCH TERM SIGNAL:
_term() {
    kill -TERM "$sunshine_pid" 2>/dev/null
}
trap _term SIGTERM


# CONFIGURE:
# TODO: Install default configurations
# Reset the default username/password
if ([ "X${SUNSHINE_USER:-}" != "X" ] && [ "X${SUNSHINE_PASS:-}" != "X" ]); then
    sunshine /home/${USER}/sunshine/sunshine.conf --creds ${SUNSHINE_USER:-} ${SUNSHINE_PASS:-}
fi


# EXECUTE PROCESS:
# Wait for X server to start
#   (Credit: https://gist.github.com/tullmann/476cc71169295d5c3fe6)
MAX=60 # About 30 seconds
CT=0
while ! xdpyinfo >/dev/null 2>&1; do
    sleep 0.50s
    CT=$(( CT + 1 ))
    if [ "$CT" -ge "$MAX" ]; then
        LOG "FATAL: $0: Gave up waiting for X server $DISPLAY"
        exit 11
    fi
done
sunshine min_log_level=info /home/${USER}/sunshine/sunshine.conf &
sunshine_pid=$!


# WAIT FOR CHILD PROCESS:
wait "$sunshine_pid"
