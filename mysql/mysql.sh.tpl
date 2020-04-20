{* #!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/jenkins-master.json > /dev/null <<"EOF"
{
"Services": [ {
    "id": "jenkins-8080",
    "name": "jenkins-master",
    "service": "jenkins-master",
    "address": "127.0.0.1",
    "port": 8080,
    "enableTagOverride": false,
    "tags" : ["jenkins-master"],
    "interval": "10s",
    "timeout": "1s"
  },
  {
    "id": "jenkins-node-exporter",
    "name": "jenkins-node-exporter",
    "service": "node-exporter",
    "address": "127.0.0.1",
    "port": 9100,
    "enableTagOverride": false,
    "tags" : ["node-exporter"],
    "interval": "10s",
    "timeout": "1s"
  } ]
}
EOF


systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

consul reload *}
