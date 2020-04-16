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

tee /etc/consul.d/node_exporter.json > /dev/null <<"EOF"
{
  "service": {
    "id": "node_exporter",
    "name": "node_exporter",
    "tags": ["node_exporter", "prometheus"],
    "port": 9100,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9100",
        "tcp": "localhost:9100",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

consul reload




