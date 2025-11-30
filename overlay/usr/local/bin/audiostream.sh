#!/usr/bin/env bash
set -e
# Simple TCP audio forwarder for VNC audio channel
PORT="${PORT_AUDIO_STREAM:-32037}"
socket="${PULSE_SOCKET_DIR:-/tmp/pulse}/pulse-socket"
gst_cmd="gst-launch-1.0 -q pulsesrc server=${socket} ! audio/x-raw,channels=2,rate=24000 ! cutter ! opusenc ! webmmux ! fdsink fd=1"
exec socat TCP-LISTEN:${PORT},fork,reuseaddr "EXEC:${gst_cmd}"
