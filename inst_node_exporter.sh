#!/bin/bash
set -e

wget https://github.com/prometheus/node_exporter/releases/download/v0.18.0/node_exporter-0.18.0.linux-amd64.tar.gz -O /tmp/node_exporter-0.18.0.linux-amd64.tar.gz
tar zxvf /tmp/node_exporter-0.18.0.linux-amd64.tar.gz

sudo cp ./node_exporter-0.18.0.linux-amd64/node_exporter /usr/local/bin


# Configure node exporter service
tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus node exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector --no-collector.infiniband

[Install]
WantedBy=multi-user.target

EOF


sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /var/lib/node_exporter
sudo chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector

sudo systemctl daemon-reload
sudo systemctl start node_exporter
systemctl status --no-pager node_exporter
sudo systemctl enable node_exporter
