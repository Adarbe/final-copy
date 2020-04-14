#!/bin/bash
set -e

apt-get update -y
apt install docker.io -y
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
mkdir -p /home/ubuntu/jenkins_home
chown -R 1000:1000 /home/ubuntu/jenkins_home
 
docker build -t myjenkins:01 /home/ubuntu
docker run -d -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JAVA_OPTS='-Djenkins.install.runSetupWizard=false' myjenkins:01

