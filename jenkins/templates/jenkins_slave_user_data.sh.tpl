#!/usr/bin/env bash
set -e

cd /home/ec2-user/.ssh
ssh-keygen
sudo chmod 600 id_rsa
sudo chmod 600 id_rsa.pub
cat id_rsa.pub >> /home/ec2-user/.ssh/authorized_keys
cat id_rsa

### add jenkins service to consul
tee /etc/consul.d/jenkins-8080.json > /dev/null <<"EOF"
{
  "service": {
    "id": "jenkins-8080",
    "name": "jenkins_slave",
    "tags": ["jenkins_slave"],
    "port": 8080,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9090",
        "tcp": "localhost:8080",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

consul reload