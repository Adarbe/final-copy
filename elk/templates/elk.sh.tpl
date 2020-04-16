#!/usr/bin/env bash
set -e

### add Elasticsearch service to consul
tee /etc/consul.d/Elasticsearch-9200.json > /dev/null <<"EOF"
{
  "service": {
    "id": "Elasticsearch-9200",
    "name": "Elasticsearch",
    "tags": ["Elasticsearch"],
    "port": 9200,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9200",
        "tcp": "localhost:9200",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF


### add Logstash service to consul
tee /etc/consul.d/Logstash-5044.json > /dev/null <<"EOF"
{
  "service": {
    "id": "Logstash-5044",
    "name": "Logstash",
    "tags": ["Logstash"],
    "port": 5044,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 5044",
        "tcp": "localhost:5044",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF


### add Kibana service to consul
tee /etc/consul.d/Kibana-5601.json > /dev/null <<"EOF"
{
  "service": {
    "id": "Kibana-5601",
    "name": "Kibana",
    "tags": ["Kibana"],
    "port": 5601,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 5601",
        "tcp": "localhost:5601",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF



consul reload