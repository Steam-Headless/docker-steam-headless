# Steam Headless (Arch Linux)
# (WIP) An Arch variant of the steam-headless image
#   using holoiso package
#
FROM lscr.io/linuxserver/webtop:amd64-arch-xfce
LABEL maintainer="YourJelly <steam_holo@yourjelly.dev>"

# Set static variables
# todo is lang/language needed?
ENV USER="default" \
    USER_HOME="/home/default" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="60" \
    DISPLAY_SIZEH="900" \
    DISPLAY_SIZEW="1600" \
    DISPLAY_VIDEO_PORT="DFP" \
    PORT_SSH="" \
    NEKO_NAT1TO1=""

WORKDIR /tmp
COPY /docker /tmp
RUN /bin/bash -c 'chmod +x /tmp/*.sh'

# Install core packages
RUN /tmp/setup.sh

# Install noVNC
ARG NOVNC_VERSION=1.3.0
RUN /tmp/setup_noVNC.sh

# Setup User
RUN /tmp/setup_user.sh

# Cleanup
RUN rm -rf /tmp

# Add FS overlay
COPY overlay /

# Expose the required ports
EXPOSE 8083

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
