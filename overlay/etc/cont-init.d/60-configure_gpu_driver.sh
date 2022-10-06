
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

# NVIDIA Params
export nvidia_pci_address="$(nvidia-smi --format=csv --query-gpu=pci.bus_id --id="${gpu_select}" 2> /dev/null | sed -n 2p | cut -d ':' -f2,3)"
export nvidia_gpu_name=$(nvidia-smi --format=csv --query-gpu=name --id="${gpu_select}" 2> /dev/null | sed -n 2p)
export nvidia_host_driver_version="$(nvidia-smi 2> /dev/null | grep NVIDIA-SMI | cut -d ' ' -f3)"

# Intel params
export intel_cpu_model="$(lscpu | grep 'Model name:' | grep -i intel | cut -d':' -f2 | xargs)"

# AMD params
export amd_cpu_model="$(lscpu | grep 'Model name:' | grep -i amd | cut -d':' -f2 | xargs)"
export amd_gpu_model="$(lspci | grep -i vga | grep -i amd)"

function download_driver {
    mkdir -p ${USER_HOME}/Downloads
    chown -R ${USER} ${USER_HOME}/Downloads

    if [[ ! -f "${USER_HOME}/Downloads/NVIDIA_${nvidia_host_driver_version}.run" ]]; then
        echo "Downloading driver v${nvidia_host_driver_version}"
        wget -q --show-progress --progress=bar:force:noscroll \
            -O /tmp/NVIDIA.run \
            http://download.nvidia.com/XFree86/Linux-x86_64/${nvidia_host_driver_version}/NVIDIA-Linux-x86_64-${nvidia_host_driver_version}.run
        [[ $? -gt 0 ]] && echo "Error downloading driver. Exit!" && return 1

        mv /tmp/NVIDIA.run ${USER_HOME}/Downloads/NVIDIA_${nvidia_host_driver_version}.run
    fi
}

function install_nvidia_driver {
    # Check here if the currently installed version matches using nvidia-settings
    nvidia_settings_version=$(nvidia-settings --version 2> /dev/null | grep version | cut -d ' ' -f 4)
    [[ "${nvidia_settings_version}x" == "${nvidia_host_driver_version}x" ]] && return 0;

    # Download the driver (if it does not yet exist locally)
    download_driver

    # if command -v pacman &> /dev/null; then
    #     echo "Install NVIDIA vulkan utils" \
    #         && pacman -Syu --noconfirm --needed \
    #             lib32-nvidia-utils \
    #             lib32-vulkan-icd-loader
    #             nvidia-utils \
    #             vulkan-icd-loader \
    #         && echo
    # fi

    echo "Installing NVIDIA driver v${nvidia_host_driver_version} to match what is running on the host"
    chmod +x ${USER_HOME}/Downloads/NVIDIA_${nvidia_host_driver_version}.run
    ${USER_HOME}/Downloads/NVIDIA_${nvidia_host_driver_version}.run \
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
        > ${USER_HOME}/Downloads/nvidia_gpu_install.log 2>&1
}

function install_amd_gpu_driver {
    echo "Install AMD vulkan driver"
    if command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm --needed \
            lib32-mesa \
            lib32-vulkan-icd-loader \
            lib32-vulkan-radeon \
            vulkan-icd-loader \
            vulkan-radeon
    # There is currently nothing to install inside the debian container. This already comes with the vulken drives that are required
    # elif command -v apt-get &> /dev/null; then
    #     [[ "${APT_UPDATED:-false}" == 'false' ]] && apt-get update && export APT_UPDATED=true
    #     apt-get install -y \
    #         libvulkan1 \
    #         libvulkan1:i386 \
    #         mesa-vulkan-drivers \
    #         mesa-vulkan-drivers:i386
    fi
}

function install_intel_gpu_driver {
    echo "Install Intel vulkan driver"
    if command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm --needed \
            lib32-mesa \
            lib32-vulkan-icd-loader \
            lib32-vulkan-intel \
            vulkan-icd-loader \
            vulkan-intel
    # There is currently nothing to install inside the debian container. This already comes with the vulken drives that are required
    # elif command -v apt-get &> /dev/null; then
    #     [[ "${APT_UPDATED:-false}" == 'false' ]] && apt-get update && export APT_UPDATED=true
    #     apt-get install -y \
    #         libvulkan1 \
    #         libvulkan1:i386 \
    #         mesa-vulkan-drivers \
    #         mesa-vulkan-drivers:i386
    fi
}

# NVIDIA GPU
if [[ ! -z ${nvidia_pci_address} ]]; then
    echo "**** Found NVIDIA device '${nvidia_gpu_name}' ****";
    install_nvidia_driver
else
    echo "**** No NVIDIA device found ****";
fi
# Intel GPU
if [[ ! -z ${intel_cpu_model} ]]; then
    echo "**** Found Intel device '${intel_cpu_model}' ****";
    install_intel_gpu_driver
else
    echo "**** No Intel device found ****";
fi
# AMD GPU
if [[ ! -z ${amd_gpu_model} ]]; then
    echo "**** Found AMD device '${amd_gpu_model}' ****";
    install_amd_gpu_driver
else
    echo "**** No AMD device found ****";
fi

echo "DONE"
