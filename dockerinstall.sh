#!/usr/bin/env bash

# From https://docs.docker.com/engine/install/ubuntu/
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
RELEASE_FILE="$(if [[ -f /etc/os-release ]]; then echo '/etc/os-release'; else echo '/etc/lsb-release'; fi)"
DEBIAN_OR_UBUNTU="$(if grep -q 'ubuntu' "$RELEASE_FILE"; then echo 'ubuntu'; else echo 'debian'; fi)"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$DEBIAN_OR_UBUNTU \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
