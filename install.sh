#!/usr/local/env bash

set -euo pipefail

OS="$(uname -s)"
BASE_URL="https://github.com/v2fly/v2ray-core/releases"
FILENAME="v2ray-linux-64.zip"

# Get config vars from stdin
read -p "Remote uuid: " REMOTE_UUID
read -p "Remote host address: " REMOTE_HOST_ADDRESS
read -p "Remote port: " REMOTE_PORT
read -p "Remote ws path: " REMOTE_WS_PATH

export REMOTE_UUID REMOTE_HOST_ADDRESS REMOTE_PORT REMOTE_WS_PATH

# Install requirements
printf "| Install dependencies and requirements |"
sudo apt update \
    && sudo apt install unzip --no-install-recommends -y

# Download latest v2ray version
VERSION="v5.16.1"
[ ${OS} == "Linux" ] && printf "| Downloading v2ray version ${VERSION}... |\n"
curl -LOJs "${BASE_URL}/download/${VERSION}/${FILENAME}"

# Unzip downloaded file
(
	printf "| Create v2ray dir |\n" \
	&& mkdir v2ray \
	&& mv ${FILENAME} v2ray \
	&& cd v2ray \
	&& printf "| Unzip v2ray file |\n" \
	&& unzip -qq ${FILENAME}
)

# Create /usr/local/v2ray/ for need files
sudo mkdir -p /usr/local/etc/v2ray/

# Move files to their locations
sudo cat config.json.template | envsubst > config.json \
	&& sudo mv config.json /usr/local/etc/v2ray/config.json
sudo mv v2ray/v2ray /usr/local/bin/v2ray

IPV4_ADDRESS="$(hostname -I | cut -d ' ' -f1)"
export IPV4_ADDRESS
cat v2ray.service.template | envsubst > v2ray.service
sudo mv v2ray.service /etc/systemd/system/v2ray.service \
	&& sudo systemctl daemon-reload

printf "| Congrats! You can start using your vpn with sudo systemctl start command |\n"
