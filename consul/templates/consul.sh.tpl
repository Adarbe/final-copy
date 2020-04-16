#!/usr/bin/env bash
set -e

apt-get upgrade
### set consul version
CONSUL_VERSION="1.4.0"

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install unzip dnsmasq &>/dev/null

sleep 30

echo "Configuring dnsmasq..."
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

systemctl restart dnsmasq

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

sudo systemctl restart systemd-resolved

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
  "datacenter": "final-project",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "server": true,
  "bootstrap_expect": 3,
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



### Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz -O /tmp/node_exporter.tgz

mkdir -p /opt/prometheus
tar zxf /tmp/node_exporter.tgz -C /opt/prometheus
useradd --no-create-home --shell /bin/false node_exporter
chown node_exporter:node_exporter /opt/prometheus/node_exporter

mkdir -p /opt/prometheus/node_exporter/textfile_collector
chown node_exporter:node_exporter /opt/prometheus/node_exporter/textfile_collector

# Configure node exporter service
tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus node exporter
Requires=network-online.target
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/prometheus/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF




tee /etc/consul.d/node_exporter.json > /dev/null <<"EOF"
{
  "service": {
    "id": "node_exporter",
    "name": "node_exporter",
    "tags": ["node_exporter", "prometheus"],
    "port": 9100,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9100",
        "tcp": "localhost:9100",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service

### Install Node Exporter
wget https://github.com/prometheus/consul_exporter/releases/download/v0.6.0/consul_exporter-0.6.0.linux-amd64.tar.gz -O /tmp/consul_exporter-0.6.0.tgz
tar zxf /tmp/tmp/consul_exporter-0.6.0.tgz -C /opt/prometheus
chown node_exporter:node_exporter /opt/prometheus/consul_exporter-0.6.0

mkdir -p /opt/prometheus/consul_exporter-0.6.0/textfile_collector
chown node_exporter:node_exporter /opt/prometheus/consul_exporter-0.6.0/textfile_collector



systemctl daemon-reload
systemctl enable node_exporter.service
systemctl start node_exporter.service