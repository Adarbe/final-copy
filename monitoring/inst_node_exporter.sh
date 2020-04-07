#!/bin/bash
set -e

# This script downloads and installs node_exporter of the requested version on a host.
# node_exporter is set up as a systemd service, which requiers a daemon-reload.
# INSTRUCTIONS: Before running make sure node_exporter.service exists in same dir.

node_exporter_ver="0.18.0"

wget \
  https://github.com/prometheus/node_exporter/releases/download/v$node_exporter_ver/node_exporter-$node_exporter_ver.linux-amd64.tar.gz \
  -O /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz

tar zxvf /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz

sudo cp ./node_exporter-$node_exporter_ver.linux-amd64/node_exporter /usr/local/bin

sudo useradd --no-create-home --shell /bin/false node_exporter

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /var/lib/node_exporter
sudo chown node_exporter:node_exporter /var/lib/node_exporter/textfile_collector

sudo cp ./node_exporter.service /etc/systemd/system/node_exporter.service

rm -rf /tmp/node_exporter-$node_exporter_ver.linux-amd64.tar.gz \
  ./node_exporter-$node_exporter_ver.linux-amd64

sudo systemctl daemon-reload

sudo systemctl start node_exporter

systemctl status --no-pager node_exporter

sudo systemctl enable node_exporter
