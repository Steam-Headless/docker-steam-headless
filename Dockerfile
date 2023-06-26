FROM debian:bullseye-slim
LABEL maintainer="Josh.5 <jsunnex@gmail.com>"

# Update package repos
ARG DEBIAN_FRONTEND=noninteractive
RUN \
    echo "**** Update apt database ****" \
        && sed -i '/^.*main/ s/$/ contrib non-free/' /etc/apt/sources.list \
    && \
    echo

# Update locale
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install and configure locals ****" \
        && apt-get install -y --no-install-recommends \
            locales \
        && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
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
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Re-install certificates
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install certificates ****" \
        && apt-get install -y --reinstall \
            ca-certificates \
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

# Install core packages
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install tools ****" \
        && apt-get install -y --no-install-recommends \
            bash \
            bash-completion \
            curl \
            git \
            less \
            man-db \
            mlocate \
            nano \
            net-tools \
            patch \
            pciutils \
            pkg-config \
            procps \
            rsync \
            screen \
            sudo \
            unzip \
            vim \
            wget \
            xz-utils \
    && \
    echo "**** Install python ****" \
        && apt-get install -y --no-install-recommends \
            python3 \
            python3-numpy \
            python3-pip \
            python3-setuptools \
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

# Install supervisor
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install supervisor ****" \
        && apt-get install -y \
            supervisor \
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

# Install mesa and vulkan requirements
RUN \
    echo "**** Update apt database ****" \
        && dpkg --add-architecture i386 \
        && apt-get update \
    && \
    echo "**** Install mesa requirements ****" \
        && apt-get install -y --no-install-recommends \
            libgl1-mesa-dri \
            libgl1-mesa-glx \
            libgles2-mesa \
            libglu1-mesa \
            mesa-utils \
            mesa-utils-extra \
    && \
    echo "**** Install vulkan requirements ****" \
        && apt-get install -y --no-install-recommends \
            libvulkan1 \
            libvulkan1:i386 \
            mesa-vulkan-drivers \
            mesa-vulkan-drivers:i386 \
            vulkan-tools \
    && \
    echo "**** Install desktop requirements ****" \
        && apt-get install -y --no-install-recommends \
            libdbus-1-3 \
            libegl1 \
            libgtk-3-0 \
            libgtk2.0-0 \
            libsdl2-2.0-0 \
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

# Install X Server requirements
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install X Server requirements ****" \
        && apt-get install -y --no-install-recommends \
            avahi-utils \
            dbus-x11 \
            libxcomposite-dev \
            libxcursor1 \
            x11-xfs-utils \
            x11vnc \
            xauth \
            xfonts-base \
            xorg \
            xserver-xorg-core \
            xserver-xorg-input-evdev \
            xserver-xorg-input-libinput \
            xserver-xorg-legacy \
            xserver-xorg-video-all \
            xserver-xorg-video-dummy \
            xvfb \
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

# Install audio requirements
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install X Server requirements ****" \
        && apt-get install -y --no-install-recommends \
            pulseaudio \
            alsa-utils \
            libasound2 \
            libasound2-plugins \
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

# Install openssh server
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install openssh server ****" \
        && apt-get install -y \
            openssh-server \
        && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
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

# Install Neko server
COPY --from=m1k1o/neko:base /usr/bin/neko /usr/bin/neko
COPY --from=m1k1o/neko:base /var/www /var/www

# Install noVNC
ARG NOVNC_VERSION=1.2.0
RUN \
    echo "**** Fetch noVNC ****" \
        && cd /tmp \
        && wget -O /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz \
    && \
    echo "**** Extract noVNC ****" \
        && cd /tmp \
        && tar -xvf /tmp/novnc.tar.gz \
    && \
    echo "**** Configure noVNC ****" \
        && cd /tmp/noVNC-${NOVNC_VERSION} \
        && sed -i 's/credentials: { password: password } });/credentials: { password: password },\n                           wsProtocols: ["'"binary"'"] });/g' app/ui.js \
        && mkdir -p /opt \
        && rm -rf /opt/noVNC \
        && cd /opt \
        && mv -f /tmp/noVNC-${NOVNC_VERSION} /opt/noVNC \
        && cd /opt/noVNC \
        && ln -s vnc.html index.html \
        && chmod -R 755 /opt/noVNC \
    && \
    echo "**** Modify noVNC title ****" \
        && sed -i '/    document.title =/c\    document.title = "Steam Headless - noVNC";' \
            /opt/noVNC/app/ui.js \
    && \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install nginx support ****" \
        && apt-get install -y \
            nginx \
    && \
    echo "**** Section cleanup ****" \
        && apt-get clean autoclean -y \
        && apt-get autoremove -y \
        && rm -rf \
            /var/lib/apt/lists/* \
            /tmp/noVNC* \
            /tmp/novnc.tar.gz

# Install Websockify
ARG WEBSOCKETIFY_VERSION=0.10.0
RUN \
    echo "**** Fetch Websockify ****" \
        && cd /tmp \
        && wget -O /tmp/websockify.tar.gz https://github.com/novnc/websockify/archive/v${WEBSOCKETIFY_VERSION}.tar.gz \
    && \
    echo "**** Extract Websockify ****" \
        && cd /tmp \
        && tar -xvf /tmp/websockify.tar.gz \
    && \
    echo "**** Install Websockify to main ****" \
        && cd /tmp/websockify-${WEBSOCKETIFY_VERSION} \
        && python3 ./setup.py install \
    && \
    echo "**** Install Websockify to noVNC path ****" \
        && cd /tmp \
        && mv -v /tmp/websockify-${WEBSOCKETIFY_VERSION} /opt/noVNC/utils/websockify \
    && \
    echo "**** Section cleanup ****" \
        && rm -rf \
            /tmp/websockify-* \
            /tmp/websockify.tar.gz

# Add support for flatpaks
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install flatpak support ****" \
        && apt-get install -y \
            bridge-utils \
            flatpak \
            libpam-cgfs \
            libvirt0 \
            lxc \
            uidmap \
    && \
    echo "**** Configure flatpak ****" \
        && chmod u+s /usr/bin/bwrap \
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

# Install desktop environment
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install desktop environment ****" \
        && apt-get install -y \
            xfce4 \
            xfce4-terminal \
            msttcorefonts \
            fonts-vlgothic \
            gedit \
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

# Install Steam
RUN \
    echo "**** Install steam ****" \
        && dpkg --add-architecture i386 \
        && apt-get update \
        && echo steam steam/question select "I AGREE" | debconf-set-selections \
        && echo steam steam/license note '' | debconf-set-selections \
        && apt-get install -y \
        && apt-get install -y \
            steam \
            steam-devices \
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

# Install firefox
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install firefox ****" \
        && apt-get install -y \
            firefox-esr \
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

# Setup audio streaming deps
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install audio streaming deps ****" \
        && apt-get install -y --no-install-recommends \
            bzip2 \
            gstreamer1.0-alsa \
            gstreamer1.0-gl \
            gstreamer1.0-gtk3 \
            gstreamer1.0-libav \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-ugly \
            gstreamer1.0-pulseaudio \
            gstreamer1.0-qt5 \
            gstreamer1.0-tools \
            gstreamer1.0-vaapi \
            gstreamer1.0-x \
            libgstreamer1.0-0 \
            libncursesw5 \
            libopenal1 \
            libsdl-image1.2 \
            libsdl-ttf2.0-0 \
            libsdl1.2debian \
            libsndfile1 \
            ucspi-tcp \
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

# Install sunshine
ARG SUNSHINE_VERSION=0.20.0
RUN \
    echo "**** Fetch Sunshine deb package ****" \
        && cd /tmp \
        && wget -O /tmp/sunshine-debian.deb \
            https://github.com/LizardByte/sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-debian-bullseye-amd64.deb \
    && \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install Sunshine ****" \
        && apt-get install -y /tmp/sunshine-debian.deb \
        && apt-get install -y libboost-chrono1.74.0 \
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

# Setup video streaming deps
RUN \
    echo "**** Update apt database ****" \
        && apt-get update \
    && \
    echo "**** Install Intel media drivers and VAAPI ****" \
        && apt-get install -y --no-install-recommends \
            intel-media-va-driver-non-free \
            i965-va-driver-shaders \
            libva2 \
            vainfo \
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

# Setup dind
# Ref: 
#   - https://github.com/docker-library/docker/blob/master/20.10/dind/Dockerfile
#   - https://docs.nvidia.com/ai-enterprise/deployment-guide/dg-docker.html
ARG DOCKER_VERSION=20.10.18
ARG DOCKER_COMPOSE_VERSION=v2.11.2
RUN \
    echo "**** Fetch Docker static binary package ****" \
        && cd /tmp \
        && wget -O /tmp/docker-${DOCKER_VERSION}.tgz \
            https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
    && \
    echo "**** Extract static binaries ****" \
        && mkdir -p /usr/local/bin \
        && tar --extract \
            --file /tmp/docker-${DOCKER_VERSION}.tgz \
            --strip-components 1 \
            --directory /usr/local/bin/ \
            --no-same-owner \
    && \
    echo "**** Install docker-compose ****" \
        && wget -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Linux-x86_64" \
        && chmod +x /usr/local/bin/docker-compose \
    && \
    echo "**** Install nvidia runtime ****" \
        && distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
        && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add - \
        && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list \
        && apt-get update \
        && apt-get install -y \
            nvidia-container-toolkit \
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
VOLUME /var/lib/docker


# Configure default user and set env
ENV \
    PUID=99 \
    PGID=100 \
    UMASK=000 \
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
    NVIDIA_VISIBLE_DEVICES="all" \
    XORG_SOCKET_DIR="/tmp/.X11-unix" \
    XDG_RUNTIME_DIR="/tmp/.X11-unix/run"

# Set pulseaudio environment variables
ENV \
    PULSE_SOCKET_DIR="/tmp/pulse" \
    PULSE_SERVER="unix:/tmp/pulse/pulse-socket"

# Set container configuration environment variables
ENV \
    MODE="primary" \
    WEB_UI_MODE="vnc" \
    ENABLE_VNC_AUDIO="true" \
    NEKO_PASSWORD=neko \
    NEKO_PASSWORD_ADMIN=admin \
    ENABLE_SUNSHINE="false" \
    ENABLE_EVDEV_INPUTS="false"

# Configure required ports
ENV \
    PORT_SSH="" \
    PORT_NOVNC_WEB="8083" \
    NEKO_NAT1TO1=""

# Expose the required ports
EXPOSE 8083

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
