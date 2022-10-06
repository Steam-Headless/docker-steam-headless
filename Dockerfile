# Steam Headless (Arch Linux)
# (WIP) An Arch variant of the steam-headless image
#   using holoiso package
#
FROM lscr.io/linuxserver/webtop:amd64-arch-xfce
LABEL maintainer="YourJelly <steam_holo@yourjelly.dev>"

WORKDIR /docker
COPY /docker/debian /docker
RUN /bin/bash -c 'chmod +x /docker/*.sh'

ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Setup core packages
ARG DEBIAN_FRONTEND=noninteractive
RUN /docker/10_setup_core.sh

# Install Neko server
COPY --from=m1k1o/neko:base /usr/bin/neko /usr/bin/neko
COPY --from=m1k1o/neko:base /var/www /var/www

# Install noVNC
RUN /docker/20_setup_noVNC.sh

# Install desktop environment
RUN /docker/30_setup_desktop.sh

# Install desktop environment ##split from desktop because timing out
RUN /docker/40_setup_steam.sh

# Install sunshine
ARG SUNSHINE_VERSION=0.11.1
RUN \
    echo "**** Fetch Sunshine deb package ****" \
        && cd /tmp \
        && wget -O /tmp/sunshine-debian.deb \
            https://github.com/loki-47-6F-64/sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-debian.deb \
    && \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install Sunshine ****" \
        && apt-get install -y /tmp/sunshine-debian.deb \
    && \
    echo "**** Section cleanup ****" \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/* \
            /var/tmp/* \
            /tmp/* \
    && \
    echo

# Configure default user and set env
ENV \
    USER="default" \
    USER_PASSWORD="password" \
    USER_HOME="/home/default" \
    TZ="Pacific/Auckland" \
    USER_LOCALES="en_US.UTF-8 UTF-8"
    
RUN \
    echo "**** Configure default user '${USER}' ****" \
        && mkdir -p \
            ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && \
    echo

# Add FS overlay
COPY overlay /

# Set display environment variables
ENV \
    DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="60" \
    DISPLAY_SIZEH="900" \
    DISPLAY_SIZEW="1600" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":55" \
    NVIDIA_DRIVER_CAPABILITIES="all" \
    NVIDIA_VISIBLE_DEVICES="all"

# Set container configuration environment variables
ENV \
    MODE="primary" \
    WEB_UI_MODE="vnc" \
    ENABLE_VNC_AUDIO="true" \
    NEKO_PASSWORD="neko" \
    NEKO_PASSWORD_ADMIN="admin" \
    ENABLE_SUNSHINE="false" \
    ENABLE_EVDEV_INPUTS="false"

# Configure required ports
ENV \
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
