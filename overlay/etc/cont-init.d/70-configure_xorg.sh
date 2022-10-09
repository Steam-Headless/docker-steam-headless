
# Fech NVIDIA GPU device (if one exists)
if [ "${NVIDIA_VISIBLE_DEVICES:-}" == "all" ]; then
    export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
elif [ -z "${NVIDIA_VISIBLE_DEVICES:-}" ]; then
    export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
else
    export gpu_select=$(nvidia-smi --format=csv --id=$(echo "$NVIDIA_VISIBLE_DEVICES" | cut -d ',' -f1) --query-gpu=uuid | sed -n 2p)
    if [ -z "$gpu_select" ]; then
        export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
    fi
fi

export nvidia_gpu_hex_id=$(nvidia-smi --format=csv --query-gpu=pci.bus_id --id="${gpu_select}" 2> /dev/null | sed -n 2p)

# Fech current configuration (if modified in UI)
if [ -f "${USER_HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml" ]; then
    new_display_sizew=$(cat ${USER_HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml | grep Resolution | head -n1 | grep -oP '(?<=value=").*?(?=")' | cut -d'x' -f1)
    new_display_sizeh=$(cat ${USER_HOME}/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml | grep Resolution | head -n1 | grep -oP '(?<=value=").*?(?=")' | cut -d'x' -f2)
    if [ "${new_display_sizew}x" != "x" ] && [ "${new_display_sizeh}x" != "x" ]; then
        export DISPLAY_SIZEW="${new_display_sizew}"
        export DISPLAY_SIZEH="${new_display_sizeh}"
    fi
fi

# Configure a NVIDIA X11 config
function configure_nvidia_x_server {
    echo "Configuring X11 with GPU ID: '${gpu_select}'"
    nvidia_gpu_hex_id=$(nvidia-smi --format=csv --query-gpu=pci.bus_id --id="${gpu_select}" 2> /dev/null | sed -n 2p)
    IFS=":." ARR_ID=(${nvidia_gpu_hex_id})
    unset IFS
    bus_id=PCI:$((16#${ARR_ID[1]})):$((16#${ARR_ID[2]})):$((16#${ARR_ID[3]}))
    echo "Configuring X11 with PCI bus ID: '${bus_id}'"
    export MODELINE=$(cvt -r "${DISPLAY_SIZEW}" "${DISPLAY_SIZEH}" "${DISPLAY_REFRESH}" | sed -n 2p)
    echo "Writing X11 config with ${MODELINE}"
    nvidia-xconfig --virtual="${DISPLAY_SIZEW}x${DISPLAY_SIZEH}" --depth="${DISPLAY_CDEPTH}" --mode=$(echo "${MODELINE}" | awk '{print $2}' | tr -d '"') --allow-empty-initial-configuration --no-probe-all-gpus --busid="${bus_id}" --only-one-x-screen --connected-monitor="${DISPLAY_VIDEO_PORT}"
    sed -i '/Driver\s\+"nvidia"/a\    Option         "ModeValidation" "NoMaxPClkCheck, NoEdidMaxPClkCheck, NoMaxSizeCheck, NoHorizSyncCheck, NoVertRefreshCheck, NoVirtualSizeCheck, NoExtendedGpuCapabilitiesCheck, NoTotalSizeCheck, NoDualLinkDVICheck, NoDisplayPortBandwidthCheck, AllowNon3DVisionModes, AllowNonHDMI3DModes, AllowNonEdidModes, NoEdidHDMI2Check, AllowDpInterlaced"' /etc/X11/xorg.conf
    sed -i '/Section\s\+"Monitor"/a\    '"${MODELINE}" /etc/X11/xorg.conf
}

# Allow anybody for running x server
function configure_x_server {
    # Configure x to be run by anyone
    if grep -Fxq "allowed_users=console" /etc/X11/Xwrapper.config; then
        echo "Configure Xwrapper.config"
        sed -i "s/allowed_users=console/allowed_users=anybody/" /etc/X11/Xwrapper.config
    fi

    # Remove previous Xorg config
    rm -f /etc/X11/xorg.conf

    # Ensure the X socket path exists
    mkdir -p ${XORG_SOCKET_DIR}

    # Clear out old lock files
    display_file=${XORG_SOCKET_DIR}/X${DISPLAY#:}
    if [ -S ${display_file} ]; then
        echo "Removing ${display_file} before starting"
        rm -f /tmp/.X${DISPLAY#:}-lock
        rm ${display_file}
    fi

    # Ensure X-windows session path is owned by root 
    mkdir -p /tmp/.ICE-unix
    chown root:root /tmp/.ICE-unix/
    chmod 1777 /tmp/.ICE-unix/

    # Check if this container is being run as a secondary instance
    if [ "${MODE}" == "p" ] | [ "${MODE}" == "primary" ]; then
        echo "Configure container as primary the X server"
        # Enable supervisord script
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/xorg.ini
    elif [ "${MODE}" == "fb" ] | [ "${MODE}" == "framebuffer" ]; then
        echo "Configure container to use a virtual framebuffer as the X server"
        # Disable xorg supervisord script
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/xorg.ini
        # Enable xvfb supervisord script
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/xvfb.ini
    fi

    # Enable KB/Mouse input capture with Xorg if configured
    if [ ${ENABLE_EVDEV_INPUTS:-} = "true" ]; then
        echo "Enabling evdev input class on pointers, keyboards, touchpads, touch screens, etc."
        cp -fv /usr/share/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/10-evdev.conf
    else
        echo "Leaving evdev inputs disabled"
    fi

    monitor_connected=$(cat /sys/class/drm/card*/status | awk '/^connected/ { print $1; }' | head -n1)
    if [[ "X${monitor_connected}" == "X" ]]; then
        echo "No monitors connected. Installing dummy xorg.conf"
        # Use a dummy display input
        cp -fv /templates/xorg/xorg.dummy.conf /etc/X11/xorg.conf
    fi
}

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [[ -z ${nvidia_gpu_hex_id} ]]; then
        echo "**** Generate default xorg.conf ****";
        configure_x_server
    else
        echo "**** Generate NVIDIA xorg.conf ****";
        configure_x_server
        configure_nvidia_x_server
    fi
fi

echo "DONE"
