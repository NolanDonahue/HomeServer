#!/bin/bash

# This script performs basic system updates, installs Docker,
# sets a 'bat' alias for battery status, and configures lid switch behavior.
# It is designed to be run on an Ubuntu server.

sudo apt-get update -y
sudo apt-get upgrade -y

# --- Install 'bat' alias in .bashrc ---
# This alias uses 'upower' to display battery information.
# Ensure 'upower' is installed if you intend to use this alias.
# For the alias to take effect, the user must log out and log back in,
# or run 'source ~/.bashrc' after the script completes.
# Assuming the target user is 'test'. Adjust '/home/test/.bashrc' if needed.
echo "--- Adding 'bat' alias to .bashrc for user 'test' ---"
ALIAS_LINE="alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E \"time full|percentage\"'"
# Check if the alias already exists to prevent duplicates
if ! grep -qF "$ALIAS_LINE" /home/test/.bashrc; then
    echo "$ALIAS_LINE" | sudo tee -a /home/test/.bashrc > /dev/null
    echo "Alias 'bat' added to /home/test/.bashrc."
else
    echo "Alias 'bat' already exists in /home/test/.bashrc. Skipping."
fi

# --- Add Docker's official GPG key and repository ---
echo "--- Installing Docker prerequisites and adding GPG key ---"
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "--- Adding Docker repository to APT sources ---"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "--- Installing Docker packages ---"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Set HandleLidSwitch to ignore in logind.conf ---
# This prevents the server from suspending or shutting down when the lid is closed.
echo "--- Configuring HandleLidSwitch to ignore in logind.conf ---"
# Make a backup of the original file first
sudo cp /etc/systemd/logind.conf /etc/systemd/logind.conf.bak
# Use sed to uncomment and set HandleLidSwitch to ignore
sudo sed -i 's/^#\(HandleLidSwitch=\).*/\1ignore/' /etc/systemd/logind.conf
echo "Restarting systemd-logind service for changes to take effect..."
sudo systemctl restart systemd-logind

echo "--- Script Finished ---"
