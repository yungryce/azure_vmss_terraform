#!/usr/bin/env bash

# Create a log file
echo "Hello World. This is VM instance $(hostname)." > /var/log/custom_data.log

# Update Ubuntu
sudo apt update -y
sudo apt upgrade -y

# Install Ansible
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
