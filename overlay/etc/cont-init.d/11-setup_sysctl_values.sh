# Configure kernel parameters
print_header "Configure some system kernel parameters"

if [ "$(cat /proc/sys/vm/max_map_count)" -lt 1048576 ]; then
    if [ -w "/proc/sys/vm/max_map_count" ]; then
        print_step_header "Setting vm.max_map_count to the minimum required value of 1048576"
        echo 1048576 >/proc/sys/vm/max_map_count
    else
        print_warning "vm.max_map_count is below the required minimum of 1048576. This unprivileged container cannot change host sysctls; configure vm.max_map_count=1048576 on the host."
    fi
else
    print_step_header "vm.max_map_count is already at or above 1048576; leaving the host value unchanged"
fi

echo -e "\e[34mDONE\e[0m"
