
# Configure kernel parameters
print_header "Configure some system kernel parameters"


if [ "$(cat /proc/sys/vm/max_map_count)" -ge 524288 ]; then
    if [ -w "/proc/sys/vm/max_map_count" ]; then
        print_step_header "Setting the maximum number of memory map areas a process can create to 524288"
        echo 524288 > /proc/sys/vm/max_map_count
    else
        print_warning "Unable to set vm.max_map_count on unprivileged container"
    fi
else
    print_step_header "The vm.max_map_count is already greater than '524288'"
fi

echo -e "\e[34mDONE\e[0m"
