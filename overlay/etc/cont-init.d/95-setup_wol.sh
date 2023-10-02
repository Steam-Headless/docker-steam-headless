#!/usr/bin/env bash
###
# File: 10-setup_user.sh
# Project: cont-init.d
# File Created: Tuesday, 5th September 2023 6:15:12 pm
# Author: Josh.5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 5th September 2023 6:39:32 pm
# Modified By: Josh.5 (jsunnex@gmail.com)
###

print_header "Configure WoL Manager"

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [ "${ENABLE_WOL_POWER_MANAGER:-}" = "true" ]; then
        if [ -f "/tmp/.wol-monitor" ]; then
            print_step_header "Container started in WoL Manager mode. Disabling all other services."
            for init_config in /etc/supervisor.d/*.ini ; do
                init_config_basename=$(basename "${init_config:?}")
                init_name="${init_config_basename%.*}"
                [ "${init_name:?}" = "wol-power-manager" ] && continue
                echo " - Disable ${init_name:?}"
                sed -i 's|^autostart.*=.*$|autostart=false|' "${init_config:?}"
            done
        fi
        print_step_header "Enable WoL Manager service."
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/wol-power-manager.ini
    else
        print_step_header "Disable WoL Manager service."
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/wol-power-manager.ini
    fi
else
    print_step_header "WoL Manager service not available when container is run in 'secondary' mode."
fi
