#!/bin/bash

# Description: This script is executed on the Application VM at first boot.
# It updates the system, installs Docker, and runs an Nginx container.

# Update the package manager's list of available packages.
sudo apt-get update -y

# Install the Docker engine.
sudo apt-get install -y docker.io

# Start the Docker service and enable it to start on boot.
sudo systemctl start docker
sudo systemctl enable docker

# Pull the nginx:alpine image and run it as a container.
# -d: Run in detached mode (in the background).
# -p 80:80: Map port 80 on the VM to port 80 in the container.
# --name nginx: Give the container a friendly name.
# --restart unless-stopped: Ensure the container restarts if the VM reboots.
sudo docker run -d -p 80:80 --name nginx --restart unless-stopped nginx:alpine
