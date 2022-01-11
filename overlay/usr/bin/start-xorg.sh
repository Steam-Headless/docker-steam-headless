#!/usr/bin/env bash
###
# File: start-xorg.sh
# Project: bin
# File Created: Tuesday, 11th January 2022 8:28:52 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 11th January 2022 9:38:51 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

DISPLAY=${DISPLAY:-:55}
DISPLAY_DPI=${DPI:-:96}
XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/.X11-unix}


# Clear out old lock files
display_file=/tmp/.X11-unix/X${DISPLAY#:}
if [ -S ${display_file} ]; then
  LOG "Removing ${display_file} before starting"
  rm -f /tmp/.X${DISPLAY#:}-lock
  rm ${display_file}
fi


/usr/bin/Xorg -ac -noreset -novtswitch -sharevts -dpi "${DISPLAY_DPI}" +extension "GLX" +extension "RANDR" +extension "RENDER" vt7 "${DISPLAY}"
# /usr/bin/Xorg -ac -noreset -novtswitch -sharevts -dpi "${DISPLAY_DPI}" +extension "GLX" +extension "RANDR" +extension "RENDER" +extension "MIT-SHM" vt7 "${DISPLAY}"
# /usr/bin/Xorg -novtswitch -sharevts -dpi "${DISPLAY_DPI}" +extension "MIT-SHM" vt7 ${DISPLAY}
# /usr/bin/Xorg -novtswitch -sharevts -dpi "${DISPLAY_DPI}" +extension "MIT-SHM" "${DISPLAY}"
# /usr/bin/Xorg -ac -noreset +extension GLX +extension RANDR +extension RENDER vt7 "${DISPLAY}"
