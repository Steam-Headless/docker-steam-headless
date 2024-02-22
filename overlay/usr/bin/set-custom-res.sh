#!/bin/bash
###
# File: set-custom-res.sh
# Project: bin
# Author: LyzardByte Community Docs
###

# Get params and set any defaults
width=${1:-1920}
height=${2:-1080}
refresh_rate=${3:-60}

# You may need to adjust the scaling differently so the UI/Text isn't too small / big
scale=${4:-1}

# Get the name of the active display
display_output=$(xrandr | grep " connected" | awk '{print $1 }')

# Get the modeline info from the 2nd row in the cvt output
modeline=$(cvt ${width} ${height} ${refresh_rate} | awk 'FNR == 2')
xrandr_mode_str=${modeline//Modeline \"*\" /}
mode_alias="${width}x${height}"

echo "xrandr setting new mode ${mode_alias} ${xrandr_mode_str}"
xrandr --newmode ${mode_alias} ${xrandr_mode_str}
xrandr --addmode ${display_output} ${mode_alias}

# Reset Scaling
xrandr --output ${display_output} --scale ${scale}

# Apply new xrandr mode
xrandr --output ${display_output} --primary --mode ${mode_alias} --pos 0x0 --rotate normal --scale ${scale}

# Optionally reset your wallpaper
# xwallpaper --zoom /path/to/wallpaper.png
