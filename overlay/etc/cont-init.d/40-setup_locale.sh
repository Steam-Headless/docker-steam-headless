
# Configure dbus
print_header "Configure local"

current_local=$(head -n 1 /etc/locale.gen)
user_local=$(echo ${USER_LOCALES} | cut -d ' ' -f 1)

if [ "${current_local}" != "${USER_LOCALES}" ]; then
    print_step_header "Configuring Locales to ${USER_LOCALES}"
	rm /etc/locale.gen
	echo -e "${USER_LOCALES}\nen_US.UTF-8 UTF-8" > "/etc/locale.gen"
	export LANGUAGE="${user_local}"
	export LANG="${user_local}"
	export LC_ALL="${user_local}" 2> /dev/null
	sleep 0.5
	locale-gen
	update-locale LC_ALL="${user_local}"
else
    print_step_header "Locales already set correctly to ${USER_LOCALES}"
fi

echo -e "\e[34mDONE\e[0m"
