
# Fech NVIDIA GPU device (if one exists)
if [ "${NVIDIA_VISIBLE_DEVICES:-}" = "all" ]; then
    export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
elif [ "${NVIDIA_VISIBLE_DEVICES:-}X" = "X" ]; then
    export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
else
    export gpu_select=$(nvidia-smi --format=csv --id=$(echo "$NVIDIA_VISIBLE_DEVICES" | cut -d ',' -f1) --query-gpu=uuid | sed -n 2p)
    if [ "${gpu_select:-}X" = "X" ]; then
        export gpu_select=$(nvidia-smi --format=csv --query-gpu=uuid 2> /dev/null | sed -n 2p)
    fi
fi

# NVIDIA Params
if [ "X${gpu_select:-}" != "X" ]; then
    export nvidia_pci_address="$(nvidia-smi --format=csv --query-gpu=pci.bus_id --id="${gpu_select:?}" 2> /dev/null | sed -n 2p | cut -d ':' -f2,3)"
    export nvidia_gpu_name=$(nvidia-smi --format=csv --query-gpu=name --id="${gpu_select:?}" 2> /dev/null | sed -n 2p)
    export nvidia_host_driver_version="$(nvidia-smi 2> /dev/null | grep NVIDIA-SMI | cut -d ' ' -f3)"
fi

# Intel params
# This figures out if it's an intel CPU with integrated GPU
export intel_cpu_model="$(lscpu | grep 'Model name:' | grep -i intel | cut -d':' -f2 | xargs)"
# We need to check if the user has an intel ARC GPU as well
export intel_gpu_model="$(lspci | grep -i "VGA compatible controller: Intel" | cut -d':' -f3 | xargs)"

# AMD params
export amd_cpu_model="$(lscpu | grep 'Model name:' | grep -i amd | cut -d':' -f2 | xargs)"
export amd_gpu_model="$(lspci | grep -i vga | grep -i amd)"


function download_driver {
    mkdir -p "${USER_HOME:?}/Downloads"
    chown -R ${USER:?} "${USER_HOME:?}/Downloads"

    if [[ ! -f "${USER_HOME:?}/Downloads/NVIDIA_${nvidia_host_driver_version:?}.run" ]]; then
        print_step_header "Downloading driver v${nvidia_host_driver_version:?}"
        wget -q --show-progress --progress=bar:force:noscroll \
            -O /tmp/NVIDIA.run \
            "http://download.nvidia.com/XFree86/Linux-x86_64/${nvidia_host_driver_version:?}/NVIDIA-Linux-x86_64-${nvidia_host_driver_version:?}.run"
        [[ $? -gt 0 ]] && print_error "Unable to download driver. Exit!" && return 1

        mv /tmp/NVIDIA.run "${USER_HOME:?}/Downloads/NVIDIA_${nvidia_host_driver_version:?}.run"
    fi
}

function install_nvidia_driver {
    # Check here if the currently installed version matches using nvidia-settings
    nvidia_settings_version=$(nvidia-settings --version 2> /dev/null | grep version | cut -d ' ' -f 4)
    if [ "${nvidia_settings_version:-}X" != "${nvidia_host_driver_version:-}X" ]; then
        # Download the driver (if it does not yet exist locally)
        download_driver

        if (($(echo $nvidia_host_driver_version | cut -d '.' -f 1) >= 550)); then
            sed -i 's/--no-multigpu//g' /etc/cont-init.d/70-configure_xorg.sh
        fi

        if (($(echo $nvidia_host_driver_version | cut -d '.' -f 1) > 500)); then
            print_step_header "Installing NVIDIA driver v${nvidia_host_driver_version:?} to match what is running on the host"
            chmod +x "${USER_HOME:?}/Downloads/NVIDIA_${nvidia_host_driver_version:?}.run"
            "${USER_HOME:?}/Downloads/NVIDIA_${nvidia_host_driver_version:?}.run" \
                --silent \
                --accept-license \
                --skip-depmod \
                --skip-module-unload \
                --no-kernel-modules \
                --no-kernel-module-source \
                --install-compat32-libs \
                --no-nouveau-check \
                --no-nvidia-modprobe \
                --no-systemd \
                --no-distro-scripts \
                --no-rpms \
                --no-backup \
                --no-check-for-alternate-installs \
                --no-libglx-indirect \
                --no-install-libglvnd \
                > "${USER_HOME:?}/Downloads/nvidia_gpu_install.log" 2>&1
        else 
            print_step_header "Installing Legacy NVIDIA driver v${nvidia_host_driver_version:?} to match what is running on the host"
            chmod +x "${USER_HOME:?}/Downloads/NVIDIA_${nvidia_host_driver_version:?}.run"
            "${USER_HOME:?}/Downloads/NVIDIA_${nvidia_host_driver_version:?}.run" \
                --silent \
                --accept-license \
                --skip-depmod \
                --skip-module-unload \
                --no-kernel-module \
                --no-kernel-module-source \
                --install-compat32-libs \
                --no-nouveau-check \
                --no-nvidia-modprobe \
                --no-systemd \
                --no-distro-scripts \
                --no-rpms \
                --no-backup \
                --no-check-for-alternate-installs \
                --no-libglx-indirect \
                --no-install-libglvnd \
                > "${USER_HOME:?}/Downloads/nvidia_gpu_install.log" 2>&1
        fi
    fi
}

function patch_nvidia_driver {
    # REF: https://github.com/keylase/nvidia-patch#docker-support
    if [ "${NVIDIA_PATCH_VERSION:-}X" != "X" ]; then
        # Don't fail boot if something goes wrong here. Set +e
        (
            set +e
            if [ ! -f "${USER_HOME:?}/Downloads/nvidia-patch.${NVIDIA_PATCH_VERSION:?}.sh" ]; then
                print_step_header "Fetch NVIDIA NVENC patch"
                wget -q --show-progress --progress=bar:force:noscroll \
                    -O "${USER_HOME:?}/Downloads/nvidia-patch.${NVIDIA_PATCH_VERSION:?}.sh" \
                    "https://raw.githubusercontent.com/keylase/nvidia-patch/${NVIDIA_PATCH_VERSION:?}/patch.sh"
            fi
            if [ ! -f "${USER_HOME:?}/Downloads/nvidia-patch-fbc.${NVIDIA_PATCH_VERSION:?}.sh" ]; then
                print_step_header "Fetch NVIDIA NvFBC patch"
                wget -q --show-progress --progress=bar:force:noscroll \
                    -O "${USER_HOME:?}/Downloads/nvidia-patch-fbc.${NVIDIA_PATCH_VERSION:?}.sh" \
                    "https://raw.githubusercontent.com/keylase/nvidia-patch/${NVIDIA_PATCH_VERSION:?}/patch-fbc.sh"
            fi
            chmod +x \
                "${USER_HOME:?}/Downloads/nvidia-patch.${NVIDIA_PATCH_VERSION:?}.sh" \
                "${USER_HOME:?}/Downloads/nvidia-patch-fbc.${NVIDIA_PATCH_VERSION:?}.sh"

            print_step_header "Install NVIDIA driver patches"
            echo "/patched-lib" > /etc/ld.so.conf.d/000-patched-lib.conf
            mkdir -p "/patched-lib"
            PATCH_OUTPUT_DIR="/patched-lib" "${USER_HOME:?}/Downloads/nvidia-patch.${NVIDIA_PATCH_VERSION:?}.sh"
            PATCH_OUTPUT_DIR="/patched-lib" "${USER_HOME:?}/Downloads/nvidia-patch-fbc.${NVIDIA_PATCH_VERSION:?}.sh"

            pushd "/patched-lib" &> /dev/null || { print_error "Failed to push directory to /patched-lib"; exit 1; }
            for f in * ; do
                suffix="${f##*.so}"
                name="$(basename "$f" "$suffix")"
                [ -h "$name" ] || ln -sf "$f" "$name"
                [ -h "$name" ] || ln -sf "$f" "$name.1"
            done
            ldconfig
            popd &> /dev/null || { print_error "Failed to pop directory out of /patched-lib"; exit 1; }
        )
    else
        print_step_header "Leaving NVIDIA driver stock without patching"
    fi
}

function install_deb_mesa {
    if [ ! -f /tmp/init-mesa-libs-install.log ]; then
        print_step_header "Enable i386 arch"
        dpkg --add-architecture i386
	if [ "${ENABLE_SID:-}" = "true" ]; then
            print_step_header "Add Debian SID sources"
            echo "deb http://deb.debian.org/debian/ sid main" > /etc/apt/sources.list
	fi
        apt-get update &>> /tmp/init-mesa-libs-install.log
        print_step_header "Install mesa vulkan drivers"
        echo "" >> /tmp/init-mesa-libs-install.log
        apt-get install -y --no-install-recommends \
            libvulkan1 \
            libvulkan1:i386 \
            mesa-vulkan-drivers \
            mesa-vulkan-drivers:i386 \
            mesa-utils \
            mesa-utils-extra \
            vulkan-tools \
            &>> /tmp/init-mesa-libs-install.log
    else
        print_step_header "Mesa has already been installed into this container"
    fi
}

function install_amd_gpu_driver {
    if command -v pacman &> /dev/null; then
        print_step_header "Install AMD Mesa driver"
        pacman -Syu --noconfirm --needed \
            lib32-vulkan-icd-loader \
            lib32-vulkan-radeon \
            vulkan-icd-loader \
            vulkan-radeon
    elif command -v apt-get &> /dev/null; then
        install_deb_mesa
    fi
}

function install_intel_gpu_driver {
    if command -v pacman &> /dev/null; then
        print_step_header "Install Intel Mesa driver"
        pacman -Syu --noconfirm --needed \
            lib32-vulkan-icd-loader \
            lib32-vulkan-intel \
            vulkan-icd-loader \
            vulkan-intel
    elif command -v apt-get &> /dev/null; then
        install_deb_mesa
    fi
}

# Intel Arc GPU or Intel CPU with possible iGPU
if [ "${intel_gpu_model:-}X" != "X" ]; then
    print_header "Found Intel device '${intel_gpu_model:?}'"
    install_intel_gpu_driver
elif [ "${intel_cpu_model:-}X" != "X" ]; then
    print_header "Found Intel device '${intel_cpu_model:?}'"
    install_intel_gpu_driver
else
    print_header "No Intel device found"
fi
# AMD GPU
if [ "${amd_gpu_model:-}X" != "X" ]; then
    print_header "Found AMD device '${amd_gpu_model:?}'"
    install_amd_gpu_driver
else
    print_header "No AMD device found"
fi
# NVIDIA GPU
if [ "${nvidia_pci_address:-}X" != "X" ]; then
    print_header "Found NVIDIA device '${nvidia_gpu_name:?}'"
    install_nvidia_driver
    patch_nvidia_driver
elif [ "${NVIDIA_DRIVER_VERSION:-}X" != "X" ]; then
    export nvidia_host_driver_version="${NVIDIA_DRIVER_VERSION:?}"
    print_header "Forcing install of NVIDIA driver version '${nvidia_host_driver_version:?}' because the 'NVIDIA_DRIVER_VERSION' variable is set."
    install_nvidia_driver
    patch_nvidia_driver
else
    print_header "No NVIDIA device found"
fi

echo -e "\e[34mDONE\e[0m"
