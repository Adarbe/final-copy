#!/usr/bin/env bash
set -e

### set consul version
CONSUL_VERSION="1.4.0"

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install unzip dnsmasq &>/dev/null

echo "Configuring dnsmasq..."
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

systemctl restart dnsmasq

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul

# Setup Consul
mkdir -p /opt/consul
mkdir -p /etc/consul.d
mkdir -p /run/consul
tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "Opsschool-final-project",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "server": true,
  "bootstrap_expect": 1,
  "ui": true,
  "client_addr": "0.0.0.0"
}
EOF

# Create user & grant ownership of folders
useradd consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul


# Configure consul service
tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service








wget https://github.com/prometheus/consul_exporter/releases/download/v0.6.0/consul_exporter-0.6.0.linux-amd64.tar.gz -O /tmp/consul_exporter-0.6.0.linux-amd64.tar.gz
tar zxvf /tmp/consul_exporter-0.6.0.linux-amd64.tar.gz
cd /tmp
sudo cp /tmp/consul_exporter-0.6.0.linux-amd64.tar.gz/consul_exporter /usr/local/bin


# Configure consul_exporter service
tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus consul_exporter
Wants=network-online.target
After=network-online.target

[Service]
User=consul_exporter
Group=consul_exporter
Type=simple
ExecStart=/usr/local/bin/consul_exporter

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl start consul_exporter
systemctl enable consul_exporter




### Install Prometheus Collector
wget https://github.com/prometheus/prometheus/releases/download/v2.16.0/prometheus-2.16.0.linux-amd64.tar.gz -O /tmp/promcoll.tgz
mkdir -p /etc/prometheus
tar zxf /tmp/promcoll.tgz -C /etc/prometheus

# Create promcol configuration
mkdir -p /etc/prometheus
tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
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
ExecStart=/etc/prometheus/prometheus-2.16.0.linux-amd64/prometheus --config.file=/etc/prometheus/prometheus.yml
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
sudo tee /etc/consul.d/promcol-9090.json > /dev/null <<"EOF"
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