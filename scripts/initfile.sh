#!/usr/bin/env bash

# Update Ubuntu
sudo apt update -y
sudo apt upgrade -y

# Install Ansible
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible


