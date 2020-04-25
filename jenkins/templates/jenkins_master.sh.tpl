#!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/jenkins-master.json > /dev/null <<"EOF"
{
 "service": {
    "name": "jenkins-master",
    "port": 8080,
    "check": {
      {
        "id": "tcp",
        "name": "TCP on port 8080",
        "http": "localhost:8080",
        "interval": "10s",
        "timeout": "1s"
      }
    }
  }
}
EOF

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service