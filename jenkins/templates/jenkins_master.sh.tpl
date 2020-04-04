#!/usr/bin/env bash
set -e

### Install Prometheus Collector
wget https://files.pythonhosted.org/packages/ff/6e/0a679e6a55e472f0c0c0c09ec6b096f3d42e90370d7b12f6d9480f269bab/prometheus-jenkins-exporter-0.2.4.tar.gz
mkdir -p ${prometheus_dir}
tar zxf /tmp/promcoll.tgz -C ${prometheus_dir}

# Create jenkins_master configuration
mkdir -p ${prometheus_conf_dir}
tee ${prometheus_conf_dir}/prometheus.yml > /dev/null <<EOF
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:8080']
EOF

- job_name: ‘jenkins’
  metrics_path: /prometheus
  static_configs:
    - targets: [jenkins_master:8080’]

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
