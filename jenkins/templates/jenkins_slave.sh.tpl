#!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/jenkins-slave.json > /dev/null <<"EOF"
{
"Service": {
    "id": "jenkins-22",
    "name": "jenkins-slave",
    "port": 22,
    "tags" : ["jenkins-slave"],
    "checks": [
      {
        "id": "ssh",
        "name": "SSH on port 22",
        "tcp": "localhost:22",
        "interval": "10s",
        "timeout": "1s"
      }
}

consul reload




