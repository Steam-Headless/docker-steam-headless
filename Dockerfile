FROM debian:bullseye-slim

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
            procps \
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
        && apt-get install -y --reinstall \
            bash \
            bash-completion \
            gcc \
            git \
            kmod \
            less \
            make \
            nano \
            python3 \
            python3-numpy \
            python3-pip \
            python3-setuptools \
            rsync \
            sudo \
            unzip \
            vim \
            wget \
            xz-utils \
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

# Install desktop requirements
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
            man-db \
            mlocate \
            net-tools \
            pciutils \
            pkg-config \
            x11vnc \
            xauth \
            xfonts-base \
            xorg \
            xserver-xorg-core \
            xserver-xorg-input-libinput \
            xserver-xorg-legacy \
            xserver-xorg-video-all \
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
    echo "**** Section cleanup ****" \
        && rm -rf \
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

# Install Steam
RUN \
    echo "**** Install steam ****" \
        && dpkg --add-architecture i386 \
        && apt-get update \
        && echo steam steam/question select "I AGREE" | debconf-set-selections \
        && echo steam steam/license note '' | debconf-set-selections \
        && apt-get install -y \
            libgl1-mesa-dri \
            libgl1-mesa-dri:i386 \
            libgl1-mesa-glx \
            libglx-mesa0:i386 \
            mesa-utils \
            mesa-vulkan-drivers \
            mesa-vulkan-drivers:i386 \
            vulkan-tools \
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

# Setup browser audio streaming deps
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
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-pulseaudio \
            gstreamer1.0-qt5 \
            gstreamer1.0-tools \
            gstreamer1.0-x \
            libglu1-mesa \
            libgstreamer1.0-0 \
            libgtk2.0-0 \
            libncursesw5 \
            libopenal1 \
            libsdl-image1.2 \
            libsdl-ttf2.0-0 \
            libsdl1.2debian \
            libsndfile1 \
            novnc \
            pulseaudio \
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
            /games \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
            /games \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

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
    ENABLE_VNC_AUDIO="true"

# Be sure that the noVNC port is exposed
EXPOSE 8083
EXPOSE 32123

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
