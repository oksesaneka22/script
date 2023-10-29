#!/bin/bash

sudo apt update
sudo apt install apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
repository_url="https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
echo "Adding Docker repository: $repository_url"
echo | sudo add-apt-repository "deb [arch=amd64] $repository_url"
sudo apt update
sudo apt install docker-ce -y

sudo usermod -aG docker $USER

sudo systemctl status docker
docker -v

apt install docker-compose -y
