
if [[ "${script_path}" == *"opt/script"* ]]; then
    while true; do
        echo
        read -p "Would you like to configure this container to install ${pkg^} on startup? (Y/N) " ans

        case $ans in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    # Install this script to the home directory init.d
    dest_file="/home/${USER}/init.d/${script_name}"
    cp -f "${script_path}/${script_name}" "${dest_file}"
    # Remove anything under '#INSTALLER:'
    sed -i '/^#INSTALLER.*$/Q' "${dest_file}"
    # Append 'install' command
    echo 'install' >> "${dest_file}"
    echo
    echo
    echo "Installed init script '${dest_file}'"
    echo "This script will install ${pkg^} when you next restart the container."
    echo
    read -s -p "Press enter to continue"
    echo
fi
