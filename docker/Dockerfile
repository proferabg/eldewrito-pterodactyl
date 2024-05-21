FROM eclipse-temurin:17-jdk-jammy

ENV         DEBIAN_FRONTEND=noninteractive

## install required packages
RUN         dpkg --add-architecture i386 && \
            apt update -y && \
            apt install -y \
                curl \
                lsof \
                ca-certificates \
                openssl \
                git \
                tar \
                sqlite3 \
                fontconfig \
                tzdata \
                iproute2 \
                libfreetype6 \
                tini \
                zip \
                unzip \
                wget \
                software-properties-common \
                apt-transport-https \
                xvfb \
                winbind \
                libvulkan1:i386 \
                libgl1:i386
        
# Install wine and with recommends
RUN         wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
            apt-key add winehq.key && \
            rm winehq.key && \
            add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main' && \
            apt update && \
            apt install --install-recommends winehq-stable cabextract wine-binfmt -y
            
    
# Set up Winetricks
RUN	        wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
            chmod +x /usr/sbin/winetricks

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container 
ENV         HOME=/home/container
ENV         WINEPREFIX=/home/container/.wine
ENV         WINEDLLOVERRIDES="mscoree,mshtml="
ENV         WINEDEBUG=fixme-all
ENV         DISPLAY=:0
ENV         DISPLAY_WIDTH=1024
ENV         DISPLAY_HEIGHT=768
ENV         DISPLAY_DEPTH=16
ENV         AUTO_UPDATE=1
ENV         XVFB=1
ENV         MTNDEW_CHECKSUM=f1d6c49381ac1ec572f0f405e4cd406b
ENV         ELDEWRITO_VERSION=0.7.1
ENV         CONTAINER_VERSION=0.1
WORKDIR     /home/container

STOPSIGNAL SIGINT

ADD defaults defaults

COPY        --chown=container:container ElDewLauncher.jar /ElDewLauncher.jar
COPY        --chown=container:container entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]