#!/usr/bin/env bash
set -e

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

systemctl reload consul.service


cd /home/ec2-user/.ssh
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null
sudo chmod 600 id_rsa
sudo chmod 600 id_rsa.pub
cat id_rsa.pub >> /home/ec2-user/.ssh/authorized_keys