#!/usr/bin/env bash
set -e

### add jenkins service to consul
tee /etc/consul.d/elk.json > /dev/null <<"EOF"
{
  "service": {
      "name": "ElasticSearch_ELK",
      "port": 9200,
      "check": {
          "id": "ElasticSearch-health",
          "name": "HTTP health",
          "http": "http://localhost:9200/_cluster/health",
          "interval": "10s",
          "timeout": "1s"
      }
    }
}
EOF

consul reload