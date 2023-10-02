
print_header "Configure Flatpak"

if [ "X${NVIDIA_VISIBLE_DEVICES:-}" != "X" ]; then
    # Fix some flatpak quirks (not sure what is happening here) for NVIDIA containers
    mount -t proc none /proc
    flatpak list
    print_step_header "Flatpak configured for running inside a Docker container"
else
    print_step_header "Flatpak already configured for running inside a Docker container"
fi

echo -e "\e[34mDONE\e[0m"
