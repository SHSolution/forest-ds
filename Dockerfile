############################################################
# Dockerfile that contains SteamCMD
# based on: https://hub.docker.com/r/cm2network/steamcmd/dockerfile and 
# https://github.com/CM2Walki/steamcmd/blob/master/Dockerfile and
# https://steamcommunity.com/sharedfiles/filedetails/?id=1423538141 and
# https://developer.valvesoftware.com/wiki/SteamCMD
############################################################
FROM ubuntu:18.10
LABEL maintainer="info@shsolutions.eu"

# Install, update & upgrade packages
# Create user for the server
# This also creates the home directory we later need
# Clean TMP, apt-get cache and other stuff to make the image smaller
RUN dpkg --add-architecture i386 && \ 
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y nano iputils-ping net-tools locales locales-all lib32stdc++6 lib32gcc1 curl xvfb winbind wine && \
#        apt-get clean autoclean && \
#        apt-get autoremove -y && \
#        rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
        useradd -m steam

# Switch to user steam
USER steam

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


# Create Directory for SteamCMD
# Download SteamCMD
# Extract and delete archive
RUN mkdir -p /home/steam/steamcmd && \
    mkdir -p /home/steam/games/data/forest/saves && \
    mkdir -p /home/steam/games/data/forest/config && \
    cd /home/steam/steamcmd && \
    curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
    tar zxf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

ADD startForestServer.sh /home/steam/
ADD Server.cfg /home/steam/games/data/forest/config

WORKDIR /home/steam/steamcmd

#RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +app_update 556450 validate +quit

#WORKDIR /home/steam/

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

VOLUME /home/steam/steamcmd
VOLUME /home/steam/games

ENTRYPOINT /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +app_update 556450 validate +quit && \
    /home/steam/startForestServer.sh