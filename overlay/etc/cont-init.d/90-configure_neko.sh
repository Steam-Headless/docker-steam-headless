
echo "**** Configure Neko ****"
# REF: https://neko.m1k1o.net/#/getting-started/configuration

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then
    if [ ${WEB_UI_MODE} = "neko" ]; then
        echo "Enable Neko server"
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/neko.ini

        # Make directories for neko
        mkdir -p /var/log/neko
        chmod 1777 /var/log/neko
        chown ${USER} /var/log/neko
        
        # Configure nat1to1 if it is not already set
        if [[ -z ${NEKO_NAT1TO1} ]]; then
            export NEKO_NAT1TO1=$(ip route get 1 | awk '{print $(NF-2);exit}')
            echo "Setting NEKO_NAT1TO1=${NEKO_NAT1TO1}"
        else
            echo "User provided setting NEKO_NAT1TO1=${NEKO_NAT1TO1}"
        fi

        # Configure hardware acceleration if it is not already set
        # if [[ -z ${NEKO_HWENC} ]]; then
        #     # Enable VAAPI if device available
        #     if [[ ! -z $(stat -c "%g" /dev/dri/render* | tail -n 1) ]]; then
        #         echo "Setting Neko to use VAAPI encoder"
        #         export NEKO_HWENC="VAAPI"
        #         # Check for vp8 vaapi encoder
        #         echo "Setting Neko to use 264 encoding"
        #         # export NEKO_VP8="false"
        #         # export NEKO_VP9="false"
        #         export NEKO_H264="true"
        #     fi
        # fi

        # Configure screen size if it is not already set
        if [[ -z ${NEKO_SCREEN} ]]; then
            export NEKO_SCREEN="${DISPLAY_SIZEW}x${DISPLAY_SIZEH}@${DISPLAY_REFRESH}"
        fi
    else
        echo "Disable Neko server"
    fi
else
    echo "Neko server not available when container is run in 'secondary' mode"
fi

echo "DONE"
