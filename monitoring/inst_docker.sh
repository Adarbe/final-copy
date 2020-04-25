#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y
sudo usermod -aG docker $USER
sudo docker run hello-world
sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

sudo mkdir /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/docker.root.conf &>/dev/null << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -g /data/docker-root -H fd://
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo docker info
sudo docker run hello-world



