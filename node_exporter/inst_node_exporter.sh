### Install Node Exporter

wget \
  https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz  -O /tmp/node_exporter.tgz
mkdir -p /opt/prometheus

tar zxv /tmp/node_exporter.tgz -C  /opt/prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /opt/prometheus/node_exporter


sudo mkdir -p /opt/prometheus/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /opt/prometheus/node_exporter
sudo chown node_exporter:node_exporter /opt/prometheus/node_exporter/textfile_collector

# Configure node exporter service
tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus node exporter
Requires=network-online.target
After=network.target

[Service]
ExecStart=/opt/prometheus/node_exporter-0.18.1.linux-amd64/node_exporter
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF



systemctl daemon-reload
systemctl start node_exporter
systemctl status --no-pager node_exporter
systemctl enable node_exporter