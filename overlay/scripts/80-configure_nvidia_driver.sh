
# Fech NVIDIA GPU device (if one exists)
if [ "$NVIDIA_VISIBLE_DEVICES" == "all" ]; then
    export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
elif [ -z "$NVIDIA_VISIBLE_DEVICES" ]; then
    export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
else
    export gpu_select=$(nvidia-smi --format=csv --id=$(echo "$NVIDIA_VISIBLE_DEVICES" | cut -d ',' -f1) --query-gpu=uuid | sed -n 2p)
    if [ -z "$gpu_select" ]; then
        export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
    fi
fi

export nvidia_pci_address="$(nvidia-smi --format=csv --query-gpu=pci.bus_id --id="${gpu_select}" 2> /dev/null | sed -n 2p | cut -d ':' -f2,3)"
export nvidia_gpu_name=$(nvidia-smi --format=csv --query-gpu=name --id="${gpu_select}" | sed -n 2p 2> /dev/null)
export nvidia_host_driver_version="$(nvidia-smi 2> /dev/null | grep NVIDIA-SMI | cut -d ' ' -f3)"

function download_driver {
    mkdir -p ${USER_HOME}/.cache/nvidia

    if [[ ! -f "${USER_HOME}/.cache/nvidia/NVIDIA_${nvidia_host_driver_version}.run" ]]; then
        echo "Downloading driver"
        wget -q --show-progress --progress=bar:force:noscroll \
            -O /tmp/NVIDIA.run \
            http://download.nvidia.com/XFree86/Linux-x86_64/${nvidia_host_driver_version}/NVIDIA-Linux-x86_64-${nvidia_host_driver_version}.run
        [[ $? -gt 0 ]] && echo "Error downloading driver. Exit!" && return 1

        mv /tmp/NVIDIA.run ${USER_HOME}/.cache/nvidia/NVIDIA_${nvidia_host_driver_version}.run
    fi
}

function install_driver {
    # Check here if the currently installed version matches using nvidia-settings
    nvidia_settings_version=$(nvidia-settings --version 2> /dev/null | grep version | cut -d ' ' -f 4)
    [[ "${nvidia_settings_version}x" == "${nvidia_host_driver_version}x" ]] && return 0

    # Download the driver (if it does not yet exist locally)
    download_driver

    echo "Installing driver"
    chmod +x ${USER_HOME}/.cache/nvidia/NVIDIA_${nvidia_host_driver_version}.run
    ${USER_HOME}/.cache/nvidia/NVIDIA_${nvidia_host_driver_version}.run \
        --silent \
        --accept-license \
        --no-kernel-module \
        --install-compat32-libs \
        --no-nouveau-check \
        --no-nvidia-modprobe \
        --no-rpms \
        --no-backup \
        --no-check-for-alternate-installs \
        --no-libglx-indirect \
        --no-install-libglvnd \
        > ${USER_HOME}/.cache/nvidia/last_install.log 2>&1
}

if [[ -z ${nvidia_pci_address} ]]; then
    echo "**** No NVIDIA device found ****";
else
    echo "**** Found NVIDIA device '${nvidia_gpu_name}' ****";
    install_driver
fi

echo "DONE"
