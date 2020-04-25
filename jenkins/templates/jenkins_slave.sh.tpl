#!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/jenkins-slave.json > /dev/null <<"EOF"
{
 "service": {
    "name": "jenkins-slave",
    "port": 22,
    "check": 
      {
        "id": "ssh",
        "name": "SSH on port 22",
        "tcp": "localhost:22",
        "interval": "10s",
        "timeout": "1s"
      }
    }
  }
}

EOF 

/usr/local/bin/consul reload