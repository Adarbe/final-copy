#!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/jenkins-8080.json > /dev/null <<"EOF"
{
  "service": {
    "id": "jenkins-8080",
    "name": "jenkins_master",
    "tags": ["jenkins_master"],
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
