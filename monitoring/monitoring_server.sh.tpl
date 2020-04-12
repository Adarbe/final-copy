#!/usr/bin/env bash
set -e
                
### add pro + gra service to consul
tee /etc/consul.d/monitoring-3000.json > /dev/null <<"EOF"
{
  "service": {
    "id": "monitoring_grafana",
    "name": "monitoring_grafana",
    "tags": ["grafana"],
    "port": 3000,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 3000",
        "tcp": "localhost:3000",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

tee /etc/consul.d/monitoring-9090.json > /dev/null <<"EOF"
{
  "service": {
    "id": "monitoring_prometheus",
    "name": "monitoring_server_prometheus",
    "tags": ["prometheus"],
    "port": 9090,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9090",
        "tcp": "localhost:9090",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

consul reload