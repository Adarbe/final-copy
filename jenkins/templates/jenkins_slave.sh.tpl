#!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/jenkins-22.json > /dev/null <<"EOF"
{
  "service": {
    "id": "jenkins-22",
    "name": "jenkins_slave",
    "tags": ["jenkins_slave"],
    "port": 22,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 22",
        "tcp": "localhost:22",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

consul reload




