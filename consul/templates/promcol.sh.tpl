#!/usr/bin/env bash
set -e

### Install Prometheus Collector
wget https://github.com/prometheus/prometheus/releases/download/v2.16.0/prometheus-2.16.0.linux-amd64.tar.gz -O /tmp/promcoll.tgz
mkdir -p ${prometheus_dir}
tar zxf /tmp/promcoll.tgz -C ${prometheus_dir}

# Create promcol configuration
mkdir -p ${prometheus_conf_dir}
tee ${prometheus_conf_dir}/prometheus.yml > /dev/null <<EOF
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
EOF

# Configure promcol service
tee /etc/systemd/system/promcol.service > /dev/null <<EOF
[Unit]
Description=Prometheus Collector
Requires=network-online.target
After=network.target

[Service]
ExecStart=${prometheus_dir}/prometheus-${promcol_version}.linux-amd64/prometheus --config.file=${prometheus_conf_dir}/prometheus.yml
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable promcol.service
systemctl start promcol.service

### add promcol service to consul
tee /etc/consul.d/promcol-9090.json > /dev/null <<"EOF"
{
  "service": {
    "id": "promcol-9090",
    "name": "promcol",
    "tags": ["promcol"],
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
