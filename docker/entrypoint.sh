#!/bin/bash

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1


if [[ $XVFB == 1 ]]; then
  Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

if [ ! -d ".wine" ]; then
  printf  "${RED}=================================================================${NC}\n"
  printf  "${RED} ${NC}\n"
  printf  "${RED} First launch will throw some errors. It is safe to ignore them.${NC}\n"
  printf  "${RED} This next part will take a while...${NC}\n"
  printf  "${RED} ${NC}\n"
  printf  "${RED}=================================================================${NC}\n"
  mkdir -p $WINEPREFIX
  wineboot -u && \
  wineserver -w && \
  winetricks -q vcrun2012 winhttp && \
  rm -rf .cache && \
  rm .wget-hsts
  printf  "${GREEN}=================================================================${NC}\n"
  printf  "${GREEN} ${NC}\n"
  printf  "${GREEN}Finished installing wine! That wasn't so bad.${NC}\n"
  printf  "${GREEN} ${NC}\n"
  printf  "${GREEN}=================================================================${NC}\n"
fi

# Search for eldorado.exe in game directory
if [ ! -f "eldorado.exe" ]; then
    printf  "${RED}Could not find eldorado.exe. Please upload a copy of the game into the main directory.${NC}\n"

    sleep 2
    exit 1
fi

# Checksum the mtndew.dll to confirm we're running the correct version
if [ -z "${SKIP_CHECKSUM_CHECK}" ]; then
    checksum=$(md5sum mtndew.dll | awk '{ print $1 }')

    if [ "$checksum" != "${MTNDEW_CHECKSUM}" ]; then
        printf  "${RED}Checksum mismatch! Make sure you are using a valid copy of the game.${NC}\n"
        printf  "${RED}This container only supports ElDewrito ${ELDEWRITO_VERSION}.${NC}\n"

        printf  "Expected ${checksum}\n"
        printf  "Got ${MTNDEW_CHECKSUM}\n"

        sleep 2
        exit 10
    fi
else
    printf  "Skipping checksum check."
fi

# Create a server directory if it doesn't exist
if [ ! -d "data/server" ]; then
    printf  "${YELLOW}Could not find an existing data/server directory. Creating one.${NC}\n"
    mkdir data/server
fi

# Copy voting.json if it doesn't exist
if [ ! -f "data/server/voting.json" ]; then
    printf  "${YELLOW}Could not find an existing voting.json. Using default.${NC}\n"
    cp /defaults/voting.json data/server/
fi

# Copy dewrito.json if it doesn't exist (It is needed for the master server list)
if [ ! -f "data/dewrito.json" ]; then
    printf  "${YELLOW}Could not find an existing dewrito.json. Using default.${NC}\n"
    cp /defaults/dewrito.json data/
fi

# Overwrite ElDewLauncher.jar
if [ -f "ElDewLauncher.jar" ]; then
  rm ElDewLauncher.jar
fi
cp /ElDewLauncher.jar .
    
# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
eval ${PARSED}